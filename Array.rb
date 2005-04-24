class Array

  def self.[](*args)
    Array.new args
  end

  # def initialize(*args); end

  def &(other)
    other = convert other
    new = Array.new
    hash = make_hash other

    self.each do |key|
      value = hash.delete key
      new << key if value == true
    end

    return new
  end

  def *(times)
    if times.respond_to? :to_str then
      tmp = times.to_str
      return self.join(tmp) unless tmp.nil?
    elsif times.respond_to? :to_int then
      times = times.to_int
    else
      raise TypeError, "cannot convert " + times.class.name + " into Integer"
    end
    
    return Array.new if times == 0 # HACK ary_new(rb_obj_class(ary), 0)
    raise ArgumentError, "negative argument" if times < 0
    # raise "argument to big" if LONG_MAX/times < self.length # HACK Bignums are already too big
    
    new = Array.new
    length = self.length * times

    1.upto times do
      new += self
    end
    
    return new
  end

  def +(other)
    new = self.dup
    mem_copy new, 0, self, 0, self.length
    mem_copy new, new.length, other, 0, other.length
    #other.each do |item|
    #  new << item
    #end

    return new
  end

  def -(other)
    hash = make_hash other
    new = Array.new

    self.each do |key|
      value = hash.include? key
      next if value == true
      new << key
    end

    return new
  end

  def |(other)
    other = convert other
    new = Array.new
    hash = make_hash self, other

    self.each do |key|
      value = hash.delete key
      new << key if value == true
    end

    other.each do |key|
      value = hash.delete key
      new << key if value == true
    end

    return new
  end

  alias_method :old_append, :<<

  def <<(arg1)
    return old_append(arg1)
  end

  def <=>(other)
    other = convert other
    length = self.length
    length = other.length if length > other.length

    length = length - 1

      0.upto length do |i|
        value = self.at(i) <=> other.at(i)
        return value if value != 0
      end

    length = self.length - other.length
    return 0 if length == 0
    return 1 if length > 0
    return -1
  end

  def ==(other)
    return true if self.object_id == other.object_id

    unless other.kind_of? Array then
      return false unless other.respond_to? :to_ary
      return other == self
    end

    return false unless other.length == self.length

    self.each_with_index do |item, i|
      return false unless item == other.at(i)
    end
    
    return true
  end

  alias_method :old_index, :[]

  def [](*args)
    return old_index(*args)
  end

  #def []=(*args); end # CORE

  def assoc(key)
    self.each do |item|
      if item.kind_of? Array and # is an array
         item.length > 1 and # of two or more items
         item.at(0) == key then # where the second matches
        return item
      end
    end

    return nil
  end

  #def at(arg1); end # CORE

  def clear
    self.replace Array.new
    return self
  end
  
  def collect
    if block_given? then
      array = Array.new

      self.each do |item|
        array << yield(item)
      end

      return array
    else
      return self.dup
    end
  end

  def collect!
    self.each_with_index do |item, i|
      new_value = yield item
      self[i] = new_value
    end

    return self
  end

  def compact
    new = self.dup
    new.compact!
    return new
  end

  def compact!
    original_length = self.length

    j = 0
    
    0.upto(self.length - 1) do |i|
      item = self.at i
      unless item.nil? then
        self[j] = item
        j += 1
      end
    end

    return nil if j == original_length

    self.slice!(j..-1)

    return self
  end

  def concat(other)
    other = other.to_ary
    if other.length > 0 then
      splice self.length, 0, other
    end

    return self
  end

  def delete(object) # HACK lots like compact!
    original_length = self.length

    j = 0
    
    0.upto(self.length - 1) do |i|
      item = self.at i
      unless item == object then
        self[j] = item
        j += 1
      end
    end

    if j == original_length then
      return yield if block_given?
      return nil
    end

    self.slice!(j..-1)

    return object
  end

  def delete_at(position)
    length = self.length

    return nil if position >= length

    if position < 0 then
      position += length
      return nil if position < 0
    end

    deleted = self.at position
    (position + 1).upto length do |i|
      self[i - 1] = self.at i
    end

    self.slice!(-1)

    return deleted
  end

  alias_method :reject!, :delete_if

  def each(&block)
    0.upto(self.length - 1) do |i|
      yield self.at(i)
    end

    return self
  end

  def each_index
    0.upto(self.length - 1) do |i|
      yield i
    end

    return self
  end

  def empty?
    return self.length == 0
  end

  def eql?(other)
    return true if self.object_id == other.object_id
    return false unless other.kind_of? Array
    return false unless self.length == other.length
    self.each_with_index do |item, i|
      return false unless item.eql? other.at(i)
    end
    return true
  end

  def fetch(position, default = :_unset) # HACK, may be nil
    index = position
    if block_given? and default != :_unset then
      warn "block supersedes default value argument"
    end

    index += self.length if index < 0

    if index < 0  or self.length <= index then
      return yield(position) if block_given?
      return default unless default == :_unset
      raise IndexError, "index " + index.to_s + " out of array"
    end

    return self.at(index)
  end

  # HACK WORST METHOD EVAR!

  def fill(object, start = :_unset, count = :_unset) # HACK tests missing
    if start.kind_of? Range then # HACK lame
      start.each { |i| self[i] = object }
    else
      if count == :_unset then
        count = self.length
      end

      if start.nil? or start == :_unset then
        start = 0
      end

      if count.nil? then
        count = self.length - start
      end

      count.times do |i|
        self[start + i] = object
      end
    end

    return self
  end

  def first(count = nil)
    return self.at(0) if count.nil?

    if not count.respond_to? :to_int then
      raise TypeError, "cannot convert Object into Integer"
    elsif count < 0 then
      raise ArgumentError, "negative array size (or size too big)"
    end

    count = count.to_int

    count = self.length if count > self.length

    return self[0...count]
  end

  def flatten
    new = self.dup
    new.flatten!
    return new
  end

  def flatten!
    modified = false
    memo = nil
    i = 0

    while i < self.length do
      sub_array = self.at i
      if sub_array.respond_to? :to_ary then
        sub_array = sub_array.to_ary
        memo = Array.new if memo.nil?
        i += help_flatten i, sub_array, memo
        modified = true
      end
      i += 1
    end

    return nil unless modified
    return self
  end

  #def frozen?; end # FIX

  # HACK needs a better test

  def hash
    value = self.length
    self.each do |item|
      value = (value << 1) | (value < 0 ? 1 : 0)
      value ^= item.hash
    end

    return value
  end

  def include?(target)
    return false if self.index(target).nil?
    return true
  end

  def index(target)
    self.each_with_index do |item, i|
      return i if target == item
    end

    return nil
  end

  def indexes(*args) # UNTESTED deprecated
    warn "Array#indexes is deprecated, use Array#values_at"
    new = Array.new

    args.each do |i|
      new << self.at(i)
    end

    return new
  end

  alias_method :indices, :indexes # UNTESTED deprecated

  def insert(position, *objects)
    if position == -1 then
      position = self.length
    elsif position < 0 then
      position += 1
    end

    return self if objects.empty?

    splice position, 0, objects

    return self
  end

  def inspect # HACK finish
    return "[]" if self.length == 0
    str = "[" + self.join(", ") + "]"
    return str
  end

  alias_method :old_join, :join

  def join(*args)
    return old_join(*args)
  end

  def last(count = nil)
    return self[-1] if count.nil?

    if not count.respond_to? :to_int then
      raise TypeError, "cannot convert Object into Integer"
    elsif count < 0 then
      raise ArgumentError, "negative array size (or size too big)"
    elsif count == 0 then
      return Array.new
    elsif count > self.length then
      count = 0
    end

    count = count.to_int

    return self[-count..-1]
  end

  def length
    return self.size
  end

  alias_method :map, :collect
  alias_method :map!, :collect!

  def nitems
    count = 0
    self.each do |item|
      count += 1 unless item.nil?
    end

    return count
  end

  ##
  #--
  # C->Ruby Conversion guide:
  #
  # NEXTFROM -> self.at idx; idx += 1

  def pack(format)
    spc10 = " " * 10
    nul10 = "\0" * 10
    items = self.length
    res = ''
    len = 0
    idx = 0
    skip = 0

    format.split('').each_with_index do |type, i|
