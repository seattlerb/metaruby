class Exception

  ##
  # call-seq:
  #   exc.exception(string = nil) -> an_exception or exc
  #
  # With no argument, or if the argument is the same as the receiver, return
  # the receiver. Otherwise, create a new exception object of the same class
  # as the receiver, but with a message equal to <tt>string.to_str</tt>.
  #
  # FIX: this is really just new and should say that

  def self.exception(string = nil)
    return self.new(string)
  end

  ##
  # call-seq:
  #   Exception.new(msg = nil)   =>  exception
  #
  # Construct a new Exception object, optionally passing in a message.

  def initialize(msg = nil)
    @backtrace = nil
    @message = msg
  end

  ##
  # call-seq:
  #   exception.backtrace    => array
  #
  # Returns any backtrace associated with the exception. The backtrace is an
  # array of strings, each containing either ``filename:lineNo: in
  # `method''' or ``filename:lineNo.''
  #
  #    def a
  #      raise "boom"
  #    end
  #    def b
  #      a()
  #    end
  #    begin
  #      b()
  #    rescue => detail
  #      print detail.backtrace.join("\n")
  #    end
  #
  # <em>produces:</em>
  #
  #    prog.rb:2:in `a'
  #    prog.rb:6:in `b'
  #    prog.rb:10

  def backtrace
    return @backtrace
  end

  ##
  # call-seq:
  #   exc.exception(string = nil) -> an_exception or exc
  #
  # With no argument, or if the argument is the same as the receiver, return
  # the receiver. Otherwise, create a new exception object of the same class
  # as the receiver, but with a message equal to <tt>string.to_str</tt>.

  def exception(string = nil)
    return self if string.nil? or string.equal? self
    return self.class.exception(string)
  end

  ##
  # call-seq:
  #   exception.inspect   => string
  #
  # Return this exception's class name an message

  def inspect
    "<#{self.class}: #{message}>"
  end

  ##
  # call-seq:
  #   exc.set_backtrace(array)   =>  array
  #
  # Sets the backtrace information associated with <em>exc</em>. The
  # argument must be an array of <tt>String</tt> objects in the format
  # described in <tt>Exception#backtrace</tt>.

  def set_backtrace(array)
    @backtrace = array
  end

  ##
  # call-seq:
  #   exception.to_s      =>  string
  #   exception.message   =>  string
  #   exception.to_str    =>  string
  #
  # Returns the result of invoking <tt>exception.to_s</tt>. Normally this
  # returns the exception's message or name. By supplying a to_str method,
  # exceptions are agreeing to be used where Strings are expected.

  def to_s
    return @message
  end

  ##
  # call-seq:
  #   exception.to_s      =>  string
  #   exception.message   =>  string
  #   exception.to_str    =>  string
  #
  # Returns the result of invoking <tt>exception.to_s</tt>. Normally this
  # returns the exception's message or name. By supplying a to_str method,
  # exceptions are agreeing to be used where Strings are expected.

  alias to_str to_s

  ##
  # call-seq:
  #   exception.to_s      =>  string
  #   exception.message   =>  string
  #   exception.to_str    =>  string
  #
  # Returns the result of invoking <tt>exception.to_s</tt>. Normally this
  # returns the exception's message or name. By supplying a to_str method,
  # exceptions are agreeing to be used where Strings are expected.

  alias message to_s

end

