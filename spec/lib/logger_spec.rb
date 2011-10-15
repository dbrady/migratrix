require 'spec_helper'

describe Migratrix::Logger do
  let(:logger) { Migratrix::Logger.logger }

  describe "sanity check kitty" do
    it "is sanity checked" do
      Migratrix::Logger.should_not be_nil
      Migratrix::Logger.class.should == Class
    end
  end

  describe "singleton-ness" do
    it "is singleton-y" do
      Migratrix::Logger.logger.class.should == Migratrix::Logger
    end

    it "cannot be new'ed" do
      lambda { Migratrix::Logger.new }.should raise_error(NoMethodError)
    end
  end

  describe "default" do
    it "logs to $stdout" do
      logger.stream == $stdout
    end
  end


  describe "logging" do
    let(:buffer) { StringIO.new }

    before do
      Timecop.freeze(Time.local(2011, 6, 28, 3, 14, 15))
    end

    after do
      Timecop.return
    end

    it "formats info message with level and timestamp" do
      with_logger_streaming_to(buffer) do
        logger.info("Test Message")
        buffer.string.should == "I 2011-06-28 03:14:15: Test Message\n"
      end
    end

    it "formats debug message with level and timestamp" do
      with_logger_streaming_to(buffer) do
        logger.debug("Test Message")
        buffer.string.should == "D 2011-06-28 03:14:15: Test Message\n"
      end
    end

    it "formats warning message with level and timestamp" do
      with_logger_streaming_to(buffer) do
        logger.warn("Test Message")
        buffer.string.should == "W 2011-06-28 03:14:15: Test Message\n"
      end
    end

    it "formats error message with level and timestamp" do
      with_logger_streaming_to(buffer) do
        logger.error("Test Message")
        buffer.string.should == "E 2011-06-28 03:14:15: Test Message\n"
      end
    end

    it "formats fatal message with level and timestamp" do
      with_logger_streaming_to(buffer) do
        logger.fatal("Test Message")
        buffer.string.should == "F 2011-06-28 03:14:15: Test Message\n"
      end
    end

    it "rejects messages below logger level" do
      with_logger_streaming_to(buffer, Migratrix::Logger::ERROR) do
        logger.info("Test Message")
        logger.debug("Test Message")
        logger.warn("Test Message")
        buffer.size.should == 0
        logger.error("Test Error")
        logger.fatal("Test Fatal")
        buffer.string.should == "E 2011-06-28 03:14:15: Test Error\nF 2011-06-28 03:14:15: Test Fatal\n"
      end
    end
  end

end
