require 'spec_helper'

describe Migratrix do
  describe "sanity check kitty" do
    it "is sanity checked" do
      Migratrix.should_not be_nil
      Migratrix.class.should == Module
    end
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
      Migratrix::Migratrix.should_receive(:logger).and_return nil
      Migratrix.logger
    end
  end

  describe ".logger=" do
    let (:logger) { Logger.new(StringIO.new) }
    it "delegates to Migratrix::Migratrix" do
      Migratrix::Migratrix.should_receive(:logger=).with(logger).and_return nil
      Migratrix.logger = logger
    end
  end
end

