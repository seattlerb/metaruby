module Enumerable

  ##
  # call-seq:
  #   enum.all? [{|obj| block } ]   => true or false
  #
  # Passes each element of the collection to the given block. The method
  # returns <tt>true</tt> if the block never returns <tt>false</tt> or
  # <tt>nil</tt>. If the block is not given, Ruby adds an implicit block of
  # <tt>{|obj| obj}</tt> (that is <tt>all?</tt> will return <tt>true</tt>
  # only if none of the collection members are <tt>false</tt> or
  # <tt>nil</tt>.)
  #
  #    %w{ ant bear cat}.all? {|word| word.length >= 3}   #=> true
  #    %w{ ant bear cat}.all? {|word| word.length >= 4}   #=> false
  #    [ nil, true, 99 ].all?                             #=> false

  def all?(&block)
    block ||= proc { |i| i }

    self.each do |item|
      return false unless block.call(item)
    end
    return true
  end

  ##
  # call-seq:
  #   enum.any? [{|obj| block } ]   => true or false
  #
  # Passes each element of the collection to the given block. The method
  # returns <tt>true</tt> if the block ever returns a value other that
  # <tt>false</tt> or <tt>nil</tt>. If the block is not given, Ruby adds an
  # implicit block of <tt>{|obj| obj}</tt> (that is <tt>any?</tt> will
  # return <tt>true</tt> if at least one of the collection members is not
  # <tt>false</tt> or <tt>nil</tt>.
  #
  #    %w{ ant bear cat}.any? {|word| word.length >= 3}   #=> true
  #    %w{ ant bear cat}.any? {|word| word.length >= 4}   #=> true
  #    [ nil, true, 99 ].any?                             #=> true

  def any?(&block)
    block ||= proc { |i| i }

    self.each do |item|
      return true if block.call(item)
    end
    return false
  end

  ##
  # call-seq:
  #   enum.collect {| obj | block }  => array
  #   enum.map     {| obj | block }  => array
  #
  # Returns a new array with the results of running <em>block</em> once for
  # every element in <em>enum</em>.
  #
  #    (1..4).collect {|i| i*i }   #=> [1, 4, 9, 16]
  #    (1..4).collect { "cat"  }   #=> ["cat", "cat", "cat", "cat"]

  def collect(&block)
    block ||= proc { |i| i }
    ary = []
    self.each do |item|
      ary << block.call(item)
    end
    return ary
  end

  ##
  # call-seq:
  #   enum.detect(ifnone = nil) {| obj | block }  => obj or nil
  #   enum.find(ifnone = nil)   {| obj | block }  => obj or nil
  #
  # Passes each entry in <em>enum</em> to <em>block</em>. Returns the first
  # for which <em>block</em> is not <tt>false</tt>. If no object matches,
  # calls <em>ifnone</em> and returns its result when it is specified, or
  # returns <tt>nil</tt>
  #
  #    (1..10).detect  {|i| i % 5 == 0 and i % 7 == 0 }   #=> nil
  #    (1..100).detect {|i| i % 5 == 0 and i % 7 == 0 }   #=> 35

  alias detect find

  ##
  # call-seq:
  #   enum.each_with_index {|obj, i| block }  -> enum
  #
  # Calls <em>block</em> with two arguments, the item and its index, for
  # each item in <em>enum</em>.
  #
  #    hash = Hash.new
  #    %w(cat dog wombat).each_with_index {|item, index|
  #      hash[item] = index
  #    }
  #    hash   #=> {"cat"=>0, "wombat"=>2, "dog"=>1}

  def each_with_index
    raise LocalJumpError unless block_given?
    index = 0
    self.each do |item|
      yield item, index
      index += 1
    end
    return self
  end

  ##
  # call-seq:
  #   enum.to_a      =>    array
  #   enum.entries   =>    array
  #
  # Returns an array containing the items in <em>enum</em>.
  #
  #    (1..7).to_a                       #=> [1, 2, 3, 4, 5, 6, 7]
  #    { 'a'=>1, 'b'=>2, 'c'=>3 }.to_a   #=> [["a", 1], ["b", 2], ["c", 3]]

  alias entries to_a

  ##
  # call-seq:
  #   enum.detect(ifnone = nil) {| obj | block }  => obj or nil
  #   enum.find(ifnone = nil)   {| obj | block }  => obj or nil
  #
  # Passes each entry in <em>enum</em> to <em>block</em>. Returns the first
  # for which <em>block</em> is not <tt>false</tt>. If no object matches,
  # calls <em>ifnone</em> and returns its result when it is specified, or
  # returns <tt>nil</tt>
  #
  #    (1..10).detect  {|i| i % 5 == 0 and i % 7 == 0 }   #=> nil
  #    (1..100).detect {|i| i % 5 == 0 and i % 7 == 0 }   #=> 35

  def find(ifnone = nil)
    self.each do |item|
      return item if yield item
    end
    return ifnone
  end

  ##
  # call-seq:
  #   enum.find_all {| obj | block }  => array
  #   enum.select   {| obj | block }  => array
  #
  # Returns an array containing all elements of <em>enum</em> for which
  # <em>block</em> is not <tt>false</tt> (see also
  # <tt>Enumerable#reject</tt>).
  #
  #    (1..10).find_all {|i|  i % 3 == 0 }   #=> [3, 6, 9]

  def find_all
    found = []
    self.each do |item|
      found << item if yield item
    end
    return found
  end

  ##
  # call-seq:
  #   enum.grep(pattern)                   => array
  #   enum.grep(pattern) {| obj | block }  => array
  #
  # Returns an array of every element in <em>enum</em> for which <tt>Pattern
  # === element</tt>. If the optional <em>block</em> is supplied, each
  # matching element is passed to it, and the block's result is stored in
  # the output array.
  #
  #    (1..100).grep 38..44   #=> [38, 39, 40, 41, 42, 43, 44]
  #    c = IO.constants
  #    c.grep(/SEEK/)         #=> ["SEEK_END", "SEEK_SET", "SEEK_CUR"]
  #    res = c.grep(/SEEK/) {|v| IO.const_get(v) }
  #    res                    #=> [2, 0, 1]

  def grep(pattern)
    found = []
    self.each do |item|
      next unless pattern === item
      found << (block_given? ? yield(item) : item)
    end
    return found
  end

  ##
  # call-seq:
  #   enum.include?(obj)     => true or false
  #   enum.member?(obj)      => true or false
  #
  # Returns <tt>true</tt> if any member of <em>enum</em> equals
  # <em>obj</em>. Equality is tested using <tt>==</tt>.
  #
  #    IO.constants.include? "SEEK_SET"          #=> true
  #    IO.constants.include? "SEEK_NO_FURTHER"   #=> false

  alias include? member?

  ##
  # call-seq:
  #   enum.inject(initial) {| memo, obj | block }  => obj
  #   enum.inject          {| memo, obj | block }  => obj
  #
  # Combines the elements of <em>enum</em> by applying the block to an
  # accumulator value (<em>memo</em>) and each element in turn. At each
  # step, <em>memo</em> is set to the value returned by the block. The first
  # form lets you supply an initial value for <em>memo</em>. The second form
  # uses the first element of the collection as a the initial value (and
  # skips that element while iterating).
  #
  #    # Sum some numbers
  #    (5..10).inject {|sum, n| sum + n }              #=> 45
  #    # Multiply some numbers
  #    (5..10).inject(1) {|product, n| product * n }   #=> 151200
  #    # find the longest word
  #    longest = %w{ cat sheep bear }.inject do |memo,word|
  #       memo.length > word.length ? memo : word
  #    end
  #    longest                                         #=> "sheep"
  #    # find the length of the longest word
  #    longest = %w{ cat sheep bear }.inject(0) do |memo,word|
  #       memo >= word.length ? memo : word.length
  #    end
  #    longest                                         #=> 5

  def inject(memo = :_nothing)
    enum = self.to_a.dup

    memo = enum.shift if memo == :_nothing

    return memo if enum.empty?

    enum.each do |item|
      memo = yield memo, item
    end
    return memo
  end

  ##
  # call-seq:
  #   enum.collect {| obj | block }  => array
  #   enum.map     {| obj | block }  => array
  #
  # Returns a new array with the results of running <em>block</em> once for
  # every element in <em>enum</em>.
  #
  #    (1..4).collect {|i| i*i }   #=> [1, 4, 9, 16]
  #    (1..4).collect { "cat"  }   #=> ["cat", "cat", "cat", "cat"]

  alias map collect

  ##
  # call-seq:
  #   enum.max                   => obj
  #   enum.max {|a,b| block }    => obj
  #
  # Returns the object in <em>enum</em> with the maximum value. The first
  # form assumes all objects implement <tt>Comparable</tt>; the second uses
  # the block to return <em>a <=> b</em>.
  #
  #    a = %w(albatross dog horse)
  #    a.max                                  #=> "horse"
  #    a.max {|a,b| a.length <=> b.length }   #=> "albatross"

  def max(&block)
    return self.sort(&block).last
  end

  ##
  # call-seq:
  #   enum.include?(obj)     => true or false
  #   enum.member?(obj)      => true or false
  #
  # Returns <tt>true</tt> if any member of <em>enum</em> equals
  # <em>obj</em>. Equality is tested using <tt>==</tt>.
  #
  #    IO.constants.include? "SEEK_SET"          #=> true
  #    IO.constants.include? "SEEK_NO_FURTHER"   #=> false

  def member?(obj)
    self.each do |item|
      return true if item == obj
    end
    return false
  end

  ##
  # call-seq:
  #   enum.min                    => obj
  #   enum.min {| a,b | block }   => obj
  #
  # Returns the object in <em>enum</em> with the minimum value. The first
  # form assumes all objects implement <tt>Comparable</tt>; the second uses
  # the block to return <em>a <=> b</em>.
  #
  #    a = %w(albatross dog horse)
  #    a.min                                  #=> "albatross"
  #    a.min {|a,b| a.length <=> b.length }   #=> "dog"

  def min(&block)
    return self.sort(&block).first
  end

  ##
  # call-seq:
  #   enum.partition {| obj | block }  => [ true_array, false_array ]
  #
  # Returns two arrays, the first containing the elements of <em>enum</em>
  # for which the block evaluates to true, the second containing the rest.
  #
  #    (1..6).partition {|i| (i&1).zero?}   #=> [[2, 4, 6], [1, 3, 5]]

  def partition
    t_arr = []
    f_arr = []
    self.each do |item|
      yield(item) ? t_arr << item : f_arr << item
    end
    return t_arr, f_arr
  end

  ##
  # call-seq:
  #   enum.reject {| obj | block }  => array
  #
  # Returns an array for all elements of <em>enum</em> for which
  # <em>block</em> is false (see also <tt>Enumerable#find_all</tt>).
  #
  #    (1..10).reject {|i|  i % 3 == 0 }   #=> [1, 2, 4, 5, 7, 8, 10]

  def reject
    rejected = []
    self.each do |item|
      rejected << item unless yield item
    end
    return rejected
  end

  ##
  # call-seq:
  #   enum.find_all {| obj | block }  => array
  #   enum.select   {| obj | block }  => array
  #
  # Returns an array containing all elements of <em>enum</em> for which
  # <em>block</em> is not <tt>false</tt> (see also
  # <tt>Enumerable#reject</tt>).
  #
  #    (1..10).find_all {|i|  i % 3 == 0 }   #=> [3, 6, 9]

  alias select find_all

  ##
  # call-seq:
  #   enum.sort                     => array
  #   enum.sort {| a, b | block }   => array
  #
  # Returns an array containing the items in <em>enum</em> sorted, either
  # according to their own <tt><=></tt> method, or by using the results of
  # the supplied block. The block should return -1, 0, or +1 depending on
  # the comparison between <em>a</em> and <em>b</em>. As of Ruby 1.8, the
  # method <tt>Enumerable#sort_by</tt> implements a built-in Schwartzian
  # Transform, useful when key computation or comparison is expensive..
  #
  #    %w(rhea kea flea).sort         #=> ["flea", "kea", "rhea"]
  #    (1..10).sort {|a,b| b <=> a}   #=> [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

