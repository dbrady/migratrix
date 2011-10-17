# Main "App" or Driver class for Migrating. Responsible for loading
# and integrating all the parts of a migration.
module Migratrix
  include ::Migratrix::Loggable

  def self.migrate!(name, options={})
    ::Migratrix::Migratrix.migrate(name, options)
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

  class Migratrix
    include ::Migratrix::Loggable

    def initialize
    end

    def self.migrate(name, options={})
      migratrix = self.new()
      ::Migratrix::Migratrix.log_to($stdout) if options['console']
      migration = migratrix.create_migration(name, options)
      migration.migrate
      migratrix
    end

    # Loads #{name}_migration.rb from migrations path, instantiates
    # #{Name}Migration with options, and returns it.
    def create_migration(name, options={})
      options = options.deep_copy
      klass_name = migration_name(name)
      unless loaded?(klass_name)
        raise MigrationAlreadyExists.new("Migratrix cannot instantiate class Migratrix::#{klass_name} because it already exists") if ::Migratrix.const_defined?(klass_name)
        reload_migration name
        raise MigrationNotDefined.new("Expected migration file #{filename} to define Migratrix::#{klass_name} but it did not") unless ::Migratrix.const_defined?(klass_name)
        register_migration(klass_name, "Migratrix::#{klass_name}".constantize)
      end
      fetch_migration(klass_name).new(options)
    end

    def migration_name(name)
      name = name.to_s
      name = if name.plural?
               name.classify.pluralize
             else
               name.classify
             end
      name + "Migration"
    end

    def reload_migration(name)
      filename = migrations_path + "#{name}_migration.rb"
      raise MigrationFileNotFound.new("Migratrix cannot find migration file #{filename}") unless File.exists?(filename)
      load filename
    end

    # ----------------------------------------------------------------------
    # Logger singleton; tries to hook into Rails.logger if it exists (it
    # won't if you log anything during startup because Migratrix is
    # loaded before Rails). To fix this, after rails start up call
    # Migratrix::Migratrix.logger = Rails.logger
    def self.create_logger(stream)
      logger = Logger.new(stream)
      logger.formatter = proc { |severity, datetime, progname, msg|
        "#{severity[0]} #{datetime.strftime('%F %H:%M:%S')}: #{msg}\n"
      }
      logger
    end

    def self.log_to(stream)
      self.logger = self.create_logger(stream)
    end

    def self.init_logger
      return Rails.logger if Rails.logger
      @@logger = create_logger($stdout)
    end

    def self.logger
      @@logger ||= self.init_logger
    end

    def self.logger=(new_logger)
      @@logger = new_logger
    end
    # ----------------------------------------------------------------------



    # ----------------------------------------------------------------------
    # Candidate for exract class? MigrationRegistry?
    def loaded?(name)
      registered_migrations.key? name.to_s
    end

    def register_migration(name, klass)
      registered_migrations[name.to_s] = klass
    end

    def fetch_migration(name)
      registered_migrations.fetch name.to_s
    end

    def registered_migrations
      @@registered_migrations ||= {}
    end
    # End MigrationRegistry
    # ----------------------------------------------------------------------

    def migrations_path
      @migrations_path ||= ::Migratrix.default_migrations_path
    end

    def migrations_path=(new_path)
      @migrations_path = Pathname.new new_path
    end
  end
end
