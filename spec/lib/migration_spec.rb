require 'spec_helper'

# This migration is embedded in migration_spec.rb to allow testing of
# the class methods that specialize subclasses.
class Migratrix::TestMigration < Migratrix::Migration

end

describe Migratrix::Migration do
  describe ".new" do
    it "does not modify given options hash" do
      conditions = ["id=? AND approved=?", 42, true]
      migration = Migratrix::TestMigration.new({ "where" => conditions })

      migration.options["where"][0] += " AND pants=?"
      migration.options["where"] << false
      migration.options["where"].should == ["id=? AND approved=? AND pants=?", 42, true, false]
      conditions.should == ["id=? AND approved=?", 42, true]
    end
  end
end



