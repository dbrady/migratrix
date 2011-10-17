require 'spec_helper'

describe Migratrix::Migratrix do
  let (:migratrix) { Migratrix::Migratrix.new }

  it "exists (sanity check)" do
    Migratrix.should_not be_nil
    Migratrix.class.should == Module
    Migratrix.class.should_not == Class
    Migratrix::Migratrix.class.should_not == Module
    Migratrix::Migratrix.class.should == Class
    Migratrix.const_defined?("Migratrix").should be_true
  end

  describe "MigrationRegistry (needs to be extracted)" do
    before do
      reset_migratrix! migratrix
      Migratrix.class_eval("class PantsMigration < Migration; end")
      migratrix.register_migration "PantsMigration", Migratrix::PantsMigration
    end

    it "can register migrations by name" do
      migratrix.loaded?("PantsMigration").should be_true
      Migratrix.const_defined?("PantsMigration").should be_true
    end

    it "can fetch registered migration class" do
      migratrix.fetch_migration("PantsMigration").should == Migratrix::PantsMigration
    end

    it "raises fetch error when fetching unregistered migration" do
      lambda { migratrix.fetch_migration("arglebargle") }.should raise_error(KeyError)
    end
  end

  describe ".migrations_path" do
    it "uses ./db/legacy by default" do
      migratrix.migrations_path.should == ROOT + "db/legacy"
    end

    it "can be overridden" do
      migratrix.migrations_path = Pathname.new('/tmp')
      migratrix.migrations_path.should == Pathname.new("/tmp")
    end
  end

  describe "#valid_options" do
    it "returns the valid set of option keys" do
      migratrix.valid_options.should == ["limit", "offset", "order", "where"]
    end
  end

  describe "#filter_options" do
    it "filters out invalid options" do
      options = migratrix.filter_options({ "pants" => 42, "limit" => 3})
      options["limit"].should == 3
      options.should_not have_key("pants")
    end
  end

  describe "#migration_name" do
    it "classifies the name and adds Migration" do
      migratrix.migration_name("shirt").should == "ShirtMigration"
    end

    it "handles symbols" do
      migratrix.migration_name(:socks).should == "SocksMigration"
    end

    it "preserves pluralization" do
      migratrix.migration_name(:pants).should == "PantsMigration"
      migratrix.migration_name(:shirts).should == "ShirtsMigration"
    end
  end

  describe "#create_migration" do
    before do
      reset_migratrix! migratrix
      migratrix.migrations_path = SPEC + "fixtures/migrations"
    end

    it "creates new migration by name with filtered options" do
      migration = migratrix.create_migration :marbles, { "cheese" => 42, "where" => "id > 100", "limit" => "100" }
      migration.class.should == Migratrix::MarblesMigration
      Migratrix::MarblesMigration.should_not be_migrated
      migration.options.should == { "where" => "id > 100", "limit" => "100" }
    end
  end

  describe ".migrate" do
    before do
      reset_migratrix! migratrix
      migratrix.migrations_path = SPEC + "fixtures/migrations"
    end

    it "loads migration and migrates it" do
      Migratrix::Migratrix.stub!(:new).and_return(migratrix)
      Migratrix::Migratrix.migrate :marbles
    end
  end

  describe "with logger as a singleton" do
    let (:migration) { migratrix.create_migration :marbles }
    let (:buffer) { StringIO.new }

    def spec_all_loggers_are(this_logger)
      Migratrix.logger.should == this_logger
      Migratrix::Migratrix.logger.should == this_logger
      migratrix.logger.should == this_logger
      migration.logger.should == this_logger
      Migratrix::MarblesMigration.logger.should == this_logger
    end

    before do
      reset_migratrix! migratrix
      migratrix.migrations_path = SPEC + "fixtures/migrations"
    end

    describe ".logger=" do
      it "sets logger globally across all Migratrices, the Migratrix module, Migrators and Models" do
        logger = Migratrix::Migratrix.create_logger(buffer)
        with_logger(logger) do
          Migratrix::Migratrix.logger = logger
          spec_all_loggers_are logger
        end
      end
    end
    describe ".log_to" do
      it "sets logger globally across all Migratrices, the Migratrix module, Migrators and Models" do
        logger = Migratrix::Migratrix.create_logger(buffer)
        with_logger(logger) do
          Migratrix::Migratrix.should_receive(:create_logger).with(buffer).once.and_return(logger)
          Migratrix.log_to buffer
          spec_all_loggers_are logger
        end
      end
    end
  end

end

