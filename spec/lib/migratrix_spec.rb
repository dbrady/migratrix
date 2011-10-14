require 'spec_helper'

def reset_migratrix
  # TODO: Move this back to "fragile" hacky code that hacks
  # Migratrix's constants because these specs are the ONLY clients of
  # the remove_migration method, and it's preventing me from
  # extracting the Registry.
  if Migratrix.loaded?("MarblesMigration")
    Migratrix.remove_migration("MarblesMigration")
  end
  Migratrix.migrations_path = SPEC + "fixtures/migrations"
end

describe Migratrix do
  before do
    Migratrix.class_eval("class PantsMigration < Migration; end")
  end

  it "exists" do
    Migratrix.should_not be_nil
  end

  describe "MigrationRegistry (needs to be extracted)" do
    before do
      Migratrix.register_migration "PantsMigration", Migratrix::PantsMigration
    end

    it "can register migrations by name" do
      Migratrix.loaded?("PantsMigration").should be_true
      Migratrix.const_defined?("PantsMigration").should be_true
    end

    it "can fetch registered migration class" do
      Migratrix.fetch_migration("PantsMigration").should == Migratrix::PantsMigration
    end

    it "raises fetch error when fetching unregistered migration" do
      lambda { Migratrix.fetch_migration("arglebargle") }.should raise_error(KeyError)
    end

    it "can remove migrations and their constants" do
      Migratrix.remove_migration "PantsMigration"
      Migratrix.loaded?("PantsMigration").should be_false
      Migratrix.const_defined?("PantsMigration").should be_false
    end
  end

  describe "Migrations path" do
    it "uses ./lib/migrations by default" do
      Rails.stub!(:root).and_return(Pathname.new('/tmp'))
      Migratrix.migrations_path.should == Pathname.new("/tmp") + "lib/migrations"
    end

    it "can be overridden" do
      Migratrix.migrations_path = Pathname.new('/tmp')
      Migratrix.migrations_path.should == Pathname.new("/tmp")
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

  describe ".migration_name" do
    it "classifies the name and adds Migration" do
      Migratrix.migration_name("shirt").should == "ShirtMigration"
    end

    it "handles symbols" do
      Migratrix.migration_name(:socks).should == "SocksMigration"
    end

    it "preserves pluralization" do
      Migratrix.migration_name(:pants).should == "PantsMigration"
      Migratrix.migration_name(:shirts).should == "ShirtsMigration"
    end
  end

  describe ".create_migration" do
    before do
      reset_migratrix
    end

    it "creates new migration by name with filtered options" do
      migration = Migratrix.create_migration :marbles, { "cheese" => 42, "where" => "id > 100", "limit" => "100" }
      migration.class.should == Migratrix::MarblesMigration
      Migratrix::MarblesMigration.should_not be_migrated
      migration.options.should == { "where" => "id > 100", "limit" => "100" }
    end
  end

  describe ".migrate" do
    before do
      reset_migratrix
    end

    it "loads migration and migrates it" do
      Migratrix.migrate :marbles
      Migratrix::MarblesMigration.should be_migrated
    end
  end

end

