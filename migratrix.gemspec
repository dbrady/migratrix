spec = Gem::Specification.new do |s|
  s.name = 'migratrix'
  s.version = '0.0.7'
  s.date = '2011-10-15'
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
    "lib/migratrix/exceptions.rb",
    "lib/migratrix/loggable.rb",
    "lib/migratrix/migration.rb",
    "lib/migratrix/migratrix.rb",
    "lib/patches/andand.rb",
    "lib/patches/object_ext.rb",
    "lib/patches/string_ext.rb",
    "spec/fixtures/migrations/marbles_migration.rb",
    "spec/lib/loggable_spec.rb",
    "spec/lib/migration_spec.rb",
    "spec/lib/migrator_spec.rb",
    "spec/lib/migratrix_spec.rb",
    "spec/migratrix_module_spec.rb",
    "spec/patches/object_ext_spec.rb",
    "spec/patches/string_ext_spec.rb",
    "spec/spec_helper.rb",
  ]
end

