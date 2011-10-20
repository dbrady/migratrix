module Migratrix
  module Extractors
    # Extractor that expects to be pointed at an ActiveRecord class.
    class ActiveRecord < Extractor
      set_valid_options :fetchall

      def source=(new_source)
        raise TypeError.new(":source is of type must be an ActiveRecord model class (must inherit from ActiveRecord::Base)") unless is_ar?(new_source)
        @source = new_source
      end

      def is_ar?(source)
        source.is_a?(Class) && source.ancestors.include?(::ActiveRecord::Base)
      end

      def obtain_source(source, options={})
        raise ExtractorSourceUndefined unless source
        raise TypeError.new(":source is of type must be an ActiveRecord model class (must inherit from ActiveRecord::Base)") unless is_ar?(source)
        source
      end

      def handle_where(source, clause)
        source.where(clause)
      end

      def handle_limit(source, clause)
        source.limit(clause.to_i)
      end

      def handle_offset(source, clause)
        source.offset(clause.to_i)
      end

      def handle_order(source, clause)
        source.order(clause)
      end

      # Constructs the query
      def to_query(source)
        if source.is_a?(::ActiveRecord::Relation)
          source.to_sql
        else
          handle_where(source, 1).to_sql
        end
      end

      def execute_extract(src, options={})
        return src.all if options['fetchall']
        ret = if src.is_a?(::ActiveRecord::Relation)
                src
              else
                handle_where(src, 1)
              end
      end
    end
  end
end

