require 'spec_helper'
require 'active_record'

class TestModel < ::ActiveRecord::Base
#  self.abstract_class = true
end

class TestActiveRecordExtractor < Migratrix::Extractors::ActiveRecord
end

describe Migratrix::Extractors::ActiveRecord do
  let(:extractor) { TestActiveRecordExtractor.new }
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Extractors::Extractor.should_not be_nil
      TestActiveRecordExtractor.should_not be_nil
    end
  end

  describe ".new" do
    it "raises TypeError unless source is Active" do
      lambda { TestActiveRecordExtractor.new :source => Object }.should raise_error(TypeError)
    end
  end

  describe "#source=" do
    it "raises TypeError unless source is Active" do
      lambda { extractor.source = Object }.should raise_error(TypeError)
    end
  end

  describe "#obtain_source" do
    it "raises ExtractorSourceUndefined unless source is defined" do
      lambda { extractor.extract }.should raise_error(Migratrix::ExtractorSourceUndefined)
    end

    it "returns the legacy ActiveRecord class" do
      extractor.source = TestModel
      extractor.obtain_source(TestModel).should == TestModel
    end
  end
end

