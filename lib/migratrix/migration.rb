require 'active_model/attribute_methods'

module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    include ::Migratrix::Loggable
    include ActiveModel::AttributeMethods
    include Migratrix::ValidOptions

    attr_accessor :options
    set_valid_options :console

    def initialize(options={})
      @options = options.deep_copy.symbolize_keys
      Migratrix.log_to($stdout) if @options[:console]
    end

    # TODO: Technically, we need to ask our extractor, transformers
    # and loaders for THEIR valid options as well. limit, offset,
    # order and where are all extractor-only options, and fetchall is
    # an ActiveRecord-specific option
    def self.valid_options
      opts = super # wacky, I know, but the extended ValidOptions module is in the super chain. (I <3 Ruby)
      if extractors
        extractors.each do |name, extractor|
          opts += extractor.valid_options
        end
      end
      if transforms
        transforms.each do |name, transform|
          opts += transform.valid_options
        end
      end
#       if loads
#         loads.each do |name, load|
#           opts += load.valid_options
#         end
#       end
      opts.uniq.sort
    end

    # Sets the extractor (unlike transform and load, which have
    # chains, there is only one Extractor per Migration)
    def self.set_extractor(extractor_name, class_name, options={})
      extractors[extractor_name] = Migratrix.extractor(class_name, extractor_name, options)
    end

    def self.extractors
      @extractors ||= {}
    end

    def extractors
      self.class.extractors
    end

    def self.set_transform(name, type, options={})
      transforms[name] = Migratrix.transform(name, type, options)
    end

    def self.transforms
      @transforms ||= {}
    end

    def transforms
      self.class.transforms
    end

    def self.set_load(name, type, options={})
      loads[name] = Migratrix.load(name, type, options)
    end

    def self.loads
      @loads ||= {}
    end

    def loads
      self.class.loads
    end

    def extract
      extracted_items = {}
      extractors.each do |name, extractor|
        extracted_items[name] = extractor.extract(options)
      end
      extracted_items
    end

    # Transforms source data into outputs. @transformed_items is a
    # hash of name => transformed_items.
    #
    def transform(extracted_items)
      transformed_items = { }
      transforms.each do |name, transform|
        transformed_items[transform.name] = transform.transform extracted_items[transform.extractor]
      end
      transformed_items
    end

    # Saves the migrated data by "loading" it into our database or
    # other data sink. Loaders have their own names, and by default
    # they depend on a transformed_items key of the same name, but you
    # may override this behavior by setting :source => :name or
    # possibly :source => [:name1, :name2, etc].
    def load(transformed_items)
      loaded_items = { }
      loads.each do |name, load|
        loaded_items[load.name] = load.load transformed_items[load.transform]
      end
      loaded_items
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
      # This fn || @var API lets you write a method and either set the
      # @var or return the value.
      @extracted_items = extract || @extracted_items
      @transformed_items = transform(@extracted_items) || @transformed_items
      load @transformed_items
    end
  end
end

