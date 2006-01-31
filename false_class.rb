
class FalseClass

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
    # double-bang to force bool type, and test for truth
    return ! ! term
  end

  ##
  # call-seq:
  #   false | obj   =>   true or false
  #   nil   | obj   =>   true or false
  #
  # Or---Returns <tt>false</tt> if <em>obj</em> is <tt>nil</tt> or
  # <tt>false</tt>; <tt>true</tt> otherwise.

  def |(term)
    # double-bang to force bool type, and test for truth
    return ! ! term
  end

  ##
  # call-seq:
  #   false.to_s   =>  "false"
  #
  # 'nuf said...

  def to_s
    return 'false'
  end
end
