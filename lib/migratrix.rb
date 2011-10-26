require 'pathname'
require 'forwardable'
require 'logger'

module Migratrix
  APP=Pathname.new(__FILE__).dirname + "migratrix"
  EXT=Pathname.new(__FILE__).dirname + "patches"

  require EXT + 'string_ext'
  require EXT + 'object_ext'
  require EXT + 'andand'
  require APP + 'exceptions'

  require APP + 'callbacks'
  require APP + 'loggable'
  require APP + 'migration_strategy'
  require APP + 'valid_options'
  require APP + 'registry'
  require APP + 'migration'
  require APP + 'migratrix'

  require APP + 'extractions/extraction'
  require APP + 'extractions/no_op'
  require APP + 'extractions/active_record'

  require APP + 'transforms/transform'
  require APP + 'transforms/no_op'
  require APP + 'transforms/map'

  require APP + 'loads/load'
  require APP + 'loads/no_op'
  require APP + 'loads/yaml'
#  require APP + 'loads/csv'
#  require APP + 'loads/active_record'


  include ::Migratrix::Loggable

  def self.register_extraction(name, klass, init_options={})
    ::Migratrix::Migratrix.register_extraction(name, klass, init_options)
  end

  def self.extractions
    ::Migratrix::Migratrix.extractions
  end

  def self.register_transform(name, klass, init_options={})
    ::Migratrix::Migratrix.register_transform(name, klass, init_options)
  end

  def self.transforms
    ::Migratrix::Migratrix.transforms
  end

  def self.register_load(name, klass, init_options={})
    ::Migratrix::Migratrix.register_load(name, klass, init_options)
  end

  def self.loads
    ::Migratrix::Migratrix.loads
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
  register_extraction :extraction, Extractions::Extraction
  register_extraction :active_record, Extractions::ActiveRecord
  register_extraction :no_op, Extractions::NoOp

  register_transform :transform, Transforms::Transform
  register_transform :no_op, Transforms::NoOp
  register_transform :map, Transforms::Map

  register_load :load, Loads::Load
  register_load :no_op, Loads::NoOp
  register_load :yaml, Loads::Yaml

end

