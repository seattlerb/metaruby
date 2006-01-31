class Exception

  ##
  # call-seq:
  #   exc.exception(string) -> an_exception or exc
  #
  # With no argument, or if the argument is the same as the receiver, return
  # the receiver. Otherwise, create a new exception object of the same class
  # as the receiver, but with a message equal to <tt>string.to_str</tt>.

  def self.exception(*args)
    raise NotImplementedError, 'self.exception is not implemented'
  end

  ##
  # call-seq:
  #   Exception.new(msg = nil)   =>  exception
  #
  # Construct a new Exception object, optionally passing in a message.

  def initialize(*args)
    raise NotImplementedError, 'initialize is not implemented'
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
    raise NotImplementedError, 'backtrace is not implemented'
  end

  ##
  # call-seq:
  #   exc.exception(string) -> an_exception or exc
  #
  # With no argument, or if the argument is the same as the receiver, return
  # the receiver. Otherwise, create a new exception object of the same class
  # as the receiver, but with a message equal to <tt>string.to_str</tt>.

  def exception(*args)
    raise NotImplementedError, 'exception is not implemented'
  end

  ##
  # call-seq:
  #   exception.inspect   => string
  #
  # Return this exception's class name an message

  def inspect
    raise NotImplementedError, 'inspect is not implemented'
  end

  ##
  # call-seq:
  #   exception.message   =>  string
  #   exception.to_str    =>  string
  #
  # Returns the result of invoking <tt>exception.to_s</tt>. Normally this
  # returns the exception's message or name. By supplying a to_str method,
  # exceptions are agreeing to be used where Strings are expected.

  def message
    raise NotImplementedError, 'message is not implemented'
  end

  ##
  # call-seq:
  #   exc.set_backtrace(array)   =>  array
  #
  # Sets the backtrace information associated with <em>exc</em>. The
  # argument must be an array of <tt>String</tt> objects in the format
  # described in <tt>Exception#backtrace</tt>.

  def set_backtrace(arg1)
    raise NotImplementedError, 'set_backtrace is not implemented'
  end

  ##
  # call-seq:
  #   exception.to_s   =>  string
  #
  # Returns exception's message (or the name of the exception if no message
  # is set).

  def to_s
    raise NotImplementedError, 'to_s is not implemented'
  end

  ##
  # call-seq:
  #   exception.message   =>  string
  #   exception.to_str    =>  string
  #
  # Returns the result of invoking <tt>exception.to_s</tt>. Normally this
  # returns the exception's message or name. By supplying a to_str method,
  # exceptions are agreeing to be used where Strings are expected.

  def to_str
    raise NotImplementedError, 'to_str is not implemented'
  end
end

