
class FalseClass
  def &(term)
    return false
  end

  def ^(term)
    # double-bang to force bool type, and test for truth
    return ! ! term
  end

  def |(term)
    # double-bang to force bool type, and test for truth
    return ! ! term
  end

  def to_s
    return 'false'
  end
end

