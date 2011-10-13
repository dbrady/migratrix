require 'spec_helper'

def reset_migratrix
  if Migratrix.loaded?("MarblesMigrator")
    Migratrix.remove_migrator("MarblesMigrator")
  end
  Migratrix.migrators_path = SPEC + "fixtures/migrators"
end

describe Migratrix do
  before do
    Migratrix.class_eval("class PantsMigrator < Migrator; end")
  end

  it "exists" do
    Migratrix.should_not be_nil
  end

  describe "MigratorRegistry (needs to be extracted)" do
    before do
      Migratrix.register_migrator "PantsMigrator", Migratrix::PantsMigrator
    end

    it "can register migrators by name" do
      Migratrix.loaded?("PantsMigrator").should be_true
      Migratrix.const_defined?("PantsMigrator").should be_true
    end

    it "can fetch registered migrator class" do
      Migratrix.fetch_migrator("PantsMigrator").should == Migratrix::PantsMigrator
    end

    it "raises fetch error when fetching unregistered migrator" do
      lambda { Migratrix.fetch_migrator("arglebargle") }.should raise_error(KeyError)
    end

    it "can remove migrators and their constants" do
      Migratrix.remove_migrator "PantsMigrator"
      Migratrix.loaded?("PantsMigrator").should be_false
      Migratrix.const_defined?("PantsMigrator").should be_false
    end
  end

  describe "Migrators path" do
    it "uses ./lib/migrators by default" do
      Rails.stub!(:root).and_return(Pathname.new('/tmp'))
      Migratrix.migrators_path.should == Pathname.new("/tmp") + "lib/migrators"
    end

    it "can be overridden" do
      Migratrix.migrators_path = Pathname.new('/tmp')
      Migratrix.migrators_path.should == Pathname.new("/tmp")
    end
  end

  describe ".valid_options" do
    it "returns the valid set of option keys" do
      Migratrix.valid_options.should == ["limit", "where"]
    end
  end

  describe ".filter_options" do
    it "filters out invalid options" do
      Migratrix.filter_options({ "pants" => 42, "limit" => 3}).should == { "limit" => 3}
    end
  end

  describe ".migrator_name" do
    it "classifies the name and adds Migrator" do
      Migratrix.migrator_name("shirt").should == "ShirtMigrator"
    end

    it "handles symbols" do
      Migratrix.migrator_name(:socks).should == "SocksMigrator"
    end

    it "preserves pluralization" do
      Migratrix.migrator_name(:pants).should == "PantsMigrator"
      Migratrix.migrator_name(:shirts).should == "ShirtsMigrator"
    end
  end

  describe ".create_migrator" do
    before do
      reset_migratrix
    end

    it "creates new migrator by name with filtered options" do
      migrator = Migratrix.create_migrator :marbles, { "cheese" => 42, "where" => "id > 100", "limit" => "100" }
      migrator.class.should == Migratrix::MarblesMigrator
      Migratrix::MarblesMigrator.should_not be_migrated
      migrator.options.should == { "where" => "id > 100", "limit" => "100" }
    end
  end

  describe ".migrate!" do
    before do
      reset_migratrix
    end

    it "loads migrator and migrates it" do
      Migratrix.migrate! :marbles
      Migratrix::MarblesMigrator.should be_migrated
    end
  end

end

