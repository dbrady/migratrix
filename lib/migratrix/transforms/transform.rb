module Migratrix
  module Transforms
    # Transform base class. A transform takes a collection of
    # extracted objects and returns a collection of transformed
    # objects. To do this, it needs to know the following:
    #
    # 1. What kind of collection to create. (Array? Hash? Set?
    # Custom?)
    # 2. How to transform one extracted object into a transformed
    # object.
    # 2.1 How to create the object that will hold the transformed
    # object's attributes (might be the transformed object's class,
    # might be a hash of attributes used to create the object itself,
    # you might even try loading the target object from the
    # destination db to see if it's already been migrated--and if so,
    # can it be skipped or does it need to be updated?)
    # 2.2 What attributes to pull off the extracted object
    # 2.3 HOW to pull an attribute off the extracted object
    # 2.4 How to transform each attribute
    # 2.5 What attributes to store on the target object
    # 2.6 HOW to store an attribute on the target object
    # 2.7 How to finalize the transformation
    # 2.7.1 Did you create the target object by class and have you
    # been updating it all along? Then yay, this step is a no-op and
    # you're already done.
    # 2.7.2 If you're doing a merge transformation, and you haven't
    # already checked the destination db for an existing record, now's
    # the time to try to load that sucker and, if successful, to merge
    # it with your migrated values.
    # 2.7.3 A common Rails optimization is to create an attributes
    # hash and new the ActiveRecord object in one call. This is
    # faster* than creating a blank object and updating its attributes
    # individually.
    # 2.8 How to store the finalized object in the collection.
    # (hash[id]=obj? set << obj?)
    #
    # And remember, all of this is just to handle ONE record, albeit
    # admittedly in the most complicated way possible . For sql->sql
    # migrations the transformation step is pretty simple. (It doesn't
    # exist, ha ha. A cross-database INSERT SELECT means that the
    # extract, transform and load all take place in the extract step.)
    #
    # * DANGER DANGER DANGER This is a completely unsubstantiated
    # optimization claim. I'm *sure* it's faster, though, so that's
    # good enough, right? TODO: BENCHMARK THIS OR SOMETHING WHATEVER
    class Transform
      include ::Migratrix::Loggable
      include ::Migratrix::ValidOptions
      attr_accessor :name, :options, :extraction, :transformations

      set_valid_options(
                :apply_attribute,
                :extract_attribute,
                :extraction,
                :final_class,
                :finalize_object,
                :store_transform,
                :target,
                :transform,
                :transform_class,
                :transform_collection
                )

      def initialize(name, options={})
        @name = name
        @options = options.symbolize_keys
        @transformations = options[:transform]
      end

      # Name of the extraction to use. If omitted, returns our name.
      def extraction
        options[:extraction] || name
      end

      # This transform method has strategy magic at every turn. I
      # expect it to be slow, but we can optimize it later, e.g. by
      # rolling out a define_method or similar for all of the constant
      # parts.
      #
      # ----------------------------------------------------------------------
      # Default strategy:
      #
      # create_transformed_collection -> Array.new
      # create_new_object -> @options[:target].new
      # transformations -> MUST BE SUPPLIED BY CHILD CLASS, e.g. Map's {:dst => :src} hash
      # extract_attribute -> attribute_or_extract.is_a?(Proc) ? attribute_or_extract.call(object) : object.send(attribute_or_extract)
      # apply_attribute -> object.send("#{attribute_or_apply}=", value)
      # finalize_object -> no-op
      # store_transformed_object -> collection << transformed_object
      # ----------------------------------------------------------------------
      #
      #
      # Now, can we represent these two strategies as configurations
      # in the migration? For example, here's one way of representing
      # PetTypeMigration's strategy, which in the Load step must save
      # off a YAML dump of a hash of all the pet objects (with just id
      # and name)  keyed
      #
      # set_transform :repetition_types, :map,
      #               :map => {:id => :id, :name => :name },
      #               :extract_method => :index,
      #               :apply_method => :index,
      #               :new_class => Hash,
      #               :collection => Hash,
      #               :store_method => lambda {|item, hash| hash[item[:id]] = item },
      #
      # So the backing magic is this:
      #
      # - We expect :new_class to respond to new() and give us a new,
      #   blank object.
      #
      # - Ditto for :collection; it should respond to new()
      #
      # - extract_method :index means attr = extracted_object[:name]
      #
      # - apply_method :index means the same thing
      #
      # - store_method is the only weirdness here, and it might
      #   actually make sense to have names for the most obvious
      #   strategies, like :store_by => { :index => :id } (An array
      #   could use :store_by => :push, Set by :add, etc.)
      #
      # - The :final_class option is optional; its presence interacts
      #   with the also-optional :finalize option.
      #
      # - The :finalize option is optional; its presence interacts
      #   with the also-optional :final_class option, as follows:
      #
      #   Both Missing: final_object = new_object
      #   :final_class only: final_obj = FinalClass.new(new_obj)
      #   :finalize only: final_obj = finalize(new_obj)
      #   Both Present: final_obj = FinalClass.new(finalize(obj))
      #
      #   Examples/Notes:
      #
      #   - To build ActiveRecord objects quickly, use :new_class =>
      #     Hash, :final_class => ModelClass, :finalize => nil.
      #
      #   - If your source row is a hash (e.g. select_all or a YAML
      #     load) that needs no transformation, but has more columns
      #     than your ActiveRecord model can accept, you could use a
      #     copy transform (basically a map transform without the map
      #     step; new_object = extracted_object) with something like
      #     :new_class => Hash, :final_class => ModelClass, :finalize
      #     => lambda {|hsh| hsh.dup.keep_if? {|k,v|
      #     k.in?(ModelClass.new.attributes.keys)}}
      #     (That would be HORRIBLY inefficient but there would be
      #     ways to memoize with e.g. before_finalize { @keys =
      #     ModelClass.new.attributes.keys })
      #
      # Advanced Magic:
      # - new_class, collection can be procs returning a new object
      # - extract_method, apply_method can be procs taking |obj, attr|
      #   and |obj, attr, value|
      #
      # Super Advanced Magic (YAGNI):
      # - instead of procs, take blocks and use define_method on them
      #   so they're faster.
      def transform(extracted_objects)
        transformed_collection = create_transformed_collection
        extracted_objects.each do |extracted_object|
          new_object = create_new_object(extracted_object)
          transformations.each do |attribute_or_apply, attribute_or_extract|
            apply_attribute(new_object, attribute_or_apply, extract_attribute(extracted_object, attribute_or_extract))
          end
          transformed_object = finalize_object(new_object)
          store_transformed_object(transformed_object, transformed_collection)
        end
        transformed_collection
      end


      def create_transformed_collection
        raise NotImplementedError unless options[:transform_collection]
        option = options[:transform_collection]
        case option
        when Proc
          option.call
        when Class
          option.new
        else
          raise TypeError
        end
      end

      def create_new_object(extracted_row)
        # TODO: this should work like finalize, taking a create and an init.
        raise NotImplementedError unless options[:transform_class]
        option = options[:transform_class]
        case option
        when Proc
          option.call(extracted_row)
        when Class
          option.new # laaame--should receive extracted_row, see todo above
        else
          raise TypeError
        end
      end

      def apply_attribute(object, attribute_or_apply, value)
        raise NotImplementedError unless options[:apply_attribute]
        option = options[:apply_attribute]
        case option
        when Proc
          option.call(object, attribute_or_apply, value)
        when Symbol
          object.send(option, attribute_or_apply, value)
        else
          raise TypeError
        end
      end

      def extract_attribute(object, attribute_or_extract)
        raise NotImplementedError unless options[:extract_attribute]
        if attribute_or_extract.is_a? Proc
          attribute_or_extract.call(object)
        else
          option = options[:extract_attribute]
          case option
          when Proc
            option.call(object, attribute_or_extract)
          when Symbol
            object.send(option, attribute_or_extract)
          else
            raise TypeError
          end
        end
      end


      #   Both Missing: final_object = new_object
      #   :final_class only: final_obj = FinalClass.new(new_obj)
      #   :finalize only: final_obj = finalize(new_obj)
      #   Both Present: final_obj = FinalClass.new(finalize(obj))
      def finalize_object(new_object)
        return new_object unless options[:final_class] || options[:finalize_object]
        raise TypeError if options[:finalize_object] && !options[:finalize_object].is_a?(Proc)
        raise TypeError if options[:final_class] && !options[:final_class].is_a?(Class)
        new_object = options[:finalize_object].call(new_object) if options[:finalize_object]
        new_object = options[:final_class].new(new_object) if options[:final_class]
        new_object
      end

      def store_transformed_object(object, collection)
        raise NotImplementedError unless options[:store_transformed_object]
        option = options[:store_transformed_object]
        case option
        when Proc
          option.call(object, collection)
        when Symbol
          collection.send(option, object)
        else
          raise TypeError
        end
      end
    end
  end
end
