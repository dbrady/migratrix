require 'spec_helper'

describe Migratrix do
  describe "sanity check kitty" do
    it "is sanity checked" do
      Migratrix.should_not be_nil
      Migratrix.class.should == Module
    end
  end

  describe "convenience delegator methods" do
    def spec_delegates_to_migratrix(method, *args)
      if args.size > 0
        Migratrix::Migratrix.should_receive(method).with(*args).once
      else
        Migratrix::Migratrix.should_receive(method).once
      end
      Migratrix.send(method, *args)
    end

    describe ".migrate!" do
      let (:migratrix) { Migratrix::Migratrix.new }

      before do
        reset_migratrix! migratrix
        Migratrix::Migratrix.stub!(:new).and_return(migratrix)
        migratrix.migrations_path = SPEC + "fixtures/migrations"
      end

      it "delegates to Migratrix::Migratrix" do
        Migratrix.migrate! :marbles
        Migratrix::MarblesMigration.should be_migrated
      end
    end

    describe ".logger" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix :logger
      end
    end

    describe ".logger=" do
      let (:logger) { Logger.new(StringIO.new) }
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix :logger=, logger
      end
    end

    describe ".log_to" do
      let (:buffer) { StringIO.new }
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix :log_to, buffer
      end
    end

    describe ".reload_migration" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix :reload_migration, :marbles
      end
    end
  end
end

