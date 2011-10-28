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
    # set_extraction :nickname, :registered_name, options_hash
    # set_extraction :nickname, :registered_name # options = {}
    # set_extraction :registered_name, options_hash # nickname = :default
    # set_extraction :registered_name # nickname = :default, options={}
    def self.set_extraction(nickname, registered_name=nil, options=nil)
      # barf, seriously these args need some detangler.
      if registered_name.nil?
        nickname, registered_name, options = :default, nickname, {}
      elsif options.nil?
        if registered_name.is_a?(Hash)
          nickname, registered_name, options = :default, nickname, registered_name
        else
          nickname, registered_name, options = nickname, registered_name, {}
        end
      end
      extractions[nickname] = Migratrix.extraction(nickname, registered_name, options)
    end

    def self.extend_extraction(nickname, options=nil)
      nickname, options = :default, nickname if options.nil?
      migration = ancestors.detect {|k| k.respond_to?(:extractions) && k.extractions[nickname]}
      raise ExtractionNotDefined.new("Could not extend extraction '%s'; no parent Migration defines it" % nickname) unless migration
      extraction = migration.extractions[nickname]
      extractions[nickname] = extraction.class.new(nickname, extraction.options.merge(options))
    end

    def self.extractions
      @extractions ||= {}
      ancestry = ancestors.select {|klass| klass != self && klass.respond_to?(:extractions) }.reverse
      # take oldest ancestor and merge extractions forward
      ext = {}
      ancestry.each do |ancestor|
        ext = ext.merge(ancestor.extractions || {})
      end
      @extractions = ext.merge(@extractions)
    end

    def extractions
      self.class.extractions
    end

    # transform crap
    # set_transform :nickname, :registered_name, options_hash
    # set_transform :nickname, :registered_name # options = {}
    # set_transform :registered_name, options_hash # nickname = :default
    # set_transform :registered_name # nickname = :default, options={}
    def self.set_transform(nickname, registered_name=nil, options=nil)
      # barf, seriously these args need some detangler.
      if registered_name.nil?
        nickname, registered_name, options = :default, nickname, {}
      elsif options.nil?
        if registered_name.is_a?(Hash)
          nickname, registered_name, options = :default, nickname, registered_name
        else
          nickname, registered_name, options = nickname, registered_name, {}
        end
      end
      transforms[nickname] = Migratrix.transform(nickname, registered_name, options)
    end

    def self.extend_transform(nickname, options={})
      nickname, options = :default, nickname if options.nil?
      migration = ancestors.detect {|k| k.respond_to?(:transforms) && k.transforms[nickname]}
      raise TransformNotDefined.new("Could not extend extractar '%s'; no parent Migration defines it" % nickname) unless migration
      transform = migration.transforms[nickname]
      transforms[nickname] = transform.class.new(nickname, transform.options.merge(options))
    end

    def self.transforms
      @transforms ||= {}
      ancestry = ancestors.select {|klass| klass != self && klass.respond_to?(:transforms) }.reverse
      # take oldest ancestor and merge transforms forward
      ext = {}
      ancestry.each do |ancestor|
        ext = ext.merge(ancestor.transforms || {})
      end
      @transforms = ext.merge(@transforms)
    end

    def transforms
      self.class.transforms
    end

    # load crap
    # set_load :nickname, :registered_name, options_hash
    # set_load :nickname, :registered_name # options = {}
    # set_load :registered_name, options_hash # nickname = :default
    # set_load :registered_name # nickname = :default, options={}
    def self.set_load(nickname, registered_name=nil, options=nil)
      # barf, seriously these args need some detangler.
      if registered_name.nil?
        nickname, registered_name, options = :default, nickname, {}
      elsif options.nil?
        if registered_name.is_a?(Hash)
          nickname, registered_name, options = :default, nickname, registered_name
        else
          nickname, registered_name, options = nickname, registered_name, {}
        end
      end
      loads[nickname] = Migratrix.load(nickname, registered_name, options)
    end

#     def self.set_load(name, type, options={})
#       loads[name] = Migratrix.load(name, type, options)
#     end

    def self.extend_load(nickname, options={})
      nickname, options = :default, nickname if options.nil?
      migration = ancestors.detect {|k| k.respond_to?(:loads) && k.loads[nickname]}
      raise LoadNotDefined.new("Could not extend extractar '%s'; no parent Migration defines it" % nickname) unless migration
      load = migration.loads[nickname]
      loads[nickname] = load.class.new(nickname, load.options.merge(options))
    end

    def self.loads
      @loads ||= {}
      ancestry = ancestors.select {|klass| klass != self && klass.respond_to?(:loads) }.reverse
      # take oldest ancestor and merge loads forward
      ext = {}
      ancestry.each do |ancestor|
        ext = ext.merge(ancestor.loads || {})
      end
      @loads = ext.merge(@loads)
    end

    def loads
      self.class.loads
    end
  end
end

