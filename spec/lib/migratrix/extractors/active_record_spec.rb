require 'spec_helper'
require 'active_record'

class TestModel < ::ActiveRecord::Base
#  self.abstract_class = true
  set_table_name :test_model
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

  describe "handler functions" do
    let(:source) { TestModel }
    before do
      extractor.source = source
    end

    [:where, :order, :limit, :offset].each do |handler|
      describe "#handle_#{handler}" do
        it "calls #{handler} on the source ActiveRelation" do
          source.should_receive(handler).with(1).and_return(nil)
          extractor.send("handle_#{handler}", source, 1)
        end
      end
    end
  end

  describe "#to_query" do
    let(:source) { TestModel }
    let(:relation) { source.where(1) }
    let(:lolquery) { 'SELECT "HAY GUYZ IM A QUARY LOL"' }
    before do
      extractor.source = source
    end

    describe "when source is ActiveRecord" do
      it "converts it to ActiveRelation with where(1)" do
        extractor.should_receive(:handle_where).with(source, 1).and_return(relation)
        relation.should_receive(:to_sql).and_return(lolquery)
        extractor.to_query(source).should == lolquery
      end
    end

    describe "When source has already been converted to ActiveRelation" do
      it "delegates to to_sql on source" do
        relation.should_receive(:to_sql).and_return(lolquery)
        extractor.to_query(relation).should == lolquery
      end
    end
  end

  describe "#execute_extract" do
    let(:source) { TestModel }
    let(:relation) { source.where(1) }
    let(:lolquery) { 'SELECT "HAY GUYZ IM A QUARY LOL"' }

    before do
      TestModel.stub!(:establish_connection).and_return true
    end

    describe "with :fetchall option" do
      let(:extractor) { TestActiveRecordExtractor.new :fetchall => true }

      describe "and source is an ActiveRelation" do
        it "calls all on the relation" do
          relation.should_receive(:all).and_return([])
          extractor.execute_extract(relation).should == []
        end
      end

      describe "and source is still ActiveRecord" do
        it "converts it to ActiveRelation with where(1)" do
          source.should_receive(:all).and_return([])
          extractor.execute_extract(source).should == []
        end
      end
    end

    describe "without :fetchall option" do
      before do
        # hrm, okay, this is tricky. The should == is setting off a
        # tripwire in ActiveRecord that makes it try to connect to
        # the database. This is AR internals dependent, but if the
        # relation has a cached to_sql, it will return it without
        # trying to connect.
        relation.should_receive(:to_sql).at_least(1).times.and_return(lolquery)
      end

      describe "and source is an ActiveRelation" do
        it "returns source unmodified" do
          extractor.execute_extract(relation).should == relation
        end
      end

      describe "and source is still ActiveRecord" do
        it "converts it to ActiveRelation with where(1)" do
          extractor.should_receive(:handle_where).with(source, 1).and_return(relation)
          extractor.execute_extract(source).should == relation
        end
      end
    end
  end
end

