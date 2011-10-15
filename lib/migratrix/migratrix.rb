# Main "App" or Driver class for Migrating. Responsible for loading
# and integrating all the parts of a migration.

module Migratrix

  def migrate(name, options={})
    ::Migratrix::Migratrix.migrate(name, options)
  end

  class Migratrix
    def self.migrate(name, options={})
      migratrix = self.new()
      migration = migratrix.create_migration(name, options)
      migration.migrate
      migratrix
    end

    # Loads #{name}_migration.rb from migrations path, instantiates
    # #{Name}Migration with options, and returns it.
    def create_migration(name, options={})
      options = filter_options(options)
      klass_name = migration_name(name)
      unless loaded?(klass_name)
        raise MigrationAlreadyExists.new("Migratrix cannot instantiate class Migratrix::#{klass_name} because it already exists") if ::Migratrix.const_defined?(klass_name)
        filename = migrations_path + "#{name}_migration.rb"
        raise MigrationFileNotFound.new("Migratrix cannot find migration file #{filename}") unless File.exists?(filename)
        load filename
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

    def filter_options(hash)
      Hash[valid_options.map {|v| hash.key?(v) ? [v, hash[v]] : nil }.compact]
    end

    def valid_options
      %w(limit where logger)
    end

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
      @registered_migrations ||= {}
    end
    # End MigrationRegistry
    # ----------------------------------------------------------------------

    # ----------------------------------------------------------------------
    # Migration path class accessors. Defaults to lib/migrations.
    def migrations_path
      @migrations_path ||= ::Migratrix.default_migrations_path
    end

    def migrations_path=(new_path)
      @migrations_path = Pathname.new new_path
    end

#     def self.migrations_path
#       @@migrations_path ||= ::Migratrix::DEFAULT_MIGRATIONS_PATH
#     end

#     def self.migrations_path=(new_path)
#       @@migrations_path = Pathname.new new_path
#     end
    # End Migration path management
    # ----------------------------------------------------------------------

#     def self.log(msg="", level=:info)
#       return if quiet
#       level = :info unless level.in? [:debug, :info, :warn, :error, :fatal, :unknown]
#       logger.send level, "#{Time.now.strftime('%T')}: #{msg}"
#     end
  end
end
