module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    attr_accessor :options, :logger

    def initialize(options={})
      @options = options
    end

    def migrate
      # default strategy: vanilla ActiveRecord => ActiveRecord
      # TODO: Implement this with extract!, transform!, load!, and the
      # child class can either override this or one or more of the ETL
      # methods; ALSO need a setup/init/builder
      raise NotImplementedError.new("superclass Migratrix::Migration.migrate! does not have a default strategy (yet?)")
    end

    def execute(query, msg=nil)
      log(msg || query) unless msg == false
      # TODO: this is bad, need to use specific connection at source
#      ::ActiveRecord::Base.connection.execute query
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

