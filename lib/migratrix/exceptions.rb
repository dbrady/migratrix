module Migratrix
  # ----------------------------------------------------------------------
  # Exceptions
  class MigrationAlreadyExists < Exception; end
  class MigrationFileNotFound < Exception; end
  class MigrationNotDefined < Exception; end
end

