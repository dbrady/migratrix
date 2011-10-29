require 'spec_helper'
require 'active_record'

class TestModel < ::ActiveRecord::Base
end

class TestActiveRecordExtraction < Migratrix::Extractions::ActiveRecord
end

describe Migratrix::Extractions::ActiveRecord do
  let(:extraction) { TestActiveRecordExtraction.new :test }
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Extractions::Extraction.should_not be_nil
      TestActiveRecordExtraction.should_not be_nil
    end
  end

  describe ".new" do
    it "raises TypeError unless source is Active" do
      lambda { TestActiveRecordExtraction.new :test, :source => Object }.should raise_error(TypeError)
    end
  end

  describe "#source=" do
    it "raises TypeError unless source is Active" do
      lambda { extraction.source = Object }.should raise_error(TypeError)
    end
  end

  describe ".local_valid_options" do
    it "returns the valid set of option keys" do
      Migratrix::Extractions::ActiveRecord.local_valid_options.should == [:fetchall, :includes, :joins]
    end
  end

  describe ".valid_options" do
    it "returns the valid set of option keys" do
      Migratrix::Extractions::ActiveRecord.valid_options.should == [:fetchall, :includes, :joins] + Migratrix::Extractions::Extraction.valid_options
    end
  end

  describe "#obtain_source" do
    it "raises ExtractionSourceUndefined unless source is defined" do
      lambda { extraction.extract }.should raise_error(Migratrix::ExtractionSourceUndefined)
    end

    it "returns the legacy ActiveRecord class" do
      extraction.source = TestModel
      extraction.obtain_source(TestModel).should == TestModel
    end
  end

  describe "handler functions" do
    let(:source) { TestModel }
    before do
      extraction.source = source
    end

    [:where, :order, :limit, :offset, :includes, :joins].each do |handler|
      describe "#handle_#{handler}" do
        it "calls #{handler} on the source ActiveRelation" do
          source.should_receive(handler).with(1).and_return(nil)
          extraction.send("handle_#{handler}", source, 1)
        end
      end
    end
  end

  describe "#to_sql" do
    let(:source) { TestModel }
    let(:relation) { source.where(1) }
    let(:lolquery) { 'SELECT "HAY GUYZ IM A QUARY LOL"' }
    before do
      extraction.source = source
    end

    describe "when source does not have to_sql (e.g. is ActiveRecord)" do
      it "converts it to ActiveRelation with where(1)" do
        extraction.should_receive(:handle_where).with(source, 1).and_return(relation)
        relation.should_receive(:to_sql).and_return(lolquery)
        extraction.to_sql(source).should == lolquery
      end
    end

    describe "When source responds to to_sql (e.g. is already an ActiveRelation)" do
      it "delegates to to_sql on source" do
        relation.should_receive(:respond_to?).with(:to_sql).and_return(true)
        relation.should_receive(:to_sql).and_return(lolquery)
        extraction.to_sql(relation).should == lolquery
      end
    end

    describe "with default source" do
      it "uses @source" do
        extraction = Migratrix::Extractions::ActiveRecord.new(:default, source: source)
        source.should_receive(:to_sql).and_return(lolquery)
        extraction.to_sql.should == lolquery
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

    describe "with 'fetchall' option" do
      let(:extraction) { TestActiveRecordExtraction.new :test, "fetchall" => true }

      describe "and source is an ActiveRelation" do
        it "calls all on the relation" do
          relation.should_receive(:all).and_return([])
          extraction.execute_extract(relation, extraction.options).should == []
        end
      end

      describe "and source is still ActiveRecord" do
        it "converts it to ActiveRelation with where(1)" do
          source.should_receive(:all).and_return([])
          extraction.execute_extract(source, extraction.options).should == []
        end
      end
    end

    describe "without 'fetchall' option" do
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
          extraction.execute_extract(relation).should == relation
        end
      end

      describe "and source is still ActiveRecord" do
        it "converts it to ActiveRelation with where(1)" do
          extraction.should_receive(:handle_where).with(source, 1).and_return(relation)
          extraction.execute_extract(source).should == relation
        end
      end
    end
  end
end

