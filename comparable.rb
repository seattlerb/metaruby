module Comparable

  ##
  # call-seq:
  #   obj < other    => true or false
  #
  # Compares two objects based on the receiver's <tt><=></tt> method,
  # returning true if it returns -1.

  def <(other)
    return (self <=> other) == -1
  end

  ##
  # call-seq:
  #   obj <= other    => true or false
  #
  # Compares two objects based on the receiver's <tt><=></tt> method,
  # returning true if it returns -1 or 0.

  def <=(other)
    return ((self <=> other) == -1 or (self <=> other) == 0)
  end

  ##
  # call-seq:
  #   obj == other    => true or false
  #
  # Compares two objects based on the receiver's <tt><=></tt> method,
  # returning true if it returns 0. Also returns true if <em>obj</em> and
  # <em>other</em> are the same object.

  def ==(other)
    return (self <=> other) == 0
  end

  ##
  # call-seq:
  #   obj > other    => true or false
  #
  # Compares two objects based on the receiver's <tt><=></tt> method,
  # returning true if it returns 1.

  def >(other)
    return (self <=> other) == 1
  end

  ##
  # call-seq:
  #   obj >= other    => true or false
  #
  # Compares two objects based on the receiver's <tt><=></tt> method,
  # returning true if it returns 0 or 1.

  def >=(other)
    return ((self <=> other) == 1 or (self <=> other) == 0)
  end

  ##
  # call-seq:
  #   obj.between?(min, max)    => true or false
  #
  # Returns <tt>false</tt> if <em>obj</em> <tt><=></tt> <em>min</em> is less
  # than zero or if <em>anObject</em> <tt><=></tt> <em>max</em> is greater
  # than zero, <tt>true</tt> otherwise.
  #
  #    3.between?(1, 5)               #=> true
  #    6.between?(1, 5)               #=> false
  #    'cat'.between?('ant', 'dog')   #=> true
  #    'gnu'.between?('ant', 'dog')   #=> false

  def between?(min, max)
    return ((self <=> min) >= 0 and (self <=> max) <= 0)
    raise NotImplementedError, 'between? is not implemented'
  end

end

