$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZEnumerable < Rubicon::TestCase

  def setup
    @a = [ 2, 4, 6, 8, 10 ]
  end

  #
  # These tests all rely on Array#each
  def test_00_sanity
    count = 0
    @a.each { |a| count += 1 }
    assert_equal(count, @a.size)

    tmp = []
    @a.each { |a| tmp << a }
    assert_equal(@a, tmp)
  end

  def test_collect
    assert_equal([],                    [].collect {|a| a })
    assert_equal([1,3,5,7,9],           @a.collect {|a| a-1 })
    assert_equal([1,1,1,1,1],           @a.collect {|a| 1 })
    assert_equal([[1],[3],[5],[7],[9]], @a.collect {|a| [a-1] })
  end

  def test_detect
    assert_equal(nil, [].detect {|a| true  })
    assert_equal(nil, @a.detect {|a| false })
    assert_equal(2,   @a.detect {|a| a > 1 })
    assert_equal(6,   @a.detect {|a| a > 5 })
    assert_equal(10,  @a.detect {|a| a > 9 })
    assert_equal(nil, @a.detect {|a| a > 10 })
  end

  def test_each_with_index
    res = []
    [].each_with_index {|a,i| res << [a,i]}
    assert_equal([], res)

    res = []
    @a.each_with_index {|a,i| res << [a,i]}
    assert_equal([[2,0],[4,1],[6,2],[8,3],[10,4]], res)
  end

  def test_entries
    assert_equal([], [].entries)
    assert_equal(@a, @a.entries)
    assert_equal([3,4,5], (3..5).entries)
  end

  def test_find
    assert_equal(nil, [].find {|a| true  })
    assert_equal(nil, @a.find {|a| false })
    assert_equal(2,   @a.find {|a| a > 1 })
    assert_equal(6,   @a.find {|a| a > 5 })
    assert_equal(10,  @a.find {|a| a > 9 })
    assert_equal(nil, @a.find {|a| a > 10 })
  end

  def test_find_all
    assert_equal([],     [].find_all {|a| true})
    assert_equal([],     @a.find_all {|a| false})
    assert_equal([2, 4], @a.find_all {|a| a < 6})
    assert_equal([4],    @a.find_all {|a| a == 4})
    assert_equal(@a,     @a.find_all {|a| true})
  end

  def test_grep
    assert_equal([],     [].grep(1))
    assert_equal([4,6],  @a.grep(3..7))
    assert_equal([5,7],  @a.grep(3..7) {|a| a+1})
    assert_equal([self], [self, 1].grep(TestEnumerable))
  end

  def test_include?
    assert(![].include?(1))
    assert(@a.include?(2))
    assert(!@a.include?(3))
    assert([nil].include?(nil))
  end

  def test_map
    assert_equal([],                    [].map {|a| a })
    assert_equal([1,3,5,7,9],           @a.map {|a| a-1 })
    assert_equal([1,1,1,1,1],           @a.map {|a| 1 })
    assert_equal([[1],[3],[5],[7],[9]], @a.map {|a| [a-1] })
  end

  def test_max
    assert_equal(nil, [].max)
    assert_equal(1,   [1].max)
    assert_equal(5,   [1,2,3,4,5].max)
    assert_equal(5,   [5,4,3,2,1].max)
    assert_equal(5,   [1,4,3,5,2].max)
    assert_equal(5,   [5,5,5,5,5].max)
  end

  def test_member?
    assert(![].member?(1))
    assert(@a.member?(2))
    assert(!@a.member?(3))
    assert([nil].member?(nil))
  end

  def test_min
    assert_equal(nil, [].min)
    assert_equal(1,   [1].min)
    assert_equal(1,   [1,2,3,4,5].min)
    assert_equal(1,   [5,4,3,2,1].min)
    assert_equal(1,   [4,1,3,5,2].min)
    assert_equal(5,   [5,5,5,5,5].min)
  end

  def test_reject
    assert_equal([],            [].reject {|a| true})
    assert_equal(@a,            @a.reject {|a| false})
    assert_equal([6, 8, 10],    @a.reject {|a| a < 6})
    assert_equal([2, 6, 8, 10], @a.reject {|a| a == 4})
    assert_equal([],            @a.reject {|a| true})
  end

  def test_select
    assert_equal([],     [].select {|a| true})
    assert_equal([],     @a.select {|a| false})
    assert_equal([2, 4], @a.select {|a| a < 6})
    assert_equal([4],    @a.select {|a| a == 4})
    assert_equal(@a,     @a.select {|a| true})
  end

  def test_sort
    assert_equal([],         [].sort)
    assert_equal([1],       [1].sort)
    assert_equal([1,1,1],    [1,1,1].sort)
    assert_equal(@a,         @a.sort)
    assert_equal(@a,         @a.sort {|a,b| a - b })
    assert_equal(@a.reverse, @a.sort {|a,b| b <=> a})
    assert_equal("ant bat cat dog", %w(cat ant bat dog).sort.join(" "))
  end

  def test_to_a
    assert_equal([],     (3..2).to_a)
    assert_equal([2, 3], (2..3).to_a)
    assert_equal(@a,     @a.to_a)
  end

end

Rubicon::handleTests(TestEnumerable) if $0 == __FILE__
