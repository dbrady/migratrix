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
    # :target: is the class of the target object.
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

      def initialize(options={})
        super
        @map = @options[:map]
      end
    end
  end
end
