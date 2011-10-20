require 'spec_helper'

# This migration is embedded in migration_spec.rb to allow testing of
# the class methods that specialize subclasses.
class Migratrix::TestMigration < Migratrix::Migration
end

describe Migratrix::Migration do
  let(:migration) { Migratrix::TestMigration.new :cheese => 42 }
  let(:loggable) { Migratrix::TestMigration.new }
  let(:mock_extractor) { mock("Migratrix::Extractors::ActiveRecord", :name => :pets, :extract => 43, :valid_options => ["fetchall", "limit", "offset", "order", "where"])}
  it_should_behave_like "loggable"

  describe "#migrate" do
    it "delegates to extract, transform, and load" do
      migration.should_receive(:extract).once
      migration.should_receive(:transform).once
      migration.should_receive(:load).once
      migration.migrate
    end
  end

  describe "with registered mock active_record extractor" do
    before do
      Migratrix.extractors.should_receive(:class_for).with(:active_record).and_return(Migratrix::Extractors::ActiveRecord)
      Migratrix::Extractors::ActiveRecord.should_receive(:new).with(:pets, { :source => Object }).and_return(mock_extractor)
      Migratrix::TestMigration.set_extractor :pets, :active_record, :source => Object
    end

    describe ".set_extractor" do
      it "sets the class instance variable for extractor" do
        Migratrix::TestMigration.extractors[:pets].should == mock_extractor
      end

      it "also sets convenience instance method for extractor" do
        Migratrix::TestMigration.new.extractors[:pets].should == mock_extractor
      end
    end

    describe "#extract" do
      it "delegates to extractor" do
        migration.extract.should == { :pets => 43 }
      end
    end
  end

  describe "with mock map transform" do
    let(:map) { { :id => :id, :name => :name }}
    let(:mock_extractor) {
      mock("Migratrix::Extractors::ActiveRecord", {
             :extract => {:animals => [42,13,43,14]},
             :valid_options => ["fetchall", "limit", "offset", "order", "where"]
           }
      )
    }
    let(:transform1) {
      mock("Migratrix::Transforms::Map", {
             :name => :tame,
             :transform => [{:id => 42, :name => "Mister Bobo"}, {:id => 43, :name => "Mrs. Bobo"}],
             :valid_options => ["map"],
             :extractor => :animals
           })
    }
    let(:transform2) {
      mock("Migratrix::Transforms::Map", {
             :name => :animals,
             :extractor => :animals,
             :transform => [{:id => 13, :name => "Sparky"}, {:id => 14, :name => "Fido"}],
             :valid_options => ["map"]
           }
      )
    }

    before do
      Migratrix::TestMigration.extractors.clear
      Migratrix::TestMigration.transforms.clear
      Migratrix::Extractors::ActiveRecord.should_receive(:new).with(:animals, {:source => Object }).and_return(mock_extractor)
      Migratrix::Transforms::Map.should_receive(:new).with(:monkeys, :transform => map, :extractor => :animals).and_return(transform1)
      Migratrix::Transforms::Map.should_receive(:new).with(:puppies, :transform => map, :extractor => :animals).and_return(transform2)
      Migratrix::TestMigration.set_extractor :animals, :active_record, :source => Object
      Migratrix::TestMigration.set_transform :monkeys, :map, :transform => map, :extractor => :animals
      Migratrix::TestMigration.set_transform :puppies, :map, :transform => map, :extractor => :animals
    end

    describe ".set_transform" do
      it "sets the class instance variable for transforms" do
        Migratrix::TestMigration.transforms.should == { :monkeys => transform1, :puppies => transform2 }
      end

      it "also sets convenience instance method for extractor" do
        Migratrix::TestMigration.new.transforms.should == { :monkeys => transform1, :puppies => transform2 }
      end
    end

    describe "#transform" do
      it "should pass named extracted_items to each transform" do
        transform1.should_receive(:transform).with([42,13,43,14])
        transform2.should_receive(:transform).with([42,13,43,14])

        migration = Migratrix::TestMigration.new
        migration.transform(mock_extractor.extract)
      end
    end
  end
end

