require 'spec_helper'

class TestTransform < Migratrix::Transforms::Transform
end

describe Migratrix::Transforms::Transform do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Transforms::Transform.should_not be_nil
      TestTransform.should_not be_nil
    end
  end

  describe "#valid_options" do
    let(:base_transform) { Migratrix::Transforms::Transform.new(:base_transform) }
    it "returns the valid set of option keys" do
      base_transform.valid_options.should == ["target", "transform"]
    end
  end

  describe

  # You know, with the exception of the not_implemented_methods list
  # and the base object class, this could easily become a shared
  # example group.

#   describe "unimplemented methods:" do
#     let(:base_transform) { Migratrix::Transforms::Transform.new }
#     [].each do |method|
#       describe "#{method}" do
#         it "raises NotImplementedError" do
#           lambda { base_transform.send(method, nil) }.should raise_error(NotImplementedError)
#         end
#       end
#     end
#   end

end
