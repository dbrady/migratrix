require 'spec_helper'

# This code is hacky and touches the internals of Migratrix, which I
# don't like, so I refactored Migratrix to have a remove_migration
# method which uregistered the migration and deleted the class out of
# the module, which seemed dangerous and weird. When I realized that
# the ONLY client of remove_migration is this spec file--and that the
# API was preventing me from extracting class MigrationRegistry from
# inside of Migratrix--I removed the API and put the hacky dangerous
# code back in. I'm not a bad programmer, honest. Well, not an evil
# one, anyway. Anyway, point of all this is, if you discover a
# legitimate reason to unregister a migration and delete its class
# constant out of the Migratrix namespace, you're going to nee that
# API call, and here's the code that goes in it.
def reset_migratrix!(path=nil)
    Migratrix.migrations_path = path || Migratrix::DEFAULT_MIGRATIONS_PATH
    Migratrix.constants.map(&:to_s).select {|m| m =~ /.+Migration$/}.each do |migration|
      Migratrix.send(:remove_const, migration.to_sym)
      Migratrix.registered_migrations.delete "MarblesMigration"
    end
end

# migrations_path is a stateful class variable that is not reset
# between test runs. If you need to use migratrix fixtures, this
# overrides the default path behavior and un-sets the MarblesMigration
# fixture. This ensures that the path and fixtures are reset even if
# the spec fails or raises an exception.
#
def with_migratrix_fixtures_available(&block)
  begin
    old_path = Migratrix.migrations_path
    reset_migratrix! SPEC + "fixtures/migrations"
    yield
  ensure
    reset_migratrix!
  end
end

describe Migratrix do
  before do
    Migratrix.class_eval("class PantsMigration < Migration; end")
  end

  it "exists (sanity check)" do
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
      with_migratrix_fixtures_available do
        migration = Migratrix.create_migration :marbles, { "cheese" => 42, "where" => "id > 100", "limit" => "100" }
        migration.class.should == Migratrix::MarblesMigration
        Migratrix::MarblesMigration.should_not be_migrated
        migration.options.should == { "where" => "id > 100", "limit" => "100" }
      end
    end
  end

  describe ".migrate" do
    it "loads migration and migrates it" do
      with_migratrix_fixtures_available do
        Migratrix.migrate :marbles
        Migratrix::MarblesMigration.should be_migrated
      end
    end
  end
end

