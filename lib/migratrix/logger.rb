module Migratrix
  class Logger
    attr_accessor :level, :stream

    FATAL = 0
    ERROR = 1
    WARN = 2
    DEBUG = 3
    INFO = 4

    @@singleton_instance = new

    def self.logger
      @@singleton_instance
    end

    def self.set_logger(stream=$stdout, level=INFO)
      self.logger.stream=stream
      self.logger.level=level
    end

    def initialize(stream, level)
      @stream, @level = stream, level
    end

    def fatal(msg)
      log(msg, FATAL)
    end

    def error(msg)
      log(msg, ERROR)
    end

    def warn(msg)
      log(msg, WARN)
    end

    def debug(msg)
      log(msg, DEBUG)
    end

    def info(msg)
      log(msg, INFO)
    end

    def log(msg, level)
      if level <= @level
        @stream.puts "%c %s: %s" % ["FEWDI"[level], Time.now.strftime("%F %T"), msg]
        @stream.flush
      end
    end

    private_class_method :new
  end
end
