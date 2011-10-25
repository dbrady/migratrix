module Migratrix
  # TODO: blatant asymmetry here: extraction.extract gets options, but
  # transform and load do not--and they should.
  #
  # = MigrationStrategy
  #
  # This module defines the basic strategy for a generic migration:
  # extract gets a collection of items, transform transforms each
  # item, then load calls save on that final transformed object.
  module MigrationStrategy
    def extract
      extracted_items = {}
      extractions.each do |name, extraction|
        extracted_items[name] = extraction.extract(options)
      end
      extracted_items
    end

    # Transforms source data into outputs. @transformed_items is a
    # hash of name => transformed_items.
    #
    def transform(extracted_items)
      transformed_items = { }
      transforms.each do |name, transform|
        transformed_items[transform.name] = transform.transform extracted_items[transform.extraction]
      end
      transformed_items
    end

    # Saves the migrated data by "loading" it into our database or
    # other data sink. Loaders have their own names, and by default
    # they depend on a transformed_items key of the same name, but you
    # may override this behavior by setting :source => :name or
    # possibly :source => [:name1, :name2, etc].
    def load(transformed_items)
      loaded_items = { }
      loads.each do |name, load|
        loaded_items[load.name] = load.load transformed_items[load.transform]
      end
      loaded_items
    end

    # Perform the migration
    def migrate
      # This fn || @var API lets you write a method and either set the
      # @var or return the value.
      @extracted_items = extract || @extracted_items
      @transformed_items = transform(@extracted_items) || @transformed_items
      load @transformed_items
    end
  end
end

