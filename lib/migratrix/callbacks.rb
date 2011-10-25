require 'active_support/concern'

module Migratrix
  # = Migratrix Callbacks
  #
  # Callbacks are hooks into the life cycle of a Migratrix Migration
  # or Component object that allow you to trigger logic before or
  # after an alteration of the object state. This can be used to do
  # extra preparation or cleanup at each step along the way.  Consider
  # the <tt>Migration#migrate</tt> call:
  #
  # * (1) <tt>before_migrate</tt>
  # * (2) <tt>before_extract</tt>
  # * (-) <tt>extract</tt>
  # * (3) <tt>after_extract</tt>
  # * (4) <tt>before_transform</tt>
  # * (-) <tt>transform</tt>
  # * (5) <tt>after_transform</tt>
  # * (6) <tt>before_load</tt>
  # * (-) <tt>load</tt>
  # * (7) <tt>after_load</tt>
  # * (8) <tt>after_migrate</tt>
  #
  module Callbacks
    extend ActiveSupport::Concern

    CALLBACKS = [ :after_extract, :after_load, :after_migrate,
      :after_transform, :around_extract, :around_load,
      :around_migrate, :around_transform, :before_extract,
      :before_load, :before_migrate, :before_transform
    ]

    included do
      extend ActiveModel::Callbacks
    #  include ActiveModel::Validations::Callbacks

      define_model_callbacks :migrate, :extract, :load, :transform
    end

    def migrate #:nodoc:
      run_callbacks(:migrate) { super }
    end

    def extract #:nodoc:
      run_callbacks(:extract) { super }
    end

    def transform(*) #:nodoc:
      run_callbacks(:transform) { super }
    end

    def load(*) #:nodoc:
      run_callbacks(:load) { super }
    end
  end
end

