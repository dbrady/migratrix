require 'spec_helper'

class TestExtraction < Migratrix::Extractions::Extraction
end

class TestTransform < Migratrix::Transforms::Transform
end

class TestLoad < Migratrix::Loads::Load
end

describe Migratrix::Migratrix do
  let (:migratrix) { Migratrix::Migratrix.new }

  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix.should_not be_nil
      Migratrix.class.should == Module
      Migratrix.class.should_not == Class
      Migratrix::Migratrix.class.should_not == Module
      Migratrix::Migratrix.class.should == Class
      Migratrix.const_defined?("Migratrix").should be_true
    end
  end

  describe "Migration Component Registry" do
    describe ".register_extraction" do
      before do
        Migratrix::Migratrix.register_extraction :test_extraction, TestExtraction, { :source => Object }
      end

      it "registers the extraction" do
        Migratrix::Migratrix.extractions.registered?(:test_extraction).should be_true
        Migratrix::Migratrix.extractions.class_for(:test_extraction).should == TestExtraction
      end

      it "creates the extraction with given options" do
        extraction = TestExtraction.new :test
        Migratrix::Migratrix.extractions.registered?(:test_extraction).should be_true
        Migratrix::Migratrix.extractions.class_for(:test_extraction).should == TestExtraction
      end
    end

    describe ".register_transform" do
      before do
        Migratrix::Migratrix.register_transform :test_transform, TestTransform, { :source => Object }
      end

      it "registers the transform" do
        Migratrix::Migratrix.transforms.registered?(:test_transform).should be_true
        Migratrix::Migratrix.transforms.class_for(:test_transform).should == TestTransform
      end

      it "creates the transform with given options" do
        transform = TestTransform.new :monkeys
        Migratrix::Migratrix.transforms.registered?(:test_transform).should be_true
        Migratrix::Migratrix.transforms.class_for(:test_transform).should == TestTransform
      end
    end

    describe ".register_load" do
      before do
        Migratrix::Migratrix.register_load :test_load, TestLoad
      end

      it "registers the load" do
        Migratrix::Migratrix.loads.registered?(:test_load).should be_true
        Migratrix::Migratrix.loads.class_for(:test_load).should == TestLoad
      end

      it "creates the load with given options" do
        load = TestLoad.new :monkeys
        Migratrix::Migratrix.loads.registered?(:test_load).should be_true
        Migratrix::Migratrix.loads.class_for(:test_load).should == TestLoad
      end
    end
  end

  describe "with logger as a singleton" do
    let (:migration) { Migratrix::Migration.new }
    let (:buffer) { StringIO.new }

    def spec_all_loggers_are(this_logger)
      Migratrix.logger.should == this_logger
      Migratrix::Migratrix.logger.should == this_logger
      migratrix.logger.should == this_logger
      migration.logger.should == this_logger
      Migratrix::Migration.logger.should == this_logger
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

