module Migratrix
  module Extractions
    # An Extraction object that does nothing. Useful for plugging into
    # a Migration when you need to debug other parts of the migration
    class NoOp < Extraction
      def extract(options={})
        []
      end
    end
  end
end
