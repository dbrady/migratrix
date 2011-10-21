require 'spec_helper'

# This migration is embedded in migration_spec.rb to allow testing of
# the class methods that specialize subclasses.
class TestMigration < Migratrix::Migration
end

class ChildMigration1 < TestMigration
end

class ChildMigration2 < TestMigration
end

class GrandchildMigration1 < ChildMigration1
end

describe Migratrix::Migration do
  let(:migration) { TestMigration.new :cheese => 42 }
  let(:mock_extraction) { mock("Migratrix::Extractions::ActiveRecord", :name => :pets, :extract => 43, :valid_options => ["fetchall", "limit", "offset", "order", "where"])}

  let(:loggable) { TestMigration.new }
  it_should_behave_like "loggable"

  describe "#migrate" do
    it "delegates to extract, transform, and load" do
      migration.should_receive(:extract).once
      migration.should_receive(:transform).once
      migration.should_receive(:load).once
      migration.migrate
    end
  end

  describe "with mocked components" do
    let(:map) { { :id => :id, :name => :name }}
    let(:extraction) {
      mock("Migratrix::Extractions::ActiveRecord", {
             :extract => {:animals => [42,13,43,14]},
             :valid_options => [:fetchall, :limit, :offset, :order, :where]
           }
      )
    }
    let(:transform1) {
      mock("Migratrix::Transforms::Map", {
             :name => :tame,
             :transform => [{:id => 42, :name => "Mister Bobo"}, {:id => 43, :name => "Mrs. Bobo"}],
             :valid_options => [:map],
             :extraction => :animals
           })
    }
    let(:transform2) {
      mock("Migratrix::Transforms::Map", {
             :name => :animals,
             :extraction => :animals,
             :transform => [{:id => 13, :name => "Sparky"}, {:id => 14, :name => "Fido"}],
             :valid_options => [:map]
           }
      )
    }
    let(:load1) {
      mock("Migratrix::Loads::Yaml", {
        :name => :cute,
        :filename => "/tmp/monkeys.yml",
        :valid_options => [:filename],
        :transform => :tame
      })
    }
    let(:load2) {
      mock("Migratrix::Loads::Yaml", {
        :name => :adorable,
        :filename => "/tmp/puppies.yml",
        :valid_options => [:filename],
        :transform => :animals
      })
    }

    before do
      # Clear out any named components
      TestMigration.extractions.clear
      TestMigration.transforms.clear
      TestMigration.loads.clear

      # Intercept the delegated component creations
      Migratrix::Extractions::ActiveRecord.should_receive(:new).with(:animals, {:source => Object }).and_return(extraction)

      Migratrix::Transforms::Map.should_receive(:new).with(:monkeys, :transform => map, :extraction => :animals).and_return(transform1)
      Migratrix::Transforms::Map.should_receive(:new).with(:puppies, :transform => map, :extraction => :animals).and_return(transform2)

      Migratrix::Loads::Yaml.should_receive(:new).with(:monkeys, :filename => '/tmp/monkeys.yml').and_return(load1)
      Migratrix::Loads::Yaml.should_receive(:new).with(:puppies, :filename => '/tmp/puppies.yml').and_return(load2)


      TestMigration.set_extraction :animals, :active_record, :source => Object
      TestMigration.set_transform :monkeys, :map, :transform => map, :extraction => :animals
      TestMigration.set_transform :puppies, :map, :transform => map, :extraction => :animals
      TestMigration.set_load :monkeys, :yaml, :filename => '/tmp/monkeys.yml'
      TestMigration.set_load :puppies, :yaml, :filename => '/tmp/puppies.yml'
    end

    describe ".set_extraction" do
      it "sets the class instance variable for extraction" do
        TestMigration.extractions[:animals].should == extraction
      end

      it "also sets convenience instance method for extraction" do
        TestMigration.new.extractions[:animals].should == extraction
      end
    end

    describe ".set_transform" do
      it "sets the class instance variable for transforms" do
        TestMigration.transforms.should == { :monkeys => transform1, :puppies => transform2 }
      end

      it "also sets convenience instance method for transform" do
        TestMigration.new.transforms.should == { :monkeys => transform1, :puppies => transform2 }
      end
    end

    describe ".set_load" do
      it "sets the class instance variable for loads" do
        TestMigration.loads.should == { :monkeys => load1, :puppies => load2 }
      end

      it "also sets convenience instance method for load" do
        TestMigration.new.loads.should == { :monkeys => load1, :puppies => load2 }
      end
    end

    describe "#extract" do
      it "delegates to extraction" do
        extraction.should_receive(:extract).and_return([42,13,43,14])
        migration.extract.should == {:animals => [42,13,43,14]}
      end
    end

    describe "#transform" do
      it "should pass named extracted_items to each transform" do
        transform1.should_receive(:transform).with([42,13,43,14])
        transform2.should_receive(:transform).with([42,13,43,14])

        migration = TestMigration.new
        migration.transform(extraction.extract)
      end
    end

    describe "#load" do
      it "should pass named transformed_items to each load" do
        load1.should_receive(:load).with([{:id => 42, :name => "Mister Bobo"}, {:id => 43, :name => "Mrs. Bobo"}])
        load2.should_receive(:load).with([{:id => 13, :name => "Sparky"}, {:id => 14, :name => "Fido"}])

        migration = TestMigration.new
        extracteds = extraction.extract
        transforms = migration.transform(extracteds)
        migration.load(transforms)
      end
    end

    describe ".valid_options" do
      it "returns valid options from itself and components" do
        TestMigration.valid_options.should == [:console, :fetchall, :limit, :map, :offset, :order, :where]
      end
    end
  end

  describe "extending" do
    before do
      [TestMigration, ChildMigration1, ChildMigration2, GrandchildMigration1].each do |klass|
        [:extractions, :transforms, :loads].each do |kollection|
          klass.send(kollection).send(:clear)
        end
      end
      TestMigration.set_extraction :cheese, :extraction, { first_option: 'id>100' }
      TestMigration.set_transform :cheese, :transform, { first_option: 'id>100' }
      TestMigration.set_load :cheese, :load, { first_option: 'id>100' }

    end

    [:extraction, :transform, :load ].each do |component|
      describe "#{component}" do
        it "extends the #{component} to child class" do
          ChildMigration1.send("extend_#{component}", :cheese, { second_option: 2 })
          ChildMigration1.new.send("#{component}s")[:cheese].options.should == { second_option: 2, first_option: 'id>100'}
        end

        it "extends the #{component} to the grandchild class" do
          ChildMigration1.send("extend_#{component}", :cheese, { second_option: 2 })
          GrandchildMigration1.send("extend_#{component}", :cheese, { surprise_option: 50 })
          GrandchildMigration1.new.send("#{component}s")[:cheese].options.should == { second_option: 2, first_option: 'id>100', surprise_option: 50 }
        end

        it "extends the #{component} to the grandchild class even if the child class does not extend" do
          GrandchildMigration1.send("extend_#{component}", :cheese, { surprise_option: 50 })
          GrandchildMigration1.new.send("#{component}s")[:cheese].options.should == { first_option: 'id>100', surprise_option: 50 }
        end

        it "overrides parent options" do
          ChildMigration1.send("extend_#{component}", :cheese, { second_option: 2, first_option: 'id>50' })
          ChildMigration1.new.send("#{component}s")[:cheese].options.should == { second_option: 2, first_option: 'id>50'}
        end

        it "does not affect sibling class options" do
          ChildMigration1.send("extend_#{component}", :cheese, { second_option: 2, first_option: 'id>50' })
          ChildMigration2.send("extend_#{component}", :cheese, { zany_option: Hash, first_option: 'id>75' })
          ChildMigration1.new.send("#{component}s")[:cheese].options.should == { second_option: 2, first_option: 'id>50'}
          ChildMigration2.new.send("#{component}s")[:cheese].options.should == { zany_option: Hash, first_option: 'id>75'}
        end

        it "does not affect parent class options" do
          ChildMigration1.send("extend_#{component}", :cheese, { second_option: 2, first_option: 'id>50' })
          ChildMigration1.new.send("#{component}s")[:cheese].options.should == { second_option: 2, first_option: 'id>50'}
          TestMigration.new.send("#{component}s")[:cheese].options.should == { first_option: 'id>100'}
        end

        it "raises #{component.capitalize}NotDefined if no parent has that #{component}" do
          exception = "Migratrix::#{component.capitalize}NotDefined".constantize
          lambda { ChildMigration1.send("extend_#{component}", :blargle, { second_option: 2, first_option: 'id>50' }) }.should raise_error(exception)
        end
      end
    end


    # TODO: lambdas cannot be deep-copied, and form closures at the
    # time of creation. Is there a way to detect if a lambda has a
    # closure?
  end
end

