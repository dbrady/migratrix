require 'pathname'

module Migratrix
  LIB=Pathname.new(__FILE__).dirname + "migratrix"
  EXT=Pathname.new(__FILE__).dirname + "patches"

  require EXT + 'string_ext'
  require EXT + 'object_ext'
  require EXT + 'andand'
  require LIB + 'exceptions'
  require LIB + 'migrator'

  def self.migrate!(name, options={})
    name = name.to_s
    migrator = create_migrator(name, options)
    migrator.migrate!
  end

  # Loads #{name}_migrator.rb from migrators path, instantiates
  # #{Name}Migrator with options, and returns it.
  def self.create_migrator(name, options={})
    options = filter_options(options)
    klass_name = migrator_name(name)
    unless loaded?(klass_name)
      raise MigratorAlreadyExists.new("Migratrix cannot instantiate class Migratrix::#{klass_name} because it already exists") if Migratrix.const_defined?(klass_name)
      filename = migrators_path + "#{name}_migrator.rb"
      raise MigratorFileNotFound.new("Migratrix cannot find migrator file #{filename}") unless File.exists?(filename)
      load filename
      raise MigratorNotDefined.new("Expected migrator file #{filename} to define Migratrix::#{klass_name} but it did not") unless Migratrix.const_defined?(klass_name)
      register_migrator(klass_name, "Migratrix::#{klass_name}".constantize)
      fetch_migrator(klass_name).new(options)
    end
  end

  def self.migrator_name(name)
    name = name.to_s
    name = if name.plural?
      name.classify.pluralize
    else
      name.classify
    end
    name + "Migrator"
  end

  def self.filter_options(hash)
    Hash[valid_options.map {|v| hash.key?(v) ? [v, hash[v]] : nil }.compact]
  end

  def self.valid_options
    %w(limit where)
  end

  # ----------------------------------------------------------------------
  # Candidate for exract class? MigratorRegistry?
  def self.loaded?(name)
    migrator_classes.key? name.to_s
  end

  def self.register_migrator(name, klass)
    migrator_classes[name.to_s] = klass
  end

  def self.fetch_migrator(name)
    migrator_classes.fetch name.to_s
  end

  def self.migrator_classes
    @@migrator_classes ||= {}
  end

  def self.remove_migrator(name)
    name = name.to_s
    klass = migrator_classes.delete(name)
    remove_const name.to_sym
  end
  # End MigratorRegistry
  # ----------------------------------------------------------------------


  # ----------------------------------------------------------------------
  # Migrator path class accessors. Defaults to lib/migrators.
  def self.migrators_path
    @@migrators_path ||= ::Rails.root + 'lib/migrators'
  end

  def self.migrators_path=(new_path)
    @@migrators_path = Pathname.new new_path
  end
  # End Migrator path management
  # ----------------------------------------------------------------------
end
