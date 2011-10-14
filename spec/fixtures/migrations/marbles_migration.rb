# Fake migrator
module Migratrix
  class MarblesMigration < Migratrix::Migration
    def initialize(options={})
      super
      @@migrated = false
    end

    def migrate
      @@migrated = true
    end

    def self.migrated?
      @@migrated
    end
  end
end