#puts "#{i}: #{type}"
      if skip > 0 then # skip over consumed characters
        skip -= 1
        next
      end
      next if type == ' '

      if format[i + skip + 1] == ?* then # set data length
        len = type =~ /[@Xxu]/ ? 0 : items
        skip += 1
      elsif format[i + skip + 1].chr =~ /\d/ then
        format[i + skip + 1..-1] =~ /^(\d+)/
        skip += $1.length
        len = $1.to_i
      else
        len = 1
      end

      case type
      when 'A', 'a', 'Z', 'B', 'b', 'H', 'h' then
        raise ArgumentError if idx >= self.length
        from = self.at idx
        idx += 1
        if from.nil? then
          ptr = ""
        else
          ptr = from = from.to_str
        end

        plen = ptr.length

        len = plen if format[i + skip] == ?*

        case type
        when 'a', 'A', 'Z' then
          if plen >= len then
            res << ptr[0...len]
            if format[i + skip] == ?* and type == 'Z' then
              res << "\0"
            end
          else
            res << ptr[0...plen]
            len -= plen
            while len >= 10 do
              res << (type == 'A' ? spc10 : nul10)
              len -= 10
            end
            res << (type == 'A' ? spc10 : nul10)[0...len]
          end

        when 'b' then # bit string ascending
          i = j = byte = 0

          if len > plen then
            j = (len - plen + 1) / 2
            len = plen
          end

          0.upto(len - 1) do |i|
            if ptr[i] & 1 != 0 then
              byte |= 128
            end

            if i + 1 & 7 != 0 then
              byte = byte >> 1
            else
              res << byte.chr
