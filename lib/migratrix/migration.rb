module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    include ::Migratrix::Loggable
    extend ::Migratrix::Loggable::ClassMethods

    attr_accessor :options

    def initialize(options={})
      # cannot make a deep copy of an IO stream (e.g. logger) so make a shallow copy of it and move it out of the way
      @options = options.deep_copy
    end

    # Load this data from source
    def extract
      # run the chain of extractions
    end

    # Transforms source data into outputs
    def transform
      # run the chain of transforms
    end

    # Saves the migrated data by "loading" it into our database or
    # other data sink.
    def load
      # run the chain of loads
    end

    # Perform the migration
    def migrate
      extract
      transform
      load
    end
  end
end

