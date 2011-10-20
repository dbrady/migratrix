module Migratrix
  module Transforms
    # Map is a transform that maps attributes from the source object
    # to the target object.
    #
    # :transform: a hash with dst => src keys, where dst is an
    # attribute on the transformed target object and src is either an
    # attribute on the source object or a Proc that receives the
    # entire extracted row and returns a value to be set.
    #
    # TODO: Right now map makes a lot of hard-coded assumptions as a
    # result of the primary test case. Notably that target is a Hash,
    # final class is a Hash keyed by transformed_object[:id], etc.
    #
    # TODO: Figure out how to do both of these strategies with Map:
    #
    # # Create object and then modify it sequentially
    # new_object = target.new
    # map.each do |dst, src|
    #   new_object[dst] = extracted_item[src]
    # end
    #
    # # Build up creation params and then new the object
    # hash = Hash.new
    # map.each do [dst, src]
    #   hash[dst] = extracted_item[src]
    # end
    # new_object = target.new(hash)
    class Map < Transform
      attr_accessor :map

      def initialize(name, options={})
        super
      end

      def create_transformed_collection
        Hash.new
      end

      def create_new_object(extracted_row)
        Hash.new
      end

      def apply_attribute(object, attribute_or_apply, value)
        object[attribute_or_apply] = value
      end

      def extract_attribute(object, attribute_or_extract)
        object[attribute_or_extract]
      end

      def store_transformed_object(object, collection)
        collection[object[:id]] = object
      end
    end
  end
end
