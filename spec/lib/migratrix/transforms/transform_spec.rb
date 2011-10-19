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

  describe "unimplemented methods:" do
    [ [:create_transformed_collection, []],
      [:create_new_object, [:extracted_row]],
      [:apply_attribute, [:object, :value, :attribute_or_apply]],
      [:extract_attribute, [:object, :attribute_or_extract]],
      [:store_transformed_object, [:object, :collection]] ].each do |method, args|
      describe "#{method}(#{args.map(&:inspect)*','})" do
        let(:object_with_not_implemented_methods) { Migratrix::Transforms::Transform.new(:brain_damaged_transform) }
        it "raises NotImplementedError" do
          lambda { object_with_not_implemented_methods.send(method, *args) }.should raise_error(NotImplementedError)
        end
      end
    end
  end
end

