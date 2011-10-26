module Migratrix
  module Loads
    # A Load object that does nothing. Useful for plugging into a
    # Migration when you need to debug other parts of the migration
    class NoOp < Load
      def load(transformed_items, options={})
        []
      end
    end
  end
end
