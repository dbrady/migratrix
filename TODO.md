# TODO #

* [x] BARF Extract Migratrix code into a central/main/controller
  class.

* [x] Fix the module-level API: `migrate!`, `logger` and `logger=` are
  all that are really necessary; everything else people can go through
  `Migratrix::Migratrix` to get at, or more likely directly to
  `Migratrix::Migration`, etc.
  
* [x] Reinstate the logging stuff. Migratrix should log to STDOUT by
  default, or somewhere else if redirected, and everything in the
  Migratrix namespace should share/reuse that logger. Singletons,
  anyone?

* [ ] 100% code coverage, because I *can*.

* [ ] Parts of migratrix_spec.rb are testing migration.rb. Extract them.

* [ ] Extract MigrationRegistry.

* [ ] Consider having a `Migratrix::ModelBase < ActiveRecord::Base`
  base class with all the ActiveRecord migration helpers pre-mixed-in.
  Then users can define something like
  
    module Legacy
      class Base < Migratrix::ModelBase
        establish_connection :legacy
      end
    end
    
  ...and build up their legacy models from there.

* [ ] Move `Migratrix.valid_options` into migration, provide
  `valid_options` class method / DSL to allow subclasses to
  overwrite/extend the migratrix options. Then the migration class can
  handle its options its own way (for example a csv-based migration
  might permit a "headers" option)

* [ ] Tease apart `Migration.execute` so that the log can be easily
  redirected at the Migratrix level but `execute` is either handled by
  the appropriate connection. We cannot simply call
  `ActiveRecord::Base.connection` because in an AR->AR migration, the
  connection may be changed. If we put the method in
  `ActiveRecord::Base`, and have it call `connection`, that should let
  legacy subclasses of `ActiveRecord::Base` refer to their own legacy
  connections. But that means they still need access to the
  `Migratrix` logger... ah, yes: Have `ActiveRecord::Base.execute`
  call `Migratrix.logger` explicitly, and then call `execute` on its
  own `connection`. That should work.

* [ ] Create `strategy` class method(s). Pat likes a single `strategy`
  call with a hash that has a key for each phase pointing to an array
  of configurations each phase; I think I like individual strategy
  methods for each phase because the single configuration hash is
  pretty huge. Best of both worlds: write the single `strategy` method
  and have it call `extract_strategy`, `transform_strategy`, and
  `load_strategy`, which lets users do it either way and keeps the
  code more testable. Worky.

* [ ] Create before/after class methods and method call chains.

* [ ] Get `EquipmentMigration` working. It should do an ActiveRecord all()
  on the legacy equipment table, then transform it into a hash of id
  => Struct.
  
* [ ] Get a simple AR->AR 1->1 migration working. Food or Exercises.

* [ ] Get Meals migration working, either as Multimodel (with tricksy
  joins in the legacy models)->Multimodel or SQL->Multimodel, both
  with find/create behavior on the food output. **YIKES:** This
  implies that a complex migration must either have different load
  strategies for each *type* of data being loaded, and/or it must be
  able to defer to a separate migration entirely.
  
  E.g. importing meals means importing a meal, finding its dependent
  foods, and then performing the foods migration with the option
  `"where"=>["id in (?)", foods.map(&:id)]`
  
* [ ] Get a CSV migration working. This involves making either the extract
  or transform phase supply source and destination attribute names,
  and either the transform phase or the load phase must access those
  attribute values and write them to the CSV.
  
# TODON'T (YET) #

* [ ] Write generators, e.g. for

    rails g migratrix:constant_migration --namespace NewApp equipment name weight

which should emit the struct class, constant, and initializer loader, e.g.

    module NewApp
        class Equipment < Struct.new(:name, :weight); end
               
        EQUIPMENT = YAML.load_file(CONSTANTS_PATH + 'equipment.yml').inject({}) {|hash, object| hash[object[:id]] = Equipment.new(*object.values); hash }

etc.
