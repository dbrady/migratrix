require 'spec_helper'

class TestExtractor < Migratrix::Extractors::Extractor
end

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

    describe ".register_extractor" do
      before do
        Migratrix::Migratrix.register_extractor :test_extractor, TestExtractor, { :source => Object }
      end

      it "registers the extractor" do
        Migratrix::Migratrix.extractors.registered?(:test_extractor).should be_true
        Migratrix::Migratrix.extractors.class_for(:test_extractor).should == TestExtractor
      end

      it "creates the extractor with given options" do
        extractor = TestExtractor.new
        Migratrix::Migratrix.extractors.registered?(:test_extractor).should be_true
        Migratrix::Migratrix.extractors.class_for(:test_extractor).should == TestExtractor
        TestExtractor.should_receive(:new).with({ :source => Object }).and_return(extractor)
        Migratrix::Migratrix.extractor(:test_extractor).should == extractor
      end
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

    it "creates new migration by name with unfiltered options" do
      opts = { "cheese" => 42, "where" => "id > 100", "limit" => "100" }
      migration = migratrix.create_migration :marbles, opts
      migration.class.should == Migratrix::MarblesMigration
      Migratrix::MarblesMigration.should_receive(:new).with(opts).and_return(migration)
      migratrix.create_migration :marbles, opts
    end
  end

  describe ".migrate" do
    before do
      reset_migratrix! migratrix
      migratrix.migrations_path = SPEC + "fixtures/migrations"
    end

    it "loads migration and migrates it" do
      Migratrix::Migratrix.stub!(:new).and_return(migratrix)
      Migratrix::Migratrix.create_migration :marbles
      migration = Migratrix::MarblesMigration.new
      Migratrix::MarblesMigration.stub!(:new).and_return(migration)
      Migratrix::Migratrix.migrate :marbles
      migration.should be_migrated
    end

    describe "with 'console' option" do
      it "tells Migratrix class to log to $stdout" do
        Migratrix::Migratrix.stub!(:new).and_return(migratrix)
        Migratrix::Migratrix.should_receive(:log_to).with($stdout)
        Migratrix::Migratrix.migrate :marbles, {'console' => true }
      end
    end
  end

  describe ".create_migration" do
    before do
      reset_migratrix! migratrix
      migratrix.migrations_path = SPEC + "fixtures/migrations"
    end

    it "loads, registers and returns migration but does not migrate it" do
      Migratrix::Migratrix.stub!(:new).and_return(migratrix)
      migration = Migratrix::Migratrix.create_migration :marbles, {'limit' => 1}
      migration.should be_kind_of(Migratrix::MarblesMigration)
      migration.should_not be_migrated
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

