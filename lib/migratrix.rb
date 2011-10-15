require 'pathname'
require 'forwardable'

module Migratrix
  APP=Pathname.new(__FILE__).dirname + "migratrix"
  EXT=Pathname.new(__FILE__).dirname + "patches"

  def self.default_migrations_path
    Rails.root + 'lib/migrations'
  end

  require EXT + 'string_ext'
  require EXT + 'object_ext'
  require EXT + 'andand'
  require APP + 'logger'
  require APP + 'loggable'
  require APP + 'exceptions'
  require APP + 'migration'
  require APP + 'migratrix'

end
