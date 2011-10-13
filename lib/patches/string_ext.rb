# String extensions
class String
  def plural?
    self != self.singularize
  end

  def singular?
    self != self.pluralize
  end
end

