require 'spec_helper'

# class SomeLoggableThing
#   include Migratrix::Loggable
# end

shared_examples_for "loggable" do
#  let(:loggable) { SomeLoggableThing.new }
  let(:buffer) { StringIO.new }
  let(:logger) { Migratrix::Migratrix.create_logger(buffer) }

  before do
    Timecop.freeze(Time.local(2011, 6, 28, 3, 14, 15))
  end

  after do
    Timecop.return
  end

  it "is loggable" do
    loggable.class.ancestors.should include(Migratrix::Loggable)
  end

  describe "instance" do
    it "can log" do
      with_logger(logger) do
        loggable.logger.info("This is a test")
      end
      buffer.string.should == "I 2011-06-28 03:14:15: This is a test\n"
    end
  end
end
