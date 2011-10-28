module Migratrix
  module Extractions
    # base class for extraction
    class Extraction
      include ::Migratrix::Loggable
      include ::Migratrix::ValidOptions

      attr_accessor :name, :source, :options

      set_valid_options :limit, :offset, :order, :where

      def initialize(name, options={})
        @options = options.deep_copy
        self.source = options[:source] if options[:source]
      end

      def extract(options={})
        options = options.deep_copy
        options[:where] = Array(options[:where]) + Array(@options[:where])
        options = @options.merge(options).symbolize_keys

        # TODO: Raise error if self.abstract? DANGER/NOTE that this is
        # the "default strategy" for extraction, and may need to be
        # extracted to a strategy object.

        src = obtain_source(self.source, options)
        src = process_source(src, options)
        execute_extract(src, options)
      end

      def process_source(source, options)
        if options[:where]
          options[:where].each do |where|
            source = handle_where(source, where)
          end
        end
        source = handle_order(source, options[:order]) if options[:order]
        source = handle_limit(source, options[:limit]) if options[:limit]
        source = handle_offset(source, options[:offset]) if options[:offset]
        source
      end

      # = extraction filter methods
      #
      # The handle_* methods receive a source and return a source and
      # must be chainable. For example, source might come in as an
      # ActiveRecord::Base class (or as an ActiveRecord::Relation),
      # and it will be returned as an ActiveRecord::Relation, which
      # will not be expanded into an actual resultset until the
      # execute_extract step is called. On the other hand, for a csv
      # reader, the first self.source call might read all the rows of
      # the table and hold them in memory, the where clause might
      # filter it, the order clause might sort it, and the
      # execute_extract might simply be a no-op returning the
      # processed results.

      # First step in extraction is to take the given source and turn
      # it into something that the filter chain can used. The
      # ActiveRecord extraction uses a legacy model class as its source
      # so it can simply return its source. A CSV or Yaml extraction
      # here might need to read the entire file contents and returns
      # the full, unfiltered data source.
      def obtain_source(source, options={})
        raise NotImplementedError
      end

      # Apply where clause to source, return new source.
      def handle_where(source, where)
        raise NotImplementedError
      end

      # Apply limit clause to source, return new source.
      def handle_limit(source, limit)
        raise NotImplementedError
      end

      # Apply offset clause to source, return new source.
      def handle_offset(source, offset)
        raise NotImplementedError
      end

      # Apply order clause to source, return new source.
      def handle_order(source, order)
        raise NotImplementedError
      end

      # Constructs the query, if applicable. May not exist or make
      # sense for non-SQL and/or non-ActiveRecord extractions.
      def to_query(source)
        raise NotImplementedError
      end

      # Execute the extraction and return the result set.
      def execute_extract(source, options={})
        raise NotImplementedError
      end
    end
  end
end
