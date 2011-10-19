require 'pathname'
require 'forwardable'
require 'logger'

module Migratrix
  APP=Pathname.new(__FILE__).dirname + "migratrix"
  EXT=Pathname.new(__FILE__).dirname + "patches"

  def self.default_migrations_path
    Rails.root + 'db/legacy'
  end

  require EXT + 'string_ext'
  require EXT + 'object_ext'
  require EXT + 'andand'
  require APP + 'loggable'
  require APP + 'exceptions'
  require APP + 'registry'
  require APP + 'migration'
  require APP + 'migratrix'

  require APP + 'extractors/extractor'
  require APP + 'extractors/active_record'

#  register_extractor :active_record, Migratrix::Migrations::ActiveRecord

  require APP + 'transforms/transform'
  require APP + 'transforms/map'


  include ::Migratrix::Loggable

  def self.migrate!(name, options={})
    ::Migratrix::Migratrix.migrate(name, options)
  end

  def self.create_migration(name, options={})
    ::Migratrix::Migratrix.create_migration(name, options)
  end

  def self.register_migration(name, klass, init_options={})
    ::Migratrix::Migratrix.register_migration(name, klass, init_options)
  end

  def self.reload_migration(name)
    ::Migratrix::Migratrix.reload_migration(name)
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
end

