require 'active_support/concern'
module Migratrix
  module Loggable
    extend ActiveSupport::Concern

    module ClassMethods
      def logger
        ::Migratrix::Logger.logger
      end
    end

    module InstanceMethods
      def logger
        ::Migratrix::Logger.logger
      end
    end
  end
end
