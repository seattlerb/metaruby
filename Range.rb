
class Range

  include Enumerable

  ##
  # call-seq:
  #   Range.new(start, end, exclusive=false)    => range
  #
  # Constructs a range using the given <em>start</em> and <em>end</em>.
  # If the third parameter is omitted or is <tt>false</tt>, the
  # <em>range</em> will include the end object; otherwise, it will be
  # excluded.

  def initialize(first, last, exclude_end=false)
    @first = first
    @last = last
    @exclude_end = exclude_end
  end

  ##
  # call-seq:
  #   rng == obj    => true or false
  #
  # Returns <tt>true</tt> only if <em>obj</em> is a Range, has
  # equivalent beginning and end items (by comparing them with
  # <tt>==</tt>), and has the same #exclude_end? setting as <i>rng</t>.
  #
  #   (0..2) == (0..2)            #=> true
  #   (0..2) == Range.new(0,2)    #=> true
  #   (0..2) == (0...2)           #=> false

  def ==(other)
    return false unless Range === other 
    return self.first == other.first && self.last == other.last && self.exclude_end? == other.exclude_end?
  end

  ##
  # call-seq:
  #   rng === obj       =>  true or false
  #   rng.member?(val)  =>  true or false
  #   rng.include?(val) =>  true or false
  #
  # Returns <tt>true</tt> if <em>obj</em> is an element of <em>rng</em>,
  # <tt>false</tt> otherwise. Conveniently, <tt>===</tt> is the
  # comparison operator used by <tt>case</tt> statements.
  #
  #    case 79
  #    when 1..50   then   print "low\n"
  #    when 51..75  then   print "medium\n"
  #    when 76..100 then   print "high\n"
  #    end
  #
  # <em>produces:</em>
  #
  #    high

  def ===(value)
    if @first <= value then
      if self.exclude_end? then
        return true if value < @last
      else
        return true if value <= @last
      end
    end
    return false
  rescue
    return false
  end
  alias_method :member?, :===
  alias_method :include?, :===

  ##
  # call-seq:
  #   rng.each {| i | block } => rng
  #
  # Iterates over the elements <em>rng</em>, passing each in turn to the
  # block. You can only iterate if the start object of the range
  # supports the <tt>succ</tt> method (which means that you can't
  # iterate over ranges of <tt>Float</tt> objects).
  #
  #    (10..15).each do |n|
  #       print n, ' '
  #    end
  #
  # <em>produces:</em>
  #
  #    10 11 12 13 14 15

  def each
    first = self.first # dup?
    last = self.last

    if Fixnum === first && Fixnum === last then
      last -= 1 if self.exclude_end?
      first.upto(last) { |i| yield(i) }
    elsif String === first then
      first.upto(last) do |s|
        next if @exclude_end && s == last
        yield(s)
      end
    else
      current = first
      if @exclude_end then
        loop do
          break if current == last
          yield(current)
          current = current.succ
        end
      else
        loop do
          yield(current)
          break if current == last
          current = current.succ
        end
      end
    end
    return self
  end

  ##
  # call-seq:
  #   rng.eql?(obj)    => true or false
  #
  # Returns <tt>true</tt> only if <em>obj</em> is a Range, has
  # equivalent beginning and end items (by comparing them with #eql?),
  # and has the same #exclude_end? setting as <em>rng</em>.
  #
  #   (0..2) == (0..2)            #=> true
  #   (0..2) == Range.new(0,2)    #=> true
  #   (0..2) == (0...2)           #=> false

  def eql?(other)
    return false unless Range === other 
    return self.first.eql?(other.first) &&
      self.last.eql?(other.last) &&
      self.exclude_end? == other.exclude_end?
  end

  ##
  # call-seq:
  #   rng.exclude_end?    => true or false
  #
  # Returns <tt>true</tt> if <em>rng</em> excludes its end value.

  def exclude_end?
    @exclude_end
  end

  ##
  # call-seq:
  #   rng.first    => obj
  #   rng.begin    => obj
  #
  # Returns the first object in <em>rng</em>.

  def first
    @first
  end
  alias_method :begin, :first

  ##
  # call-seq:
  #   rng.hash    => fixnum
  #
  # Generate a hash value such that two ranges with the same start and
  # end points, and the same value for the "exclude end" flag, generate
  # the same hash value.

  def hash
    excl = @exclude_end ? 1 : 0
    hash = excl
    hash ^= @first.hash << 1
    hash ^= @last.hash << 9
    hash ^= excl << 24;
    return hash
  end

  ##
  # call-seq:
  #   rng.inspect  => string
  #
  # Convert this range object to a printable form (using
  # <tt>inspect</tt> to convert the start and end objects).

  def inspect
    joiner = @exclude_end ? "..." : ".."
    return "#{@first.inspect}#{joiner}#{@last.inspect}"
  end

  ##
  # call-seq:
  #   rng.end    => obj
  #   rng.last   => obj
  #
  # Returns the object that defines the end of <em>rng</em>.
  #
  #    (1..10).end    #=> 10
  #    (1...10).end   #=> 10

  def last
    return @last
  end
  alias_method :end, :last

  ##
  # call-seq:
  #   rng.step(n=1) {| obj | block }    => rng
  #
  # Iterates over <em>rng</em>, passing each <em>n</em>th element to the
  # block. If the range contains numbers or strings, natural ordering is
  # used. Otherwise <tt>step</tt> invokes <tt>succ</tt> to iterate
  # through range elements. The following code uses class <tt>Xs</tt>,
  # which is defined in the class-level documentation.
  #
  #    range = Xs.new(1)..Xs.new(10)
  #    range.step(2) {|x| puts x}
  #    range.step(3) {|x| puts x}
  #
  # <em>produces:</em>
  #
  #     1 x
  #     3 xxx
  #     5 xxxxx
  #     7 xxxxxxx
  #     9 xxxxxxxxx
  #     1 x
  #     4 xxxx
  #     7 xxxxxxx
  #    10 xxxxxxxxxx

  def step(n=1)
    if n == 1 then
      each { |o| yield(o) }
    else
      counter = 0
      each do |o|
        yield(o) if counter % n == 0
        counter += 1
      end
    end
  end

  ##
  # call-seq:
  #   rng.to_s   => string
  #
  # Convert this range object to a printable form.

  def to_s
    joiner = @exclude_end ? "..." : ".."
    return "#{@first}#{joiner}#{@last}"
  end
end

