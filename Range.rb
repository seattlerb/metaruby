class Range

  ##
  # call-seq:
  #   Range.new(start, end, exclusive=false)    => range
  #
  # Constructs a range using the given <em>start</em> and <em>end</em>.
  # If the third parameter is omitted or is <tt>false</tt>, the
  # <em>range</em> will include the end object; otherwise, it will be
  # excluded.

  # def initialize(*args); end

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

  # def ==(arg1); end

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

  # def ===(arg1); end

  ##
  # call-seq:
  #   rng.first    => obj
  #   rng.begin    => obj
  #
  # Returns the first object in <em>rng</em>.

  # def begin; end

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

  # def each; end

  ##
  # call-seq:
  #   rng.end    => obj
  #   rng.last   => obj
  #
  # Returns the object that defines the end of <em>rng</em>.
  #
  #    (1..10).end    #=> 10
  #    (1...10).end   #=> 10

  # def end; end

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

  # def eql?(arg1); end

  ##
  # call-seq:
  #   rng.exclude_end?    => true or false
  #
  # Returns <tt>true</tt> if <em>rng</em> excludes its end value.

  # def exclude_end?; end

  ##
  # call-seq:
  #   rng.first    => obj
  #   rng.begin    => obj
  #
  # Returns the first object in <em>rng</em>.

  # def first; end

  ##
  # call-seq:
  #   rng.hash    => fixnum
  #
  # Generate a hash value such that two ranges with the same start and
  # end points, and the same value for the "exclude end" flag, generate
  # the same hash value.

  # def hash; end

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

  # def include?(arg1); end

  ##
  # call-seq:
  #   rng.inspect  => string
  #
  # Convert this range object to a printable form (using
  # <tt>inspect</tt> to convert the start and end objects).

  # def inspect; end

  ##
  # call-seq:
  #   rng.end    => obj
  #   rng.last   => obj
  #
  # Returns the object that defines the end of <em>rng</em>.
  #
  #    (1..10).end    #=> 10
  #    (1...10).end   #=> 10

  # def last; end

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

  # def member?(arg1); end

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

  # def step(*args); end

  ##
  # call-seq:
  #   rng.to_s   => string
  #
  # Convert this range object to a printable form.

  # def to_s; end
end

puts 'DONE!'
