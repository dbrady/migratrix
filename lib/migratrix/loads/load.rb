module Migratrix
  module Loads
    class Load
      include ::Migratrix::Loggable
      include ::Migratrix::ValidOptions

      attr_accessor :name, :options

      set_valid_options :transform

      def initialize(name, options={})
        @name = name
        @options = options.symbolize_keys
      end

      # Default strategy: call save() on every transformed_object.
      def load(transformed_objects)
        transformed_objects.each do |transformed_object|
          transformed_object.save
        end
      end

      # Name of the transform to use. If omitted, returns our name.
      def transform
        options[:transform] || name
      end


      # # Prepare for load. Here is where you might want to truncate
      # # database tables, clear out target files, etc.
      # def before_load
      #   raise NotImplementedError
      # end

      # # Clean up after load. If you opened a file pointer in
      # # before_load, now's a good time to close it.
      # # TODO: Use the active model hooks to do this
      # def after_load
      #   raise NotImplementedError
      # end
    end
  end
end