#  def sort # HACK
#    raise NotImplementedError, 'sort is not implemented'
#  end

  ##
  # call-seq:
  #   enum.sort_by {| obj | block }    => array
  #
  # Sorts <em>enum</em> using a set of keys generated by mapping the values
  # in <em>enum</em> through the given block.
  #
  #    %w{ apple pear fig }.sort_by {|word| word.length}
  #                 #=> ["fig", "pear", "apple"]
  #
  # The current implementation of <tt>sort_by</tt> generates an array of
  # tuples containing the original collection element and the mapped value.
  # This makes <tt>sort_by</tt> fairly expensive when the keysets are simple
  #
  #    require 'benchmark'
  #    include Benchmark
  #    a = (1..100000).map {rand(100000)}
  #    bm(10) do |b|
  #      b.report("Sort")    { a.sort }
  #      b.report("Sort by") { a.sort_by {|a| a} }
  #    end
  #
  # <em>produces:</em>
  #
  #    user     system      total        real
  #    Sort        0.180000   0.000000   0.180000 (  0.175469)
  #    Sort by     1.980000   0.040000   2.020000 (  2.013586)
  #
  # However, consider the case where comparing the keys is a non-trivial
  # operation. The following code sorts some files on modification time
  # using the basic <tt>sort</tt> method.
  #
  #    files = Dir["*"]
  #    sorted = files.sort {|a,b| File.new(a).mtime <=> File.new(b).mtime}
  #    sorted   #=> ["mon", "tues", "wed", "thurs"]
  #
  # This sort is inefficient: it generates two new <tt>File</tt> objects
  # during every comparison. A slightly better technique is to use the
  # <tt>Kernel#test</tt> method to generate the modification times directly.
  #
  #    files = Dir["*"]
  #    sorted = files.sort { |a,b|
  #      test(?M, a) <=> test(?M, b)
  #    }
  #    sorted   #=> ["mon", "tues", "wed", "thurs"]
  #
  # This still generates many unnecessary <tt>Time</tt> objects. A more
  # efficient technique is to cache the sort keys (modification times in
  # this case) before the sort. Perl users often call this approach a
  # Schwartzian Transform, after Randal Schwartz. We construct a temporary
  # array, where each element is an array containing our sort key along with
  # the filename. We sort this array, and then extract the filename from the
  # result.
  #
  #    sorted = Dir["*"].collect { |f|
  #       [test(?M, f), f]
  #    }.sort.collect { |f| f[1] }
  #    sorted   #=> ["mon", "tues", "wed", "thurs"]
  #
  # This is exactly what <tt>sort_by</tt> does internally.
  #
  #    sorted = Dir["*"].sort_by {|f| test(?M, f)}
  #    sorted   #=> ["mon", "tues", "wed", "thurs"]

  def sort_by
      return self.collect do |item|
         [yield(item), item]
      end.sort.collect { |item| item.last }
  end

  ##
  # call-seq:
  #   enum.to_a      =>    array
  #   enum.entries   =>    array
  #
  # Returns an array containing the items in <em>enum</em>.
  #
  #    (1..7).to_a                       #=> [1, 2, 3, 4, 5, 6, 7]
  #    { 'a'=>1, 'b'=>2, 'c'=>3 }.to_a   #=> [["a", 1], ["b", 2], ["c", 3]]

  def to_a
    return self.map
  end

  ##
  # call-seq:
  #   enum.zip(arg, ...)                   => array
  #   enum.zip(arg, ...) {|arr| block }    => nil
  #
  # Converts any arguments to arrays, then merges elements of <em>enum</em>
  # with corresponding elements from each argument. This generates a
  # sequence of <tt>enum#size</tt> <em>n</em>-element arrays, where
  # <em>n</em> is one more that the count of arguments. If the size of any
  # argument is less than <tt>enum#size</tt>, <tt>nil</tt> values are
  # supplied. If a block given, it is invoked for each output array,
  # otherwise an array of arrays is returned.
  #
  #    a = [ 4, 5, 6 ]
  #    b = [ 7, 8, 9 ]
  #    (1..3).zip(a, b)      #=> [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
  #    "cat\ndog".zip([1])   #=> [["cat\n", 1], ["dog", nil]]
  #    (1..3).zip            #=> [[1], [2], [3]]

  def zip(*args)
    raise "I don't do that yet" if block_given?

    args_len = args.length

    result = []

    self.each_with_index do |item, i|
      tmp = Array.new args_len + 1
      tmp[0] = item

      0.upto(args_len - 1) do |j|
        tmp[j + 1] = args[j][i]
      end

      result[i] = tmp
    end

    return result
  end

end

