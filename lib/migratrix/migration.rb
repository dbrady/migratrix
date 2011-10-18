require 'active_model/attribute_methods'

module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    include ::Migratrix::Loggable
    include ActiveModel::AttributeMethods

    attr_accessor :options

    def initialize(options={})
      @options = filter_options(options.deep_copy)
    end

    def filter_options(hash)
      Hash[valid_options.map {|v| hash.key?(v) ? [v, hash[v]] : nil }.compact]
    end

    # TODO: Technically, we need to ask our extractor, transformers
    # and loaders for THEIR valid options as well. limit, offset,
    # order and where are all extractor-only options, and fetchall is
    # an ActiveRecord-specific option
    def valid_options
      opts = %w(console)
      opts += extractor.valid_options if extractor
      opts.sort
    end

    # Sets the extractor (unlike transform and load, which have
    # chains, there is only one Extractor per Migration)
    def self.set_extractor(name, options={})
      # TODO: use name to pick from list of extractors. Currently we only have the one.
      raise NotImplementedError.new("Migratrix currently only supports ActiveRecord extractor.") unless name == :active_record
      @extractor = ::Migratrix::Extractors::ActiveRecord.new(options)
    end

    def self.extractor=(name)
      # usually only used to clear out the extractor...
      if name
        self.set_extractor(name)
      else
        @extractor = nil
      end
    end

    def self.extractor
      @extractor
    end

    def extractor
      self.class.extractor
    end

    def self.set_transform(name, type, options={})
      @transforms ||= []
      transform = case type
                  when :map
                    ::Migratrix::Transforms::Map.new(name, options)
                  end
      @transforms << transform if transform
    end

    def self.transforms
      @transforms ||= []
    end

    def transforms
      self.class.transforms
    end

    # OKAY, NEW RULE: You get ONE Extractor per Migration. You're
    # allowed to have multiple transform/load chains to the
    # extraction, but extractors? ONE.

    # default extraction method; simply assigns @extractor.extract to
    # @extracted_items. If you override this method, you should
    # populate @extracted_items if you want the default transform
    # and/or load to work correctly.
    def extract
      extractor.extract(options)
    end

    # Transforms source data into outputs. @transformed_items is a
    # hash of name => transformed_items.
    #
    def transform
      # run the chain of transforms
    end

    # Saves the migrated data by "loading" it into our database or
    # other data sink. Loaders have their own names, and by default
    # they depend on a transformed_items key of the same name, but you
    # may override this behavior by setting :source => :name or
    # possibly :source => [:name1, :name2, etc].
    def load
      # run the chain of loads
    end

    # Perform the migration
    # TODO: turn this into a strategy object. This pattern migrates
    # everything in all one go, while the user may want to do a batch
    # strategy. YAGNI: Rails 3 lets us defer the querying until we get
    # to the transform step, and then it's batched for us under the
    # hood. ...assuming, of course, we change the ActiveRecord
    # extractor's execute_extract method to return source instead of
    # all, but now the
    def migrate
      @extracted_items = extract
      transform
      load
    end
  end
end

