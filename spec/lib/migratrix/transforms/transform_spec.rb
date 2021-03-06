require 'spec_helper'

class TestTransform < Migratrix::Transforms::Transform
  include Migratrix::Loggable
end

describe Migratrix::Transforms::Transform do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Transforms::Transform.should_not be_nil
      TestTransform.should_not be_nil
    end
  end

  let(:loggable) { TestTransform.new(:loggable) }
  it_should_behave_like "loggable"

  describe ".local_valid_options" do
    it "returns the valid set of option keys" do
      Migratrix::Transforms::Transform.local_valid_options.should == [:apply_attribute, :extract_attribute, :extraction, :final_class, :finalize_object, :store_transform, :target, :transform, :transform_class, :transform_collection]
    end
  end


  describe "#extraction" do
    it "returns extraction name when set" do
      transform = Migratrix::Transforms::Transform.new(:pants_transform, { extraction: :pants_extraction })
      transform.extraction.should == :pants_extraction
    end

    it "#returns transform name when no extraction name is set" do
      transform = Migratrix::Transforms::Transform.new(:pants_transform)
      transform.extraction.should == :pants_transform
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

  describe "TypeError methods" do
    [:transform_collection, :transform_class, :extract_attribute, :apply_attribute, :final_class, :finalize_object, :store_transformed_object].each do |method|
      describe "With #{method} set to a string" do
        let(:transform_options) { {
            extraction: :test_stream,
            transform: { id: :src_id, name: :src_name },
            transform_collection: Array,
            transform_class:  Hash,
            extract_attribute:  ->(object, attribute) { object[attribute] },
            apply_attribute: ->(object, attribute, value) { object[attribute] = value },
            final_class: Set,
            finalize_object: ->(object) { object.to_a },
            store_transformed_object: :<<
          }.merge( method => "cheese")
        }
        let(:transform) { TestTransform.new :test, transform_options }
        let(:test_stream) { [{src_id: 42, src_name: "Alice"}, {src_id: 43, src_name: "Bob"} ] }
        let(:extractions) { { test_stream: mock("extraction", name: "test_stream", extract: test_stream )}}

        it "should raise TypeError" do
          lambda { transform.transform(test_stream) }.should raise_error(TypeError)
        end
      end
    end
  end

  describe "with Proc options" do
    let(:transform) { TestTransform.new :test, {
        extraction: :test_stream,
        transform: { id: :src_id, name: :src_name },
        transform_collection: ->{ Array.new },
        transform_class:  ->(row) { Hash.new },
        extract_attribute:  ->(object, attribute) { object[attribute] },
        apply_attribute: ->(object, attribute, value) { object[attribute] = value },
        final_class: Set,
        finalize_object: ->(object) { object.to_a },
        store_transformed_object: ->(object, collection) { collection << object }
      }
    }

    let(:test_stream) { [{src_id: 42, src_name: "Alice"}, {src_id: 43, src_name: "Bob"} ] }
    let(:extractions) { { test_stream: mock("extraction", name: "test_stream", extract: test_stream )}}

    before do
      TestTransform.stub!(:extractions).and_return(extractions)
    end

    it "should delegate to procs" do
      transform.transform(test_stream).should == [
        Set.new([[:id, 42], [:name, "Alice"]]),
        Set.new([[:id, 43], [:name, "Bob"]])
      ]
    end
  end

  describe "with symbol and class options" do
    let(:transform) { TestTransform.new :test, {
        extraction: :test_stream,
        transform: { id: :src_id, name: :src_name },
        transform_collection: Array,
        transform_class:  Hash,
        extract_attribute:  :[],
        apply_attribute: :[]=,
        store_transformed_object: :<<
      }
    }

    let(:test_stream) { [{src_id: 42, src_name: "Alice"}, {src_id: 43, src_name: "Bob"} ] }
    let(:extractions) { { test_stream: mock("extraction", name: "test_stream", extract: test_stream )}}

    before do
      TestTransform.stub!(:extractions).and_return(extractions)
    end

    it "should delegate to procs" do
      transform.transform(test_stream).should == [
        {id: 42, name: "Alice"},
        {id: 43, name: "Bob"}
      ]
    end
  end
end

