module Migratrix
  # ----------------------------------------------------------------------
  # Exceptions
  class MigrationAlreadyExists < Exception; end
  class MigrationFileNotFound < Exception; end
  class MigrationNotDefined < Exception; end
  class ExtractionNotDefined < Exception; end
  class TransformNotDefined < Exception; end
  class LoadNotDefined < Exception; end
  class ExtractionSourceUndefined < Exception; end
end

