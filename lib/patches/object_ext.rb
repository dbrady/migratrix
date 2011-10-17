class Object
  # SimpleCov is no longer covering this line... turns out Rails added it in 3.1.0 go Rails go!
  # gems/activesupport-3.1.0/lib/active_support/core_ext/object/inclusion.rb
  #   def in?(array)
  #     array.include? self
  #   end

  def deep_copy
    Marshal::load(Marshal::dump(self))
  end
end

