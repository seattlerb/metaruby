
class TrueClass

  ##
  # call-seq:
  #   true & obj    => true or false
  #
  # And---Returns <tt>false</tt> if <em>obj</em> is <tt>nil</tt> or
  # <tt>false</tt>, <tt>true</tt> otherwise.

  def &(term)
    # double-not will force into boolean... 
    return ! ! term
  end

  ##
  # call-seq:
  #   true ^ obj   => !obj
  #
  # Exclusive Or---Returns <tt>true</tt> if <em>obj</em> is <tt>nil</tt>
  # or <tt>false</tt>, <tt>false</tt> otherwise.

  def ^(term)
    return ! term
  end

  ##
  # call-seq:
  #   true | obj   => true
  #
  # Or---Returns <tt>true</tt>. As <em>anObject</em> is an argument to a
  # method call, it is always evaluated; there is no short-circuit
  # evaluation in this case.
  #
  #    true |  puts("or")
  #    true || puts("logical or")
  #
  # <em>produces:</em>
  #
  #    or

  def |(term)
    return true
  end

  ##
  # call-seq:
  #   true.to_s   =>  "true"
  #
  # The string representation of <tt>true</tt> is "true".

  def to_s
    return 'true'
  end
end

