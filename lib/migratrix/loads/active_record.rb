require 'yaml'

module Migratrix
  module Loads
    # An ActiveRecord-based Load that tries to update existing objects
    # rather than always doing new saves. If :update is true, before
    # saving we attempt to find the object by the primary_key column.
    # If found, we call .update_attributes on that record instead of
    # .save.
    #
    # TODO: Verify that update_attributes still calls callbacks, e.g.
    # validations and before_save? If not we'll need to load the
    # object, copy attributes manually from the transformed object,
    # and save it.
    #
    # TODO: primary_key is a bit presumptive. Would be better if it
    # were a where clause.
    class ActiveRecord < Load
      set_valid_options :primary_key, :legacy_key, :finder, :update, :cache_key

      def seen
        @seen ||= { }
      end

      def seen?(object)
        if options[:cache_key]
          seen[object[options[:cache_key]]]
        end
      end

      def seen!(object)
        if options[:cache_key]
          seen[object[options[:cache_key]]] = true
        end
      end

      def load(transformed_objects)
        transformed_objects.each do |transformed_object|
          next if seen?(transformed_object)
          if options[:update]
            object = if options[:finder]
                       options[:finder].call(transformed_object)
                     elsif options[:primary_key] && options[:legacy_key]
                       transformed_object.class.where("#{options[:primary_key]}=?", transformed_object[options[:legacy_key]]).first
                     end
            if object
              update_object object, transformed_object
            else
              save_object transformed_object
            end
          else
            save_object transformed_object
          end
        end
      end

      def save_object(transformed_object)
        return if seen?(transformed_object)
        transformed_object.save
        seen! transformed_object
        transformed_object
      end

      def update_object(original_object, transformed_object)
        return if seen?(transformed_object)
        original_object.update_attributes transformed_object.attributes
        seen! original_object
        original_object
      end
    end
  end
end
