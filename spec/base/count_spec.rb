require File.dirname(__FILE__) + '/../spec_helper.rb'

IS_ALPHA = ENV['COUCHDB_IS_ALPHA'] == 'true'

describe "ActiveCouch::Base #count method with just simple attributes" do
  before(:each) do
    # Define the model
    class Person < ActiveCouch::Base
      site 'http://localhost:5984'
      has :name
    end
    # Define the migration
    class ByName < ActiveCouch::Migration
      define :for_db => 'people', :is_alpha => IS_ALPHA do
        with_key 'name'
      end
    end
    # Create the database first
    ActiveCouch::Migrator.create_database('http://localhost:5984', 'people')
    # Create a view
    ActiveCouch::Migrator.migrate('http://localhost:5984', ByName)
    # Save an object
    Person.new(:name => 'McLovin').save
  end

  after(:each) do
    # Delete the database last
    ActiveCouch::Migrator.delete_database('http://localhost:5984', 'people')
    Object.send(:remove_const, :Person)
  end

  it "should respond to the find method" do
    Person.should respond_to(:count)
  end

  it "should return an array with one Person object in it, when sent method find with parameter :all" do
    count = Person.count(:params => {:name => 'McLovin'})
    count.should == 1
  end
end


describe "ActiveCouch::Base #find method with multiple documents in the CouchDB database" do
  before(:each) do
    class Person < ActiveCouch::Base
      site 'http://localhost:5984'
      
      has :first_name
      has :last_name
    end
    
    # Define the migration
    class ByLastName < ActiveCouch::Migration
      define :for_db => 'people', :is_alpha => IS_ALPHA do
        with_key 'last_name'
      end
    end
    # Create the database first
    ActiveCouch::Migrator.create_database('http://localhost:5984', 'people')
    # Create a view
    ActiveCouch::Migrator.migrate('http://localhost:5984', ByLastName)
    # Save two objects
    Person.create(:last_name => 'McLovin', :first_name => 'Seth')
    Person.create(:last_name => 'McLovin', :first_name => 'Bob')
  end
  
  after(:each) do
    # Delete the database last
    ActiveCouch::Migrator.delete_database('http://localhost:5984', 'people')
    Object.send(:remove_const, :Person)
  end
  
  it "should find all objects in the database when find method is sent the param :all" do
    count = Person.count(:params => {:last_name => 'McLovin'})
    count.should == 2
  end
end
