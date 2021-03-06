require 'spec_helper'

describe Migratrix do
  describe "sanity check cat" do
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

    describe ".logger" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :logger
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

    describe ".register_extraction" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :register_extraction, :marbles, Array, 3
      end
    end

    describe ".extractions" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :extractions
      end
    end

    describe ".register_transform" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :register_transform, :marbles, Array, 3
      end
    end

    describe ".transforms" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :transforms
      end
    end

    describe ".register_load" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :register_load, :marbles, Array, 3
      end
    end

    describe ".loads" do
      it "delegates to Migratrix::Migratrix" do
        spec_delegates_to_migratrix_class :loads
      end
    end
  end

  describe "gem-installed components:" do
    describe "extractions" do
      it ":active_record is registered" do
        Migratrix.extractions.class_for(:active_record).should == ::Migratrix::Extractions::ActiveRecord
      end
    end

    describe "transforms" do
      it ":transform is registered" do
        Migratrix.transforms.class_for(:transform).should == ::Migratrix::Transforms::Transform
      end

      it ":map is registered" do
        Migratrix.transforms.class_for(:map).should == ::Migratrix::Transforms::Map
      end
    end

    # transforms: map, transform
  end
end

