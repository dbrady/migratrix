require 'spec_helper'

describe Migratrix do
  describe "sanity check kitty" do
    it "is sanity checked" do
      Migratrix.should_not be_nil
      Migratrix.class.should == Module
    end
  end

  describe "convenience delegator methods" do
    def spec_delegates_to_migratrix_class(method, *args)
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
        Migratrix::Migratrix.should_receive(:migrate).with(:marbles, {:cheese => 42})
        Migratrix.migrate! :marbles, {:cheese => 42}
      end
    end

    describe ".logger" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :logger
      end
    end

    describe ".create_migration" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :create_migration, :marbles, :source => Object
      end
    end

    describe ".logger=" do
      let (:logger) { Logger.new(StringIO.new) }
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :logger=, logger
      end
    end

    describe ".log_to" do
      let (:buffer) { StringIO.new }
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :log_to, buffer
      end
    end

    describe ".reload_migration" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :reload_migration, :marbles
      end
    end

    describe ".register_extractor" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :register_extractor, :marbles, Array, 3
      end
    end

    describe ".extractors" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :extractors
      end
    end
  end

  describe "gem-installed components" do
    it "registers :active_record migration" do
      Migratrix.extractors.class_for(:active_record).should == ::Migratrix::Extractors::ActiveRecord
    end
  end
end

