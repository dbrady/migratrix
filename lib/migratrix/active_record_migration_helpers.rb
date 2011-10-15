module Migratrix
  module ActiveRecordMigrationHelpers

    # Executes a query on this class' connection, and logs the query
    # or an optional message to Migratrix.log.
    def execute(query, msg=nil)
      Migratrix.log(msg || query) unless msg == false
      connection.execute query
    end

    # MySQL ONLY: truncates a table using TRUNCATE, which drops the
    # data very quickly and resets any autoindexing primary key to 1.
    def mysql_truncate(table)
      execute("TRUNCATE #{table}")
    end

    # PostGreSQL ONLY: truncates a table by deleting all its rows and
    # restarting its id sequence at 1.
    #
    # Note: TRUNCATE was added to PostGreSQL in version 8.3, which at
    # the time of this writing is still poorly adopted. This code
    # works on earlier versions, is MVCC-safe, and will trigger
    # cascading deletes.
    #
    # It does NOT, however, actually look up the table's sequence
    # definition. It assumes the sequence for a is named a_id_seq and
    # that it should be reset to 1. (A tiny dash of extra cleverness
    # is all that would be needed to read start_value from the
    # sequence, but for now this is a pure-SQL, stateless call.)
    def psql_truncate(table)
      execute("DELETE FROM #{table}; ALTER SEQUENCE #{table}_id_seq RESTART WITH 1")
    end

    # MySQL ONLY: Disables indexes on a table and locks it for
    # writing, optionally read-locks another list of tables, then
    # yields to the given block before unlocking. This prevents MySQL
    # from indexing the migrated data until the block is complete.
    # This produces a significant speedup on InnoDB tables with
    # multiple indexes. (The plural of anecdote is not data, but on
    # one heavily-indexed table, migrating 10 million records took 38
    # hours with indexes enabled and under 2 hours with them
    # disabled.)
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
  end
end
