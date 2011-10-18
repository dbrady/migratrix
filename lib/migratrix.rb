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
  require APP + 'migration'
  require APP + 'migratrix'

  require APP + 'extractors/extractor'
  require APP + 'extractors/active_record'

  require APP + 'transforms/transform'
  require APP + 'transforms/map'
end

