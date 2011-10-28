module Migratrix
  module Extractions
    # Extraction that expects to be pointed at an ActiveRecord class.
    class ActiveRecord < Extraction
      set_valid_options :fetchall, :includes, :joins

      def source=(new_source)
        raise TypeError.new(":source is of type must be an ActiveRecord model class (must inherit from ActiveRecord::Base)") unless is_ar?(new_source)
        @source = new_source
      end

      def is_ar?(source)
        source.is_a?(Class) && source.ancestors.include?(::ActiveRecord::Base)
      end

      def obtain_source(source, options={})
        raise ExtractionSourceUndefined unless source
        source
      end

      def process_source(source, options={})
        source = super
        source = handle_joins(source, options[:joins]) if options[:joins]
        source = handle_includes(source, options[:includes]) if options[:includes]
        source
      end

      def handle_joins(source, clause)
        source.joins(clause)
      end

      def handle_includes(source, clause)
        source.includes(clause)
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
        source = process_source(obtain_source(source))
        if source.respond_to? :to_sql
          source.to_sql
        else
          handle_where(source, 1).to_sql
        end
      end

      def execute_extract(src, options={})
        return src.all if options['fetchall']
        ret = if src.respond_to? :to_sql
                src
              else
                handle_where(src, 1)
              end
      end
    end
  end
end

