if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

require 'pathname'
require 'ruby-debug'
require 'rails'
require 'timecop'
require 'logger'
require 'active_support/concern'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
SPEC = Pathname.new(__FILE__).dirname
ROOT = SPEC + ".."
LIB = ROOT + "lib"

# Rails is loaded but not actually started. Let's keep it that way as
# much as possible. But we DO need Rails.root, so:
module Rails
  def self.root
    ROOT
  end
end

Dir[SPEC + "support/**/*.rb"].each {|f| require f}

require LIB + 'migratrix'

# Migatrix loads Migration classes into its namespace. In order to
# test collision prevention, I needed to reach into Migratrix and
# mindwipe it of any migrations. Here's the shiv to do that. I
# originally put an API to do this on Migratrix but these specs are
# the only clients of it so I removed it again. If you find a
# legitimate use for it, feel free to re-add a remove_migration
# method and send me a patch.
def reset_migratrix!(migratrix)
  Migratrix.constants.map(&:to_s).select {|m| m =~ /.+Migration$/}.each do |migration|
    Migratrix.send(:remove_const, migration.to_sym)
  end
  migratrix.registered_migrations.clear

  # Also clear any class vars on base classes
  Migratrix::Migration.extractor = nil
end

# Redirect singleton logger to logger of our choice, then release it
# after the spec finishes or crashes.
def with_logger(logger, &block)
  begin
    old_logger = Migratrix::Migratrix.logger
    Migratrix::Migratrix.logger = logger
    yield
  ensure
    Migratrix::Migratrix.logger = old_logger
  end
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
end

