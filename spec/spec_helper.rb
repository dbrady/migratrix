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

require LIB + 'migratrix'
$:.unshift SPEC + "fixtures/migrations/"
$:.unshift SPEC + "fixtures/components/"

Dir[SPEC + "support/**/*.rb"].each {|f| require f}


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

def with_logging_to(stream, &block)
  begin
    old_logger = Migratrix::Migratrix.logger
    Migratrix::Migratrix.log_to stream
    yield
  ensure
    Migratrix::Migratrix.logger = old_logger
  end
end

RSpec.configure do |config|
  config.before(:each) do
    @test_logger_buffer = StringIO.new
    @test_logger = Migratrix::Migratrix.create_logger(@test_logger_buffer)
    Migratrix::Migratrix.init_logger
    Migratrix::Migratrix.logger = @test_logger

  end
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
end

