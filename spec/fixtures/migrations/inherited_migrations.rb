require 'test_migration'

class ChildMigration1 < TestMigration
end

class ChildMigration2 < TestMigration
end

class GrandchildMigration1 < ChildMigration1
end

