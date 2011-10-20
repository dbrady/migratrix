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
      attr_accessor :name, :options, :extractor, :transformations

      def initialize(name, options={})
        @name = name
        @options = options.deep_copy
      end

      # remember, if you override valid_options in a child class, call
      # (super + <your_options>).sort
      # TODO: Can this be magicked into a class method, e.g.
      # valid_options ["target", "transform"]
      # that mixes itself in with the chain?
      def valid_options
        ["extractor", "target", "transform"]
      end

      def extractor
        # TODO: This is still a 1-extractor-per-transform model, but
        # as these represent the vast majority of transforms, I don't
        # want to complicate things by having each transformer handle
        # all extractors. The implication of this right now is that we
        # can't handle multiple extractors at all. (Actually, it can
        # be done by writing a MultiExtract < Transform class that has
        # its own transform method, etc.)
        options[:extractor] || name
      end

      # This transform method has strategy magic at every turn. I
      # expect it to be slow, but we can optimize it later, e.g. by
      # rolling out a define_method or similar for all of the constant
      # parts.
      def transform(extracted_objects={})
        info "Transform #{name} started transform."
        transformed_collection = create_transformed_collection
        extracted_objects.each do |extracted_object|
          new_object = create_new_object(extracted_object)
          transformations.each do |attribute_or_apply, attribute_or_extract|
            apply_attribute(new_object, extract_attribute(extracted_object, attribute_or_extract), attribute_or_apply)
          end
          transformed_object = finalize_object(new_object)
          store_transformed_object(transformed_object, transformed_collection)
        end
        info "Transform #{name} finished transform."
        transformed_collection
      end

      # ----------------------------------------------------------------------
      # Map's strategy, as used by PetsMigration
      #
      # create_transformed_collection -> Hash.new
      # create_new_object -> Hash.new
      # transformation -> {:id => :id, :name => :name }
      # extract_attribute -> object[attribute_or_extract]
      # apply_attribute -> object[attribute] = attribute_or_apply
      # finalize_object -> no-op
      # store_transformed_object -> collection[object[:id]] = object
      # ----------------------------------------------------------------------

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


      def create_transformed_collection
        raise NotImplementedError
      end

      def create_new_object(extracted_row)
        raise NotImplementedError
      end

      def apply_attribute(object, value, attribute_or_apply)
        raise NotImplementedError
      end

      def extract_attribute(object, attribute_or_extract)
        raise NotImplementedError
      end

      # finalize_object is optional; if you are using the "start with
      # a blank object and build it up" strategy, it's a no-op.
      def finalize_object(new_object)
        new_object
      end

      def store_transformed_object(object, collection)
        raise NotImplementedError
      end
    end
  end
end
