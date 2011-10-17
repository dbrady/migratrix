require 'spec_helper'

class TestExtractor < Migratrix::Extractors::Extractor
end

describe Migratrix::Extractors::Extractor do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Extractors::Extractor.should_not be_nil
      TestExtractor.should_not be_nil
    end
  end

  describe "unimplemented method" do
    let(:base_extractor) { Migratrix::Extractors::Extractor.new }
    [:obtain_source, :handle_where, :handle_limit, :handle_offset, :handle_order, :to_query, :execute_extract].each do |method|
      describe "#{method}" do
        it "raises NotImplementedError" do
          lambda { base_extractor.send(method, nil) }.should raise_error(NotImplementedError)
        end
      end
    end
  end

  describe "#extract (default strategy)" do
    describe "with no options" do
      let(:extractor) { TestExtractor.new }
      it "should call handle_source and execute_extract only" do
        extractor.should_receive(:obtain_source).with(nil).and_return(13)
        extractor.should_receive(:execute_extract).with(13).and_return(64)
        extractor.extract.should == 64
      end
    end

    describe "with all options" do
      let(:extractor) { TestExtractor.new "where" => 1, "order" => 2, "limit" => 3, "offset" => 4 }
      it "should call entire handler chain" do
        extractor.should_receive(:obtain_source).with(nil).and_return("A")
        extractor.should_receive(:handle_where).with("A", 1).and_return("B")
        extractor.should_receive(:handle_order).with("B", 2).and_return("C")
        extractor.should_receive(:handle_limit).with("C", 3).and_return("D")
        extractor.should_receive(:handle_offset).with("D", 4).and_return("E")
        extractor.should_receive(:execute_extract).with("E").and_return("BONG")
        extractor.extract.should == "BONG"
      end
    end

    describe "with overridden options" do
      let(:extractor) { TestExtractor.new  }
      let(:overrides) { {"where" => 5, "order" => 6, "limit" => 7, "offset" => 8 } }
      it "should call entire handler chain" do
        extractor.should_receive(:obtain_source).with(nil).and_return("A")
        extractor.should_receive(:handle_where).with("A", 5).and_return("B")
        extractor.should_receive(:handle_order).with("B", 6).and_return("C")
        extractor.should_receive(:handle_limit).with("C", 7).and_return("D")
        extractor.should_receive(:handle_offset).with("D", 8).and_return("E")
        extractor.should_receive(:execute_extract).with("E").and_return("BONG")
        extractor.extract(overrides).should == "BONG"
      end
    end
  end
end

