module Migratrix
  # Fake migration fixture for "Marbles"
  class MarblesMigration < Migration
    # :nocov: # because we play some games with file loading/unloading, SimpleCov often misses lines in this file
    def initialize(options={})
      super
      @migrated = false
    end

    def migrate
      @migrated = true
    end

    def migrated?
      @migrated
    end
    # :nocov:
  end
end
