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
        options = @options.merge(options)
        source = super source, options
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
      #
      # TODO: A bit of a POLS violation here. Let's say you define a
      # migration class that has an extraction, then instantiate that
      # migration with m = MyMigration.new(where: 'id=42'). You might
      # expect to be abe to call m.extractions[:default].to_sql and
      # get the query, but the reality is that the extraction hasn't
      # actually seen the migration's options yet. They are passed in
      # to extract, but not to to_sql. Not sure how to resolve this
      # cleanly. Some options: 1. have Components know who their
      # Migration is and ask it for its options (blegh); 2. pass in
      # options here to to_sql (also blegh, because now end-users have
      # to know they need to pass in the migration's options to
      # to_sql); 3. have a proxy method on Migration that essentially
      # works just like extract, but returns the query instead of the
      # results. I dislike this mechanism the least but it's still
      # only applicable to certain subclasses of Extraction so I
      # hesitate to clutter Migration's API; 4. change
      # Migration#extractions (et al) so it settles its options with
      # the component before returning it. This seems like it would
      # appear the cleanest to the end user but also seems like it
      # would be excessively magical and a weird source of bugs--eg if
      # you try to access migration.loads[:cheese] and it crashes
      # because of an invalid option in loads[:wine].
      def to_sql(source=nil)
        source ||= @source
        source = process_source(obtain_source(source))
        if source.respond_to? :to_sql
          source.to_sql
        else
          handle_where(source, true).to_sql
        end
      end

      def execute_extract(src, options={})
        return src.all if options['fetchall']
        ret = if src.respond_to? :to_sql
                src
              else
                handle_where(src, true)
              end
      end
    end
  end
end

