class NilClass

  ##
  # call-seq:
  #   false & obj   => false
  #   nil & obj     => false
  #
  # And---Returns <tt>false</tt>. <em>obj</em> is always evaluated as it
  # is the argument to a method call---there is no short-circuit
  # evaluation in this case.

  def &(term)
    return false
  end

  ##
  # call-seq:
  #   false ^ obj    => true or false
  #   nil   ^ obj    => true or false
  #
  # Exclusive Or---If <em>obj</em> is <tt>nil</tt> or <tt>false</tt>,
  # returns <tt>false</tt>; otherwise, returns <tt>true</tt>.

  def ^(term)
    # double-not to force bool type
    return !!term
  end

  ##
  # call-seq:
  #   false | obj   =>   true or false
  #   nil   | obj   =>   true or false
  #
  # Or---Returns <tt>false</tt> if <em>obj</em> is <tt>nil</tt> or
  # <tt>false</tt>; <tt>true</tt> otherwise.

  def |(term)
    # double-not to force bool type
    return !!term
  end

  ##
  # call-seq:
  #   nil.inspect  => "nil"
  #
  # Always returns the string "nil".

  def inspect
    return 'nil'
  end

  ##
  # call-seq:
  #   ()
  #
  # call_seq:
  #
  #   nil.nil?               => true
  #
  # Only the object <em>nil</em> responds <tt>true</tt> to
  # <tt>nil?</tt>.

  def nil?
    return true
  end

  ##
  # call-seq:
  #   nil.to_a    => []
  #
  # Always returns an empty array.
  #
  #    nil.to_a   #=> []

  def to_a
    return []
  end

  ##
  # call-seq:
  #   nil.to_f    => 0.0
  #
  # Always returns zero.
  #
  #    nil.to_f   #=> 0.0

  def to_f
    return 0.0
  end

  ##
  # call-seq:
  #   nil.to_i => 0
  #
  # Always returns zero.
  #
  #    nil.to_i   #=> 0

  def to_i
    return 0
  end

  ##
  # call-seq:
  #   nil.to_s    => ""
  #
  # Always returns the empty string.
  #
  #    nil.to_s   #=> ""

  def to_s
    return ''
  end

end

