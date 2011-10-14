if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

require 'pathname'
require 'ruby-debug'
require 'rails'

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

