require 'active_model/attribute_methods'

module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    include Migratrix::Loggable
    include ActiveModel::AttributeMethods
    include Migratrix::ValidOptions
    include Migratrix::MigrationStrategy
    include Migratrix::Callbacks

    attr_accessor :options
    set_valid_options :console

    def initialize(options={})
      @options = options.deep_copy.symbolize_keys
      Migratrix.log_to($stdout) if @options[:console]
    end

    # TODO: Technically, we need to ask our extractions, transformers
    # and loaders for THEIR valid options as well. limit, offset,
    # order and where are all extraction-only options, and fetchall is
    # an ActiveRecord-specific option
    def self.valid_options
      opts = super # wacky, I know, but the extended ValidOptions module is in the super chain. (I <3 Ruby)
      if extractions
        extractions.each do |name, extraction|
          opts += extraction.valid_options
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

    # TODO: THIS IS HUGE DUPLICATION, REFACTOR REFACTOR REFACTOR

    # extraction crap
    def self.set_extraction(extraction_name, class_name, options={})
      extractions[extraction_name] = Migratrix.extraction(class_name, extraction_name, options)
    end

    def self.extend_extraction(extraction_name, options={})
      migration = ancestors.detect {|k| k.respond_to?(:extractions) && k.extractions[extraction_name]}
      raise ExtractionNotDefined.new("Could not extend extractar '%s'; no parent Migration defines it" % extraction_name) unless migration
      extraction = migration.extractions[extraction_name]
      extractions[extraction_name] = extraction.class.new(extraction_name, extraction.options.merge(options))
    end

    def self.extractions
      @extractions ||= {}
    end

    def extractions
      self.class.extractions
    end

    # transform crap
    def self.set_transform(name, type, options={})
      transforms[name] = Migratrix.transform(name, type, options)
    end

    def self.extend_transform(transform_name, options={})
      migration = ancestors.detect {|k| k.respond_to?(:transforms) && k.transforms[transform_name]}
      raise TransformNotDefined.new("Could not extend extractar '%s'; no parent Migration defines it" % transform_name) unless migration
      transform = migration.transforms[transform_name]
      transforms[transform_name] = transform.class.new(transform_name, transform.options.merge(options))
    end

    def self.transforms
      @transforms ||= {}
    end

    def transforms
      self.class.transforms
    end

    # load crap
    def self.set_load(name, type, options={})
      loads[name] = Migratrix.load(name, type, options)
    end

    def self.extend_load(load_name, options={})
      migration = ancestors.detect {|k| k.respond_to?(:loads) && k.loads[load_name]}
      raise LoadNotDefined.new("Could not extend extractar '%s'; no parent Migration defines it" % load_name) unless migration
      load = migration.loads[load_name]
      loads[load_name] = load.class.new(load_name, load.options.merge(options))
    end

    def self.loads
      @loads ||= {}
    end

    def loads
      self.class.loads
    end
  end
end

