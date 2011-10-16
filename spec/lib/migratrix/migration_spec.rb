require 'spec_helper'

# This migration is embedded in migration_spec.rb to allow testing of
# the class methods that specialize subclasses.
class Migratrix::TestMigration < Migratrix::Migration
end

describe Migratrix::Migration do
  let(:migration) { Migratrix::TestMigration.new }
  let(:loggable) { Migratrix::TestMigration.new }
  it_should_behave_like "loggable"

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

  describe "#migrate" do
    it "delegates to extract, transform, and load" do
      migration.should_receive(:extract).once
      migration.should_receive(:transform).once
      migration.should_receive(:load).once
      migration.migrate
    end
  end
end


