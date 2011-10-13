spec = Gem::Specification.new do |s|
  s.name = 'migratrix'
  s.version = '0.0.2'
  s.date = '2011-10-13'
  s.summary = 'Rails 3 legacy database migratrion tool supporting multiple strategies'
  s.email = "github@shinybit.com"
  s.homepage = "http://github.com/dbrady/migratrix/"
  s.description = "Migratrix, a Rails legacy database migration tool supporting multiple strategies, including arbitrary n-ary migrations (1->n, n->1, n->m), arbitrary inputs and outputs (ActiveRecord, bare SQL, CSV) and migration logging"
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc", "--title", "Migratrix - Rails migrations made less icky"]
  s.executables = ["migratrix"]
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE"]
  s.authors = ["David Brady"]
  s.add_dependency('trollop')

  # ruby -rpp -e "pp (Dir['{README,{examples,lib,protocol,spec}/**/*.{rdoc,json,rb,txt,xml,yml}}'] + Dir['bin/*']).map.sort"
  s.files = [
    "bin/migratrix",
    "lib/migratrix.rb",
    "lib/migratrix/exceptions.rb",
    "lib/migratrix/migrator.rb",
    "lib/patches/andand.rb",
    "lib/patches/object_ext.rb",
    "lib/patches/string_ext.rb",
    "spec/fixtures/migrators/marbles_migrator.rb",
    "spec/lib/migratrix_spec.rb",
    "spec/spec_helper.rb"
  ]
end

