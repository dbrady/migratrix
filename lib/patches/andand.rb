=begin

This code was hand-patched by David Brady in May 2011 to shut up the
warning in Ruby 1.9. At the time of this writing there is a
6-month-old patch for this in Reg's github version of andand but the
gem still does not support it. This is minor tweak; Reg's copyright
and license remain unchanged.

Copyright (c) 2008 Reginald Braithwaite
http://weblog.raganwald.com/2008/01/objectandand-objectme-in-ruby.html

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Some code adapted from Jim Weirich's post:
http://onestepback.org/index.cgi/Tech/Ruby/BlankSlate.rdoc

=end
module AndAnd
# :nocov:

  module ObjectGoodies

    def andand (p = nil)
      if self
        if block_given?
          yield(self)
        elsif p
          p.to_proc.call(self)
        else
          self
        end
      else
        if block_given? or p
          self
        else
          MockReturningMe.new(self)
        end
      end
    end

    def me (p = nil)
      if block_given?
        yield(self)
        self
      elsif p
        p.to_proc.call(self)
        self
      else
        ProxyReturningMe.new(self)
      end
    end

  end

end

class Object
  include AndAnd::ObjectGoodies
end

module AndAnd

  class BlankSlate
    instance_methods.reject { |m| m =~ /^(__|object_id$)/ }.each { |m| undef_method m }
    def initialize(me)
      @me = me
    end
  end

  class MockReturningMe < BlankSlate
    def method_missing(*args)
      @me
    end
  end

  class ProxyReturningMe < BlankSlate
    def method_missing(sym, *args, &block)
      @me.__send__(sym, *args, &block)
      @me
    end
  end
#:nocov:

end

