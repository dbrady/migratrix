class Object
  # Make a deep copy of an object as safely as possible. This was
  # originally a simple Marshal::load(Marshal::dump(self)) but it
  # turns out in Migratrix that we frequently need to copy IO streams
  # and lambdas, neither of which can be marshaled. Then it was a
  # simple dup, but some singleton types like Fixnum cannot be dup'ed.
  # So now we have this monstrosity.
  def deep_copy
    if is_a?(Array)
      map(&:deep_copy)
    elsif is_a?(Hash)
      Hash[to_a.map {|k,v| [k, v.deep_copy]}]
    else
      begin
        Marshal::load(Marshal::dump(self))
      rescue TypeError
        dup
      end
    end
  end
end

