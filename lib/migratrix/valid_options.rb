require 'active_support/concern'
module Migratrix
  module ValidOptions
    extend ActiveSupport::Concern

    module ClassMethods
      def set_valid_options(*options)
        @local_valid_options = options.map(&:to_s).sort.map(&:to_sym)
      end

      def valid_options
        options = local_valid_options.dup
        options += self.ancestors.map {|klass| klass.local_valid_options rescue nil }.compact.flatten
        options.map(&:to_s).sort.uniq.map(&:to_sym)
      end

      def local_valid_options
        @local_valid_options ||= []
      end
    end
  end
end
