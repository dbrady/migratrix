class Object
  def in?(array)
    array.include? self
  end

  def deep_copy
    Marshal::load(Marshal::dump(self))
  end
end

