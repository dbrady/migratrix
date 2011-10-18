require 'spec_helper'

class TestMap < Migratrix::Transforms::Map
end

describe Migratrix::Transforms::Map do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Transforms::Map.should_not be_nil
      TestMap.should_not be_nil
    end
  end

  describe "#valid_options" do
    let(:transform) { Migratrix::Transforms::Map.new(:map_transform) }
    it "returns the valid set of option keys" do
      transform.valid_options.should == ["target", "transform"]
    end
  end
end

