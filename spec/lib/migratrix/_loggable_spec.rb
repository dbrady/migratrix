require 'spec_helper'

# class SomeLoggableThing
#   include Migratrix::Loggable
# end

shared_examples_for "loggable" do
  # Your spec must define loggable and loggable_name!
  #  let(:loggable) { SomeLoggableThing.new }
  let(:loggable_name) { loggable.class }
  let(:buffer) { StringIO.new }
  let(:logger) { Migratrix::Migratrix.create_logger(buffer) }

  before do
    Timecop.freeze(Time.local(2011, 6, 28, 3, 14, 15))
  end

  after do
    Timecop.return
  end

  describe "your shared loggable specs" do
    it "must define let(:loggable) to somehting that includes Migratrix::Loggable" do
      loggable.class.ancestors.should include(Migratrix::Loggable)
    end
    it "must define let(:loggable_name) to the name of the class that will use the logger methods" do
      loggable_name.should_not be_nil
    end
  end

  describe "instance" do
    def spec_correct_instance_log_message(method)
      token = method.to_s.upcase[0]
      with_logger(logger) do
        loggable.send(method, "This is a test #{method} message")
      end
      buffer.string.should == "#{token} 2011-06-28 03:14:15: #{loggable_name}: This is a test #{method} message\n"
    end

    it "#logger can log" do
      with_logger(logger) do
        loggable.logger.info("This is a test")
      end
      buffer.string.should == "I 2011-06-28 03:14:15: This is a test\n"
    end

    describe "#info" do
      it "logs with class name" do
        with_logger(logger) do
          loggable.info("This is a test")
        end
        buffer.string.should == "I 2011-06-28 03:14:15: #{loggable_name}: This is a test\n"
      end
    end

    [:info, :debug, :warn, :error, :fatal].each do |log_level|
      describe ".#{log_level}" do
        it "logs #{log_level} message with class name" do
          spec_correct_instance_log_message log_level
        end
      end
    end
  end

  describe "class" do
    def spec_correct_class_log_message(method)
      token = method.to_s.upcase[0]
      with_logger(logger) do
        loggable.class.send(method, "This is a test #{method} message")
      end
      buffer.string.should == "#{token} 2011-06-28 03:14:15: #{loggable_name}: This is a test #{method} message\n"
    end

    it ".logger can log" do
      with_logger(logger) do
        loggable.class.logger.info("This is a test")
      end
      buffer.string.should == "I 2011-06-28 03:14:15: This is a test\n"
    end

    [:info, :debug, :warn, :error, :fatal].each do |log_level|
      describe ".#{log_level}" do
        it "logs #{log_level} message with class name" do
          spec_correct_class_log_message log_level
        end
      end
    end
  end

end
