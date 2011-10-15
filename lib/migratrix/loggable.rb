module Migratrix
  module Loggable
    module ClassMethods
      def logger
        ::Migratrix::Logger.logger
      end
    end

    def logger
      ::Migratrix::Logger.logger
    end

  end
end
