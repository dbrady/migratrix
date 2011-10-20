require 'spec_helper'

class TestExtractor < Migratrix::Extractors::Extractor
end

class TestTransform < Migratrix::Transforms::Transform
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

  describe "Migration Component Registry" do
    describe ".register_extractor" do
      before do
        Migratrix::Migratrix.register_extractor :test_extractor, TestExtractor, { :source => Object }
      end

      it "registers the extractor" do
        Migratrix::Migratrix.extractors.registered?(:test_extractor).should be_true
        Migratrix::Migratrix.extractors.class_for(:test_extractor).should == TestExtractor
      end

      it "creates the extractor with given options" do
        extractor = TestExtractor.new :test
        Migratrix::Migratrix.extractors.registered?(:test_extractor).should be_true
        Migratrix::Migratrix.extractors.class_for(:test_extractor).should == TestExtractor
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
#         # separate this--registration names the class, not the transform stream
#         TestTransform.should_receive(:new).with(:monkeys, { :source => Hash }).and_return(transform)
#         Migratrix::Migratrix.transform(:test_transform, :monkeys, { :source => Hash}).should == transform
      end
    end
  end

  describe "with logger as a singleton" do
    let (:migration) { Migratrix::MarblesMigration.new }
    let (:buffer) { StringIO.new }

    def spec_all_loggers_are(this_logger)
      Migratrix.logger.should == this_logger
      Migratrix::Migratrix.logger.should == this_logger
      migratrix.logger.should == this_logger
      migration.logger.should == this_logger
      Migratrix::MarblesMigration.logger.should == this_logger
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

