require 'spec_helper'

# This migration is embedded in migration_spec.rb to allow testing of
# the class methods that specialize subclasses.
class Migratrix::TestMigration < Migratrix::Migration
end

describe Migratrix::Migration do
  let(:migration) { Migratrix::TestMigration.new :cheese => 42 }
  let(:loggable) { Migratrix::TestMigration.new }
  let(:mock_extractor) { mock("Migratrix::Extractors::ActiveRecord", :extract => 43, :valid_options => ["fetchall", "limit", "offset", "order", "where"])}

  it_should_behave_like "loggable"

  describe "#migrate" do
    it "delegates to extract, transform, and load" do
      migration.should_receive(:extract).once
      migration.should_receive(:transform).once
      migration.should_receive(:load).once
      migration.migrate
    end
  end

  describe "with mock active_record extractor" do
    before do
      Migratrix::Extractors::ActiveRecord.should_receive(:new).with({:source => Object}).and_return(mock_extractor)
      Migratrix::TestMigration.set_extractor :active_record, :source => Object
    end

    describe ".set_extractor" do
      it "sets the class instance variable for extractor" do
        Migratrix::TestMigration.extractor.should == mock_extractor
      end

      it "also sets convenience instance method for extractor" do
        Migratrix::TestMigration.new.extractor.should == mock_extractor
      end
    end

    describe "#extract" do
      it "delegates to extractor" do
        migration.extract.should == 43
      end
    end
  end

  describe "with mock map transform" do
    let(:map) { { :id => :id, :name => :name }}
    let(:mock_extractor) { mock("Migratrix::Extractors::ActiveRecord", :extract => [42,13,43,14], :valid_options => ["fetchall", "limit", "offset", "order", "where"])}
    let(:transform1) { mock("Migratrix::Transforms::Map", :transform => [{:id => 42, :name => "Mister Bobo"}, {:id => 43, :name => "Mrs. Bobo"}], :valid_options => ["map"])}
    let(:transform2) { mock("Migratrix::Transforms::Map", :transform => [{:id => 13, :name => "Sparky"}, {:id => 14, :name => "Fido"}], :valid_options => ["map"])}
    before do
      Migratrix::TestMigration.transforms.clear
      Migratrix::Extractors::ActiveRecord.should_receive(:new).with({:source => Object }).and_return(mock_extractor)
      Migratrix::Transforms::Map.should_receive(:new).with(:monkeys, :transform => map).and_return(transform1)
      Migratrix::Transforms::Map.should_receive(:new).with(:puppies, :transform => map).and_return(transform2)
      Migratrix::TestMigration.set_extractor :active_record, :source => Object
      Migratrix::TestMigration.set_transform :monkeys, :map, :transform => map
      Migratrix::TestMigration.set_transform :puppies, :map, :transform => map
    end

    describe ".set_transform" do
      it "sets the class instance variable for transforms" do
        Migratrix::TestMigration.transforms.should == [transform1, transform2]
      end

      it "also sets convenience instance method for extractor" do
        Migratrix::TestMigration.new.transforms.should == [transform1, transform2]
      end
    end

#     describe "#transform" do
#       it "delegates to each transforms" do
#         migration.transforms.should == ...WRITE ME
#       end
#     end
  end

  describe "#valid_options" do
    it "returns its valid options plus those of its extractor, transforms and loads" do
      Migratrix::Extractors::ActiveRecord.should_receive(:new).with({:source => Object}).and_return(mock_extractor)
      Migratrix::TestMigration.set_extractor :active_record, :source => Object
      migration.valid_options.should == ["console", "fetchall", "limit", "offset", "order", "where"]
    end
  end

  # TODO: it should lo

#   describe "#valid_options" do
#     it "returns the valid set of option keys" do
#       migration.valid_options.should == ["limit", "offset", "order", "where"]
#     end
#   end

#   describe "#filter_options" do
#     it "filters out invalid options" do
#       options = migration.filter_options({ "pants" => 42, "limit" => 3})
#       options["limit"].should == 3
#       options.should_not have_key("pants")
#     end
#   end
end


