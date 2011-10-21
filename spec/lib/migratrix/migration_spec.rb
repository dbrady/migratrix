require 'spec_helper'

# This migration is embedded in migration_spec.rb to allow testing of
# the class methods that specialize subclasses.
class TestMigration < Migratrix::Migration
end

describe Migratrix::Migration do
  let(:migration) { TestMigration.new :cheese => 42 }
  let(:mock_extractor) { mock("Migratrix::Extractors::ActiveRecord", :name => :pets, :extract => 43, :valid_options => ["fetchall", "limit", "offset", "order", "where"])}

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
    let(:extractor) {
      mock("Migratrix::Extractors::ActiveRecord", {
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
             :extractor => :animals
           })
    }
    let(:transform2) {
      mock("Migratrix::Transforms::Map", {
             :name => :animals,
             :extractor => :animals,
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
      TestMigration.extractors.clear
      TestMigration.transforms.clear
      TestMigration.loads.clear

      # Intercept the delegated component creations
      Migratrix::Extractors::ActiveRecord.should_receive(:new).with(:animals, {:source => Object }).and_return(extractor)

      Migratrix::Transforms::Map.should_receive(:new).with(:monkeys, :transform => map, :extractor => :animals).and_return(transform1)
      Migratrix::Transforms::Map.should_receive(:new).with(:puppies, :transform => map, :extractor => :animals).and_return(transform2)

      Migratrix::Loads::Yaml.should_receive(:new).with(:monkeys, :filename => '/tmp/monkeys.yml').and_return(load1)
      Migratrix::Loads::Yaml.should_receive(:new).with(:puppies, :filename => '/tmp/puppies.yml').and_return(load2)


      TestMigration.set_extractor :animals, :active_record, :source => Object
      TestMigration.set_transform :monkeys, :map, :transform => map, :extractor => :animals
      TestMigration.set_transform :puppies, :map, :transform => map, :extractor => :animals
      TestMigration.set_load :monkeys, :yaml, :filename => '/tmp/monkeys.yml'
      TestMigration.set_load :puppies, :yaml, :filename => '/tmp/puppies.yml'
    end

    describe ".set_extractor" do
      it "sets the class instance variable for extractor" do
        TestMigration.extractors[:animals].should == extractor
      end

      it "also sets convenience instance method for extractor" do
        TestMigration.new.extractors[:animals].should == extractor
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
      it "delegates to extractor" do
        extractor.should_receive(:extract).and_return([42,13,43,14])
        migration.extract.should == {:animals => [42,13,43,14]}
      end
    end

    describe "#transform" do
      it "should pass named extracted_items to each transform" do
        transform1.should_receive(:transform).with([42,13,43,14])
        transform2.should_receive(:transform).with([42,13,43,14])

        migration = TestMigration.new
        migration.transform(extractor.extract)
      end
    end

    describe "#load" do
      it "should pass named transformed_items to each load" do
        load1.should_receive(:load).with([{:id => 42, :name => "Mister Bobo"}, {:id => 43, :name => "Mrs. Bobo"}])
        load2.should_receive(:load).with([{:id => 13, :name => "Sparky"}, {:id => 14, :name => "Fido"}])

        migration = TestMigration.new
        extracteds = extractor.extract
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
end

