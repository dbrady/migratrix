module Migratrix
  module Transforms
    # A Transform object that does nothing. Useful for plugging into a
    # Migration when you need to debug other parts of the migration
    class NoOp < Transform
      def transform(extracted_items, options={})
        []
      end
    end
  end
end
