#require 'active_model/attribute_methods'

module Migratrix
  module Extractors
    # base class for extraction
    class Extractor
      include ::Migratrix::Loggable
#      include ActiveModel::AttributeMethods

      attr_accessor :source, :options

      def initialize(options={})
        @options = options.deep_copy
        self.source = options[:source] if options[:source]
      end

      def extract(options={})
        options = @options.merge(options)

        # TODO: Raise error if self.abstract? DANGER/NOTE that this is
        # the "default strategy" for extraction, and may need to be
        # extracted to a strategy object.

        src = obtain_source(self.source)
        src = handle_where(src, options["where"]) if options["where"]
        src = handle_order(src, options["order"]) if options["order"]
        src = handle_limit(src, options["limit"]) if options["limit"]
        src = handle_offset(src, options["offset"]) if options["offset"]
        execute_extract(src)
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
      # ActiveRecord extractor uses a legacy model class as its source
      # so it can simply return its source. A CSV or Yaml extractor
      # here might need to read the entire file contents and returns
      # the full, unfiltered data source.
      def obtain_source(source)
        raise NotImplementedError
      end

      # Apply where clause to source, return new source.
      def handle_where(source)
        raise NotImplementedError
      end

      # Apply limit clause to source, return new source.
      def handle_limit(source)
        raise NotImplementedError
      end

      # Apply offset clause to source, return new source.
      def handle_offset(source)
        raise NotImplementedError
      end

      # Apply order clause to source, return new source.
      def handle_order(source)
        raise NotImplementedError
      end

      # Constructs the query, if applicable. May not exist or make
      # sense for non-SQL and/or non-ActiveRecord extractors.
      def to_query(source)
        raise NotImplementedError
      end

      # Execute the extraction and return the result set.
      def execute_extract(source)
        raise NotImplementedError
      end
    end
  end
end
