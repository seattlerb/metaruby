class NilClass

  def &(term)
    return false
  end

  def ^(term)
    # double-not to force bool type
    return !!term
  end

  def |(term)
    # double-not to force bool type
    return !!term
  end

  def inspect
    return 'nil'
  end

  def nil?
    return true
  end

  def to_a
    return []
  end

  def to_f
    return 0.0
  end

  def to_i
    return 0
  end

  def to_s
    return ''
  end

end

