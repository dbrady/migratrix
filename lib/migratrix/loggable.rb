require 'active_support/concern'
module Migratrix
  module Loggable
    extend ActiveSupport::Concern

    module ClassMethods
      def logger
        ::Migratrix::Migratrix.logger
      end
      # If you skip the logger object, your class name will be prepended to the message.
      def info(msg)
        logger.info("#{self}: #{msg}")
      end
      def debug(msg)
        logger.debug("#{self}: #{msg}")
      end
      def warn(msg)
        logger.warn("#{self}: #{msg}")
      end
      def error(msg)
        logger.error("#{self}: #{msg}")
      end
      def fatal(msg)
        logger.fatal("#{self}: #{msg}")
      end
    end

    module InstanceMethods
      def logger
        ::Migratrix::Migratrix.logger
      end

      # If you skip the logger object, your class name will be prepended to the message.
      def info(msg)
        logger.info("#{self.class}: #{msg}")
      end
      def debug(msg)
        logger.debug("#{self.class}: #{msg}")
      end
      def warn(msg)
        logger.warn("#{self.class}: #{msg}")
      end
      def error(msg)
        logger.error("#{self.class}: #{msg}")
      end
      def fatal(msg)
        logger.fatal("#{self.class}: #{msg}")
      end
    end
  end
end
