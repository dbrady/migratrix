require 'spec_helper'

class TestExtraction < Migratrix::Extractions::Extraction
end

describe Migratrix::Extractions::Extraction do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Extractions::Extraction.should_not be_nil
      TestExtraction.should_not be_nil
    end
  end

  describe ".local_valid_options" do
    it "returns the valid set of option keys" do
      Migratrix::Extractions::Extraction.local_valid_options.should == [:limit, :offset, :order, :where]
    end
  end

  describe "unimplemented methods:" do
    let(:base_extraction) { Migratrix::Extractions::Extraction.new :test }
    [:obtain_source, :handle_where, :handle_limit, :handle_offset, :handle_order, :to_query, :execute_extract].each do |method|
      describe "#{method}" do
        it "raises NotImplementedError" do
          args = [nil, nil]
          args.shift if method == :to_query
          lambda { base_extraction.send(method, *args) }.should raise_error(NotImplementedError)
        end
      end
    end
  end

  describe "#extract (default strategy)" do
    describe "with no options" do
      let(:extraction) { TestExtraction.new :test }
      it "calls handle_source and execute_extract only" do
        extraction.should_receive(:obtain_source).with(nil, {where: []}).and_return(13)
        extraction.should_receive(:execute_extract).with(13, {where: []}).and_return(64)
        extraction.extract.should == 64
      end
    end

    describe "with all options" do
      let(:options) { { :where => [1], :order => 2, :limit => 3, :offset => 4 } }
      let(:extraction) { TestExtraction.new :test, options }
      it "calls entire handler chain" do
        extraction.should_receive(:obtain_source).with(nil, options).and_return("A")
        extraction.should_receive(:handle_where).with("A", 1).and_return("B")
        extraction.should_receive(:handle_order).with("B", 2).and_return("C")
        extraction.should_receive(:handle_limit).with("C", 3).and_return("D")
        extraction.should_receive(:handle_offset).with("D", 4).and_return("E")
        extraction.should_receive(:execute_extract).with("E", options).and_return("BONG")
        extraction.extract.should == "BONG"
      end
    end

    describe "with overridden options" do
      let(:options) { { :where => [1], :order => 2, :limit => 3, :offset => 4 } }
      let(:extraction) { TestExtraction.new :test, options }
      let(:overrides) { {:where => [5], :order => 6, :limit => 7, :offset => 8 } }
      let(:merged_options) { {:where => [5, 1], :order => 6, :limit => 7, :offset => 8 } }
      it "calls entire handler chain, merging where clauses" do
        extraction.should_receive(:obtain_source).with(nil, merged_options).and_return("A")
        extraction.should_receive(:handle_where).exactly(2).times.and_return("B")
        extraction.should_receive(:handle_order).with("B", 6).and_return("C")
        extraction.should_receive(:handle_limit).with("C", 7).and_return("D")
        extraction.should_receive(:handle_offset).with("D", 8).and_return("E")
        extraction.should_receive(:execute_extract).with("E", merged_options).and_return("BONG")
        extraction.extract(overrides).should == "BONG"
      end
    end

    describe "with where clause" do
      let(:options) { { :where => 1, :order => 2, :limit => 3, :offset => 4 } }
      let(:extraction) { TestExtraction.new :test, options }
      it "promotes where clause to array" do
      end
    end
  end
end

