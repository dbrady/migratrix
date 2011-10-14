require 'spec_helper'

# Changing the migrations_path is a stateful class variable that is
# preserved between test runs. This ensures that the path is reset
# even if the spec fails or raises an exception.
def with_reset_migratrix(&block)
  begin
    old_path = Migratrix.migrations_path
    Migratrix.migrations_path = SPEC + "fixtures/migrations"
    if Migratrix.const_defined?("MarblesMigration")
      Migratrix.send(:remove_const, :MarblesMigration)
      Migratrix.registered_migrations.delete "MarblesMigration"
    end

    yield
  ensure
    Migratrix.migrations_path = old_path
  end
end

describe Migratrix do
  before do
    Migratrix.class_eval("class PantsMigration < Migration; end")
  end

  it "exists (sanity check)" do
    Migratrix.should_not be_nil
  end

  describe ".new" do
    it "does not modify given options hash" do
      with_reset_migratrix do
        conditions = ["id=? AND approved=?", 42, true]
        migration = Migratrix.create_migration(:marbles, { "where" => conditions })
        migration.options["where"][0] += " AND pants=?"
        migration.options["where"] << false
        migration.options["where"].should == ["id=? AND approved=? AND pants=?", 42, true, false]
        conditions.should == ["id=? AND approved=?", 42, true]
      end
    end
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
  end

  describe "Migrations path" do
    it "uses ./lib/migrations by default" do
      Migratrix.migrations_path.should == ROOT + "lib/migrations"
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
    it "creates new migration by name with filtered options" do
      with_reset_migratrix do
        migration = Migratrix.create_migration :marbles, { "cheese" => 42, "where" => "id > 100", "limit" => "100" }
        migration.class.should == Migratrix::MarblesMigration
        Migratrix::MarblesMigration.should_not be_migrated
        migration.options.should == { "where" => "id > 100", "limit" => "100" }
      end
    end
  end

  describe ".migrate" do
    it "loads migration and migrates it" do
      with_reset_migratrix do
        Migratrix.migrate :marbles
        Migratrix::MarblesMigration.should be_migrated
      end
    end
  end
end

