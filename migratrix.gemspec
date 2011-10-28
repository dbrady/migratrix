spec = Gem::Specification.new do |s|
  s.name = 'migratrix'
  s.version = '0.8.4'
  s.date = '2011-10-28'
  s.summary = 'Rails 3 legacy database migratrion tool supporting multiple strategies'
  s.email = "github@shinybit.com"
  s.homepage = "http://github.com/dbrady/migratrix/"
  s.description = "Migratrix, a Rails legacy database migration tool supporting multiple strategies, including arbitrary n-ary migrations (1->n, n->1, n->m), arbitrary inputs and outputs (ActiveRecord, bare SQL, CSV) and migration logging"
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.md", "--title", "Migratrix - Rails migrations made less icky"]
  s.executables = ["migratrix"]
  s.extra_rdoc_files = ["README.md", "MIT-LICENSE"]
  s.authors = ["David Brady"]
  s.add_dependency('trollop')

  # ruby -rpp -e "pp ("
  s.files = [
    "README.md",
    "bin/migratrix",
    "lib/migratrix.rb",
    "lib/migratrix/active_record_migration_helpers.rb",
    "lib/migratrix/callbacks.rb",
    "lib/migratrix/exceptions.rb",
    "lib/migratrix/extractions/active_record.rb",
    "lib/migratrix/extractions/extraction.rb",
    "lib/migratrix/extractions/no_op.rb",
    "lib/migratrix/loads/load.rb",
    "lib/migratrix/loads/no_op.rb",
    "lib/migratrix/loads/yaml.rb",
    "lib/migratrix/loggable.rb",
    "lib/migratrix/migration.rb",
    "lib/migratrix/migration_strategy.rb",
    "lib/migratrix/migratrix.rb",
    "lib/migratrix/registry.rb",
    "lib/migratrix/transforms/map.rb",
    "lib/migratrix/transforms/no_op.rb",
    "lib/migratrix/transforms/transform.rb",
    "lib/migratrix/valid_options.rb",
    "lib/patches/andand.rb",
    "lib/patches/object_ext.rb",
    "lib/patches/string_ext.rb",
    "spec/fixtures/migrations/inherited_migrations.rb",
    "spec/fixtures/migrations/test_migration.rb",
    "spec/lib/migratrix/_loggable_spec.rb",
    "spec/lib/migratrix/callbacks_spec.rb",
    "spec/lib/migratrix/extractions/active_record_spec.rb",
    "spec/lib/migratrix/extractions/extraction_spec.rb",
    "spec/lib/migratrix/loads/load_spec.rb",
    "spec/lib/migratrix/loads/yaml_spec.rb",
    "spec/lib/migratrix/migration_spec.rb",
    "spec/lib/migratrix/migrator_spec.rb",
    "spec/lib/migratrix/migratrix_spec.rb",
    "spec/lib/migratrix/registry_spec.rb",
    "spec/lib/migratrix/transforms/map_spec.rb",
    "spec/lib/migratrix/transforms/transform_spec.rb",
    "spec/lib/migratrix_spec.rb",
    "spec/lib/patches/object_ext_spec.rb",
    "spec/lib/patches/string_ext_spec.rb",
    "spec/spec_helper.rb",
  ]
end