#puts "adding #{byte.chr.inspect}"
              byte = 0
            end
          end

          if len & 7 != 0 then
            byte = byte >> 7 - (len & 7)
            res << byte.chr
            len = j

            while len >= 10 do # shrink
              res << nul10
              len -= 10
            end
            res << nul10[0...len]
          end

        when 'B' then
          i = j = byte = 0

          if len > plen then
            j = (len - plen + 1) / 2
            len = plen
          end

          0.upto(len - 1) do |i|
            byte |= ptr[i] & 1
#p "#{i}: #{byte.inspect}, #{i & 7}"
            if i + 1 & 7 != 0 then
              byte = byte << 1
            else
              res << byte.chr
#puts "adding #{byte.chr.inspect}"
              byte = 0
            end
          end

          if len & 7 != 0 then
            byte = byte << 7 - (len & 7)
            res << byte.chr
            len = j

            while len >= 10 do # shrink
              res << nul10
              len -= 10
            end
            res << nul10[0...len]
          end

        when 'H' then
          i = j = byte = 0

          if len > plen then
            j = (len - plen + 1) / 2
            len = plen
          end

          0.upto(len - 1) do |i|
            if ptr[i] =~ /A-Za-z/ then
              byte |= ((ptr[i] & 15) + 9) & 15
            else
              byte |= ptr[i] & 15
            end

            if i + 1 & 1 != 0 then # i & 1
              byte = byte << 4
            else
              c = byte & 0xff
puts "loop, adding #{c}, byte: #{byte}"
              res << c
              byte = 0
            end
          end

          if len & 1 != 0 then
            c = byte & 0xff
