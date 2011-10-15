require 'active_support/concern'
module Migratrix
  module Loggable
    extend ActiveSupport::Concern

    module ClassMethods
      def logger
        ::Migratrix::Migratrix.logger
      end
    end

    module InstanceMethods
      def logger
        ::Migratrix::Migratrix.logger
      end
    end
  end
end
