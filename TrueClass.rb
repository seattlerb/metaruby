
class TrueClass

  def &(term)
    # double-not will force into boolean... 
    return ! ! term
  end

  def ^(term)
    return ! term
  end

  def |(term)
    return true
  end

  def to_s
    return 'true'
  end
end

