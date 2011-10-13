module Migratrix
  # Superclass for all migrators. Migratrix COULD check to see that a
  # loaded migrator inherits from this class, but hey, duck typing.
  class Migrator
    attr_accessor :options, :logger

    def initialize(options={})
      @options = options
    end

    def migrate!
      raise NotImplementedError.new("superclass Migratrix::Migrator.migrate! does not have a default strategy (yet?)")
    end

    def execute(query, msg=nil)
      log(msg || query) unless msg == false
      ActiveRecord::Base.connection.execute query
    end

    # DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    #  DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGE
    # R DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANG
    # ER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DAN
    #
    # THIS IS MySQL SPECIFIC! Please specialize this into a subclass
    # and then write the equivalent PostGreSQL, sqlite3, etc, e.g. for
    # PostGreSQL prior to v8.3, you have to delete everything in the
    # table and then alter its sequence to reset its next id to 1.
    #
    # PS psql_truncate has been added. Leaving the above comment
    # because a) this stil needs to be moved out of this class and b)
    # the warning about different adapters is still generally
    # relevant.
    #
    # GER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DA
    # NGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER D
    # ANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    # DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    def mysql_truncate(table)
      execute("TRUNCATE #{table}")
    end

    # DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    #  DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGE
    # R DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANG
    # ER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DAN
    #
    # THIS IS PostGreSQL SPECIFIC! Please specialize this into a
    # subclass.
    #
    # GER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DA
    # NGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER D
    # ANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    # DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    #
    # Note: TRUNCATE was added to PostGreSQL in version 8.3, which is
    # still poorly adopted. This code works on earlier versions, and
    # is MVCC-safe. It does NOT, however, actually look up the table's
    # sequence definition. It assumes the sequence for a is named
    # a_id_seq and that it should be reset to 1. (A tiny dash of extra
    # cleverness is all that would be needed to read start_value from
    # the sequence, but for now this is a pure-SQL, stateless call.)
    def psql_truncate(table)
      execute("DELETE FROM #{table}; ALTER SEQUENCE #{table}_id_seq RESTART WITH 1")
    end

    # Disables indexes on a table and locks it for writing, optionally
    # read-locks another list of tables, then yields to the given
    # block before unlocking. This prevents MySQL from indexing the
    # migrated data until the block is complete. This produces a
    # significant speedup on InnoDB tables with multiple indexes. (The
    # plural of anecdote is not data, but on one heavily-indexed
    # table, migrating 10 million records took 38 hours with indexes
    # enabled and under 2 hours with them disabled.)
    #
    # DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    #  DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGE
    # R DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANG
    # ER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DAN
    #
    # THIS IS MySQL SPECIFIC! Please specialize this into a subclass.
    # And then write the equivalent PostGreSQL, which may be tricky
    # because PostGreSQL locks tables quite differently, notably
    #
    # * Multi-table locks are not atomic. LOCK a,b is equivalent to
    # LOCK a; LOCK b; so always remember to lock your tables in the
    # same order as everyone who ever has or will lock tables in your
    # database, lest a race condition (along with wacky hijinks) ensue
    #
    # * There is no UNLOCK TABLE command. Locks unlock automatically
    # at the end of the transaction
    #
    # * Locks ONLY work within transactions. I recommend agaist using
    # this mechanism inside an ActiveRecord migrator without first
    # really understanding the deep internals of how ActiveRecord uses
    # transactions.
    #
    # * Keep in mind that this method was written to optimize bulk
    # inserts on heavily-indexed tables in MySQL. I have no numbers to
    # support that this is useful or even a good idea in PostGreSQL or
    # any other database adapter.
    #
    # * See http://www.postgresql.org/docs/8.1/static/sql-lock.html
    #
    # * Oh yeah Sqlite3 says screw this garbage too
    #
    # GER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DA
    # NGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER D
    # ANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    # DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER DANGER
    def with_mysql_indexes_disabled_on(table, *read_locked_tables, &block)
      log "Locking table '#{table}' and disabling indexes..."
      lock_cmd = "LOCK TABLES `#{table}` WRITE"
      if read_locked_tables.andand.size > 0
        lock_cmd += ', ' + (read_locked_tables.map {|t| "#{t} READ"} * ", ")
      end
      execute lock_cmd
      execute("/*!40000 ALTER TABLE `#{table}` DISABLE KEYS */")
      yield
      log "Unlocking table '#{table}' and re-enabling indexes..."
      execute("/*!40000 ALTER TABLE `#{table}` ENABLE KEYS */")
      execute("UNLOCK TABLES")
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
