# Main "App" or Driver class for Migrating. Responsible for loading
# and integrating all the parts of a migration.
module Migratrix
  class Migratrix
    include ::Migratrix::Loggable

    def initialize
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
      @logger = create_logger($stdout)
    end

    def self.logger
      @logger ||= self.init_logger
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end
    # ----------------------------------------------------------------------



    # ----------------------------------------------------------------------
    # Candidate for exract class? MigrationRegistry?
    def self.registry
      @registry ||= Hash[[:extractions,:loads,:migrations,:transforms].map {|key| [key, Registry.new]}]
    end

    # --------------------
    # extractions
    def self.extractions
      registry[:extractions]
    end

    def self.register_extraction(registered_name, klass, options={})
      self.extractions.register(registered_name, klass, options)
    end

    def self.extraction(nickname, registered_name, options={})
      self.extractions.class_for(registered_name).new(nickname, options)
    end
    # --------------------

    # --------------------
    # transforms
    def self.transforms
      registry[:transforms]
    end

    def self.register_transform(name, klass, options={})
      self.transforms.register(name, klass, options)
    end

    def self.transform(nickname, registered_name, options={})
      self.transforms.class_for(registered_name).new(nickname, options)
    end
    # --------------------

    # --------------------
    # loads
    def self.loads
      registry[:loads]
    end

    def self.register_load(name, klass, options={})
      self.loads.register(name, klass, options)
    end

    def self.load(nickname, registered_name, options={})
      self.loads.class_for(registered_name).new(nickname, options)
    end
    # --------------------

    # End MigrationRegistry
    # ----------------------------------------------------------------------
  end
end
