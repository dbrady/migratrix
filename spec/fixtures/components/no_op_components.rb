class NoOpExtraction < Migratrix::Extractions::Extraction
  def extract(options={})
    []
  end
end

class NoOpTransform < Migratrix::Transforms::Transform
  def transform(exts, options={})
    []
  end
end

class NoOpLoad < Migratrix::Loads::Load
  def load(trans, options={})
    []
  end
end

Migratrix::Migratrix.register_extraction :no_op, NoOpExtraction
Migratrix::Migratrix.register_transform :no_op, NoOpTransform
Migratrix::Migratrix.register_load :no_op, NoOpLoad

