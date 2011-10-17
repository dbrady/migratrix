require 'active_model/attribute_methods'

module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    include ::Migratrix::Loggable
    include ActiveModel::AttributeMethods

    cattr_accessor :extractor
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

    # FIXME: I think @@extractor is shared across ALL Migrator
    # subclasses, which is bad. Each migration subclass should get its
    # own Extractor class instance. Arg, may need some serious
    # metaprogramming dark magic here, because I don't want the user
    # to have to define "MealExtractor <
    # Migratrix::Extractors::ActiveRecord", I just want them to be
    # able to say set_extractor :active_record, :source => ... and get
    # a new ActiveRecord extractor class. Perhaps I need to do
    # something like Struct.new and return a new singleton class...

    # Sets the extractor (unlike
    # transform and load, which have chains, there is only one
    # Extractor per Migration)
    def self.set_extractor(name, options={})
      # TODO: crappy hack. set_extractor nil to clear the class variable. Consider removing, I think only the test suite needs this
      if name.nil?
        @@extractor = nil
        return
      end
      # TODO: use name to pick from list of extractors. Currently we only have the one.
      raise NotImplementedError.new("Migratrix currently only supports ActiveRecord extractor.") unless name == :active_record
      @@extractor = ::Migratrix::Extractors::ActiveRecord.new(options)
    end

    def extractor
      self.class.extractor
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

