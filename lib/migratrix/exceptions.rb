module Migratrix
  # ----------------------------------------------------------------------
  # Exceptions
  class MigrationAlreadyExists < Exception; end
  class MigrationFileNotFound < Exception; end
  class MigrationNotDefined < Exception; end
  class ExtractorNotDefined < Exception; end
  class TransformNotDefined < Exception; end
  class LoadNotDefined < Exception; end
  class ExtractorSourceUndefined < Exception; end
end

