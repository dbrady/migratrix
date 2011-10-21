require 'spec_helper'

class TestLoad < Migratrix::Loads::Load
end

describe Migratrix::Loads::Load do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Loads::Load.should_not be_nil
      TestLoad.should_not be_nil
    end
  end

  let(:loggable) { TestLoad.new(:loggable) }
  it_should_behave_like "loggable"

  # describe ".local_valid_options" do
  #   it "returns the valid set of option keys" do
  #     Migratrix::Extractors::Extractor.local_valid_options.should == [:limit, :offset, :order, :where]
  #   end
  # end

  describe '#load' do
    describe "default strategy" do
      it "saves every transformed object" do
        data = mock("transformed_object", :save => true)
        load = TestLoad.new(:test_load)
        data.should_receive(:save).exactly(3).times
        load.load([data,data,data])
      end
    end
  end

  describe "#transform" do
    it "returns transform name when set" do
      load = Migratrix::Loads::Load.new(:pants_load, { transform: :pants_transform })
      load.transform.should == :pants_transform
    end

    it "#returns load name when no transform name is set" do
      load = Migratrix::Loads::Load.new(:pants_load)
      load.transform.should == :pants_load
    end
  end

  # describe "unimplemented methods:" do
  #   [ [:before_load, []],
  #     [:after_load, []] ].each do |method, args|
  #     describe "#{method}(#{args.map(&:inspect)*','})" do
  #       let(:object_with_not_implemented_methods) { Migratrix::Loads::Load.new(:brain_damaged_transform) }
  #       it "raises NotImplementedError" do
  #         lambda { object_with_not_implemented_methods.send(method, *args) }.should raise_error(NotImplementedError)
  #       end
  #     end
  #   end
  # end

end