puts "done, adding #{c}, byte: #{byte}"
            res << c
          end

          len = j

          while len >= 10 do # grow
            res << nul10
            len -= 10
          end
          res << nul10[0...len]
        end

      when '@' then
        len -= res.length

        if len > 0 then
          while len >= 10 do # grow
            res << nul10
            len -= 10
          end
          res << nul10[0...len]
        end

        len = -len

        if len > 0 then
          plen = res.length # shrink
          raise ArgumentError, "X outside of string" if plen < len
          res.slice!(plen - len..-1)
        end

      when 'c', 'C' then # signed/unsigned char
        while len > 0 do
          len -= 1
          from = self.at idx
          idx += 1
          c = num2i32 from
          c = 0x100 + c if c < 0
          res << c.chr
        end
      end

p res
    end

    return res
  end

  def pop
    return nil if self.empty?
    return self.slice!(-1)
  end

  def push(*args)
    args.each do |arg|
      self << arg
    end

    return self
  end

  def rassoc(value)
    self.each do |item|
      if item.kind_of? Array and # is an array
         item.length > 1 and # of two or more items
         item.at(1) == value then # where the second matches
        return item
      end
    end

    return nil
  end

  def reject(&block)
    array = self.dup
    array.reject!(&block)
    return array
  end

  def reject!
    j = 0

    self.each_with_index do |item, i|
      next if yield(item) == true
      if i != j then
        self[j] = item
      end
      j += 1
    end

    return nil if self.length == j
    
    if j < self.length then
      self.slice!(j..-1)
    end

    return self
  end

  def replace(other)
    other.each_with_index do |item, i|
      self[i] = item
    end

    self.slice!(other.length..-1)

    return self
  end

  def reverse
    array = self.dup
    array.reverse!
    return array
  end

  def reverse!
    return self if self.length < 1

    p1 = 0
    p2 = self.length - 1

    while p1 < p2 do
      tmp = self.at p1
      self[p1] = self.at p2
      self[p2] = tmp
      p1 += 1
      p2 -= 1
    end
    
    return self
  end

  def reverse_each
    last_index = self.length - 1
    last_index.downto 0 do |i|
      item = self.at i
      yield item
    end

    return self
  end

  def rindex(target)
    i = self.length - 1
    self.reverse_each do |item|
      return i if item == target
      i -= 1
    end

    return nil
  end

  def select(*args) # UNTESTED deprecated
    if args.length > 0 then
      raise ArgumentError, "wrong number of arguments (" + args.length.to_s + " for 0)"
    end

    selected = Array.new
    self.each do |item|
      selected << item if yield item
    end

    return selected
  end

  def shift
    return nil if self.empty?
    return self.slice!(0)
  end

  #def size; end # CORE

  alias_method :[], :slice

  #def slice!(pos, len = nil); end

  def sort(&block)
    sorted = self.dup
    return sorted.sort!(&block)
  end

  def sort!(&block)
    return self if self.empty?
    pivot = self.first
    left = nil
    right = nil

    unless block.nil? then
      left, right = self[1..-1].partition { |e| 0 >= block.call(e, pivot) }
    else
      left, right = self[1..-1].partition { |e| 0 >= (e <=> pivot) }
    end

    self.replace left.sort!(&block) + [ self.first ] + right.sort!(&block)

    return self
  end

  # HACK missing tests for non-Array subclasses

  def to_a
    return self
  end

  def to_ary
    return self
  end

  def to_s
    return "" if self.length == 0
    return self.join($\)
  end

  def transpose
    return self.dup if self.empty?
    elen = -1
    alen = self.length
    result = nil

    self.each_with_index do |item, i|
      tmp = convert(item)

      if elen < 0 then # first element
        elen = tmp.length
        result = Array.new elen

        0.upto(result.length - 1) do |j|
          result[j] = Array.new alen
        end
      elsif elen != tmp.length then
        raise IndexError, "element size differs (" + tmp.length.to_s + " should be " + elen.to_s + ")"
      end

      0.upto(elen - 1) do |j|
        result[j][i] = tmp[j]
      end
    end

    return result
  end

  def uniq
    array = self.dup
    array.uniq!
    return array
  end

  def uniq!
    hash = make_hash self

    return nil if hash.length == self.length
    
    j = 0
    self.each do |key|
      value = hash.delete key
      if value == true then
        self[j] = key
        j += 1
      end
    end

    self.slice!(j..-1)

    return self
  end

  def unshift(*args)
    return self if args.empty?
    count = args.length

    unless self.empty? then
      (self.length - 1).downto 0 do |i|
        self[i + count] = self[i]
      end
    end

    args.each_with_index do |item, i|
      self[i] = item
    end

    return self
  end

  def values_at(*args)
    result = Array.new

    args.each do |arg|
      case arg
      when Fixnum then
        result << self.at(arg)
        next
      when Numeric then  
        result << self.at(arg.to_int)
      when Range then
        # HACK rb_range_beg_len
        self.each_with_index do |item, i|
          result << item if arg.include? i
        end
      else
        raise TypeError, "Cannot convert " + arg.class.name + " into Integer"
      end
    end

    return result
  end

  def zip(*args)
    raise "I don't do that yet" if block_given?

    args = args.map { |a| convert a }
    args_len = args.length

    len = self.length
    result = Array.new len

    0.upto(length - 1) do |i|
      tmp = Array.new args_len + 1
      tmp[0] = self.at(i)

      0.upto(args_len - 1) do |j|
        tmp[j + 1] = args[j][i]
      end
      
      result[i] = tmp
    end

    return result
  end

  private

  def convert(object)
    unless object.respond_to? :to_ary then
      raise TypeError, "cannot convert " + object.class.name + " into Array"
    end
    return object.to_ary
  end

  def help_flatten(index, sub_array, memo)
    i = index
    n = 0
    limit = index + sub_array.length

    id = sub_array.object_id

    if memo.include? id then
      raise ArgumentError, "tried to flatten recursive array"
    end

    memo.push id
    splice index, 1, sub_array

    while i < limit do
      temp = self.at i
      if temp.respond_to? :to_ary then
        n = help_flatten i, temp.to_ary, memo
        i += n
        limit += n
      end
      i += 1
    end

    memo.pop

    return limit - index - 1 # number of increased items
  end

  def make_hash(*arrays)
    hash = Hash.new

    arrays.each do |array|
      array.each_with_index do |key, i|
        hash[key] = true
      end
    end

    return hash
  end

  def mem_clear(start, count)
    start.upto(start + count) do |i|
      self[i] = nil
    end
  end

  def mem_copy(dest, start, source, offset, length)
    0.upto(length - 1) do |i|
      dest[i + start] = source.at(i + offset)
    end
  end

  def splice(beg, len, rpl)
    raise IndexError, "negative len (" + len.to_s + ")" if len < 0

    if beg < 0 then
      beg += self.length
      if beg < 0 then
        beg -= self.length
        raise IndexError, "index " + beg.to_s + " out of self"
      end
    end

    if beg + len > self.length then
      len = self.length - beg
    end

    rlen = 0

    unless rpl.nil? then
      rpl = rpl.to_ary
      rlen = rpl.length
    end

    if beg >= self.length then
      len = beg + rlen
      mem_clear self.length, beg - self.length
      if rlen > 0 then
        mem_copy self, beg, rpl, 0, rlen
      end
      self.slice!(len..-1)
    else
      if beg + len > self.length then
        len = self.length - beg
      end

      alen = self.length + rlen - len

      if len != rlen then
        mem_copy(self, beg + rlen,
                 self, beg + len,
                 self.length - (beg + len))
        self.slice!(alen..-1)
      end

      mem_copy(self, beg, rpl, 0, rlen) if rlen > 0
    end
  end

  # For pack

  def num2i32(x) # :nodoc:
    y = x.to_int
    return y if y.kind_of? Integer
    raise TypeError, "can't convert " + x.class + " to `integer'"
  end

end

puts 'DONE!'
