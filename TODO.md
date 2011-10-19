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
  
* [x] FIX the reinstated logging stuff to act like real loggers, so
  that we can inject the `Rails.logger` or a `Logger.new($stdout)`
  without having to muck about with streams.

* [x] 100% code coverage, because I *can*.

* [x] Parts of migratrix_spec.rb are testing migration.rb. Extract them.

* [x] Go ahead and commit the included -> extend atrocity with
  Loggable. It's annoying to have to `include Loggable; extend
  Loggable::ClassMethods` everywhere I just want #log and .log.
  _Better: just use ActiveSupport::Concern_.
  
* [x] Add Migration class name automatically to logging methods.

* [x] Get AR->Yaml constants migration working.

* [x] Extract out Extractor class

* [x] Fix class instance buglet

* [x] Extract out Transform class, transforms collection.

* [ ] register_extractor, etc, so that we're not using magical load
  paths. This lets others write their own Extractors, Transforms and
  Loads, etc.
  
* [ ] Put dials and knobs (options) on Transform

* [ ] Renege on the only-one-extractor idea. If you have data in two
  sources--like a YAML file and a MongoDB, you really have to have 2
  extractors. (Well, okay, you could write an Extractor that grabs
  stuff from both sources but we already have this notion of named
  transform and load streams, might as well have named extraction
  streams.)
  
* [ ] Decide on default migratrix n-transform strategy: Do we have
  the transforms run sequentially, or do we attempt to have them
  process records in parallel?
  
* [ ] Even worse: decide on overall migration strategy: Do we take 1
  record and ETL it, or extract all records, then transform all, then
  load all, or do them in batches, etc. See lazy streams idea later,
  might make things interesting....
  
* [ ] Extract out Load class

* [ ] Refactor NotImplementedMethod specs to shared behavior

* [ ] Get vanilla AR 1->1 migration working.

* [ ] Create before/after class methods and method call chains.

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

* [ ] Get Hairy BFQ->n migration working, either as Multimodel (with
  tricksy joins in the legacy models)->Multimodel or SQL->Multimodel,
  both with find/create behavior on the dependent object output.
  **YIKES:** This implies that a complex migration must either have
  different load strategies for each *type* of data being loaded,
  and/or it must be able to defer to a separate migration entirely.
  
* [ ] Get a CSV migration working. This involves making either the extract
  or transform phase supply source and destination attribute names,
  and either the transform phase or the load phase must access those
  attribute values and write them to the CSV.
  
* [ ] Get migration log working

* [ ] Extract MigrationRegistry. Moving this down because while it's a
  pretty obvious wart in Migratrix, it's a *tiny* obvious wart.

# Problems For Later #

* Problem for later: What happens if we're doing a BFQ join query in
  batches of 1000, and each Load record is comprised of rand(100) rows
  in the SQL input, and a Load record spans the 1000 input rows?
  
* Problem for later: Consider lazy streams? Say we're migrating
  projects and tasks, and instead of saying limit=10 and getting 10
  tasks and taking our chances on however many projects that gets us,
  we say limit=10 *projects*. With lazy streams, instead of querying
  10 rows, we tell the loader something like 10.times { load_next },
  and it would get the next project and ALL of its tasks. The
  implication here is that you could get 5 tasks or 5,000; all you
  know for sure is that you got 10 projects. Since in this case
  migrating a Project makes sense as a cohesive unit, I think that's
  okay. (Also, todo for later, we could have options get steered to
  the appropriate areas, like projects:limit=10, tasks:limit=10, and
  now you'd get 10 projects with at most 10 tasks each. A seductively
  dark implication of this is that Load gets first crack at the
  options, and then decides which options get sent to which transforms
  and how, and how options get sent to the extractor.)
  
* Problem for later: JS (GW license)

* [ ] Refactor valid_options into a class method so you can say

    class Map < Transform
      valid_options "map", "foo", "bar"
      
  and have it magically mix itself into Transform's valid_options
  chain, and autosort, etc.

# TODON'T (YET) #

* [ ] Write generators, e.g. for

    rails g migratrix:constant_migration --namespace NewApp equipment name weight

which should emit the struct class, constant, and initializer loader, e.g.

    module NewApp
        class Equipment < Struct.new(:name, :weight); end
               
        EQUIPMENT = YAML.load_file(CONSTANTS_PATH + 'equipment.yml').inject({}) {|hash, object| hash[object[:id]] = Equipment.new(*object.values); hash }

etc.
