require 'pathname'

module Migratrix
  LIB=Pathname.new(__FILE__).dirname + "migratrix"
  EXT=Pathname.new(__FILE__).dirname + "patches"

  require EXT + 'string_ext'
  require EXT + 'object_ext'
  require EXT + 'andand'
  require LIB + 'exceptions'
  require LIB + 'migration'

  def self.migrate(name, options={})
    name = name.to_s
    migration = create_migration(name, options)
    migration.migrate
  end

  # Loads #{name}_migration.rb from migrations path, instantiates
  # #{Name}Migration with options, and returns it.
  def self.create_migration(name, options={})
    options = filter_options(options)
    klass_name = migration_name(name)
    unless loaded?(klass_name)
      raise MigrationAlreadyExists.new("Migratrix cannot instantiate class Migratrix::#{klass_name} because it already exists") if Migratrix.const_defined?(klass_name)
      filename = migrations_path + "#{name}_migration.rb"
      raise MigrationFileNotFound.new("Migratrix cannot find migration file #{filename}") unless File.exists?(filename)
      load filename
      raise MigrationNotDefined.new("Expected migration file #{filename} to define Migratrix::#{klass_name} but it did not") unless Migratrix.const_defined?(klass_name)
      register_migration(klass_name, "Migratrix::#{klass_name}".constantize)
      fetch_migration(klass_name).new(options)
    end
  end

  def self.migration_name(name)
    name = name.to_s
    name = if name.plural?
      name.classify.pluralize
    else
      name.classify
    end
    name + "Migration"
  end

  def self.filter_options(hash)
    Hash[valid_options.map {|v| hash.key?(v) ? [v, hash[v]] : nil }.compact]
  end

  def self.valid_options
    %w(limit where)
  end

  # ----------------------------------------------------------------------
  # Candidate for exract class? MigrationRegistry?
  def self.loaded?(name)
    registered_migrations.key? name.to_s
  end

  def self.register_migration(name, klass)
    registered_migrations[name.to_s] = klass
  end

  def self.fetch_migration(name)
    registered_migrations.fetch name.to_s
  end

  def self.registered_migrations
    @@registered_migrations ||= {}
  end
  # End MigrationRegistry
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # Migration path class accessors. Defaults to lib/migrations.
  def self.migrations_path
    @@migrations_path ||= Rails.root + 'lib/migrations'
  end

  def self.migrations_path=(new_path)
    @@migrations_path = Pathname.new new_path
  end
  # End Migration path management
  # ----------------------------------------------------------------------
end
