module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    attr_accessor :options, :logger

    def initialize(options={})
      @options = options.deep_copy
      # This should only be loaded if a) the Migration uses the AR
      # extract strategy and b) it's not already loaded
#      ::ActiveRecord::Base.send(:include, MigrationHelpers) unless ::ActiveRecord::Base.const_defined?("MigrationHelpers")
    end

    # Load this data from source
    def extract
      # run the chain of extractions
    end

    # Transforms source data into outputs
    def transform
      # run the chain of transforms
    end

    # Saves the migrated data by "loading" it into our database or
    # other data sink.
    def load
      # run the chain of loads
    end

    # Perform the migration
    def migrate
      extract
      transform
      load
    end

    def execute(query, msg=nil)
      log(msg || query) unless msg == false
      # TODO: this is bad, need to use specific connection at source
      ::ActiveRecord::Base.connection.execute query
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def log(msg="", level=:info)
      level = :info unless level.in? [:debug, :info, :warn, :error, :fatal, :unknown]
      logger.send level, "#{Time.now.strftime('%T')}: #{msg}"
    end
  end
end

