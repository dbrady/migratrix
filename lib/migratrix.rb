require 'pathname'
require 'forwardable'
require 'logger'

module Migratrix
  APP=Pathname.new(__FILE__).dirname + "migratrix"
  EXT=Pathname.new(__FILE__).dirname + "patches"

  require EXT + 'string_ext'
  require EXT + 'object_ext'
  require EXT + 'andand'
  require APP + 'loggable'
  require APP + 'valid_options'
  require APP + 'exceptions'
  require APP + 'registry'
  require APP + 'migration'
  require APP + 'migratrix'

  require APP + 'extractors/extractor'
  require APP + 'extractors/active_record'

  require APP + 'transforms/transform'
  require APP + 'transforms/map'


  include ::Migratrix::Loggable

  def self.register_extractor(name, klass, init_options={})
    ::Migratrix::Migratrix.register_extractor(name, klass, init_options)
  end

  def self.extractors
    ::Migratrix::Migratrix.extractors
  end

  def self.register_transform(name, klass, init_options={})
    ::Migratrix::Migratrix.register_transform(name, klass, init_options)
  end

  def self.transforms
    ::Migratrix::Migratrix.transforms
  end

  def self.logger
    ::Migratrix::Migratrix.logger
  end

  def self.logger=(new_logger)
    ::Migratrix::Migratrix.logger = new_logger
  end

  def self.log_to(stream)
    ::Migratrix::Migratrix.log_to(stream)
  end

  # ----------------------------------------------------------------------
  # Register in-gem Components
  register_extractor :active_record, Extractors::ActiveRecord

  register_transform :transform, Transforms::Transform
  register_transform :map, Transforms::Map
end

