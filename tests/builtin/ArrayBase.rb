require 'rubicon'

# This class tests the functionality of an Array-like object.
#
# To use this, create a subclass for the type being tested, and
# set the instance variable '@cls' to the class of the objects to
# test. For example, the tests for Array are run using
#
#
#    require '../rubicon'
#    require 'ArrayBase.rb'
#
#    class TestArray < ArrayBase
#      def initialize(*args)
#        @cls = Array
#        super
#      end
#    end



Rubicon::handleTests(TestArray) if $0 == __FILE__

class ArrayBase < Rubicon::TestCase

  def test_00_new
    a = @cls.new()
    assert_instance_of(@cls, a)
    assert_equal(0, a.length)
    assert_nil(a[0])
  end

  def test_01_square_brackets
    a = @cls[ 5, 4, 3, 2, 1 ]
    assert_instance_of(@cls, a)
    assert_equal(5, a.length)
    5.times { |i| assert_equal(5-i, a[i]) }
    assert_nil(a[6])
  end

  def test_AND # '&'
    assert_equal(@cls[1, 3], @cls[ 1, 1, 3, 5 ] & @cls[ 1, 2, 3 ])
    assert_equal(@cls[],     @cls[ 1, 1, 3, 5 ] & @cls[ ])
    assert_equal(@cls[],     @cls[  ]           & @cls[ 1, 2, 3 ])
    assert_equal(@cls[],     @cls[ 1, 2, 3 ]    & @cls[ 4, 5, 6 ])
  end

  def test_MUL # '*'
    assert_equal(@cls[], @cls[]*3)
    assert_equal(@cls[1, 1, 1], @cls[1]*3)
    assert_equal(@cls[1, 2, 1, 2, 1, 2], @cls[1, 2]*3)
    assert_equal(@cls[], @cls[1, 2, 3] * 0)
    assert_exception(ArgumentError) { @cls[1, 2]*(-3) }

    assert_equal('1-2-3-4-5', @cls[1, 2, 3, 4, 5] * '-')
    assert_equal('12345',     @cls[1, 2, 3, 4, 5] * '')

  end

  def test_PLUS # '+'
    assert_equal(@cls[],     @cls[]  + @cls[])
    assert_equal(@cls[1],    @cls[1] + @cls[])
    assert_equal(@cls[1],    @cls[]  + @cls[1])
    assert_equal(@cls[1, 1], @cls[1] + @cls[1])
    assert_equal(@cls['cat', 'dog', 1, 2, 3], %w(cat dog) + (1..3).to_a)
  end

  def test_MINUS # '-'
    assert_equal(@cls[],  @cls[1] - @cls[1])
    assert_equal(@cls[1], @cls[1, 2, 3, 4, 5] - @cls[2, 3, 4, 5])
    assert_equal(@cls[1], @cls[1, 2, 1, 3, 1, 4, 1, 5] - @cls[2, 3, 4, 5])
    a = @cls[]
    1000.times { a << 1 }
    assert_equal(1000, a.length)
    assert_equal(@cls[1], a - @cls[2])
    assert_equal(@cls[1],  @cls[ 1, 2, 1] - @cls[2])
    assert_equal(@cls[1, 2, 3], @cls[1, 2, 3] - @cls[4, 5, 6])
  end

  def test_LSHIFT # '<<'
    a = @cls[]
    a << 1
    assert_equal(@cls[1], a)
    a << 2 << 3
    assert_equal(@cls[1, 2, 3], a)
    a << nil << 'cat'
    assert_equal(@cls[1, 2, 3, nil, 'cat'], a)
    a << a
    assert_equal(@cls[1, 2, 3, nil, 'cat', a], a)
  end

  def test_CMP # '<=>'
    assert_equal(0,  @cls[] <=> @cls[])
    assert_equal(0,  @cls[1] <=> @cls[1])
    assert_equal(0,  @cls[1, 2, 3, 'cat'] <=> @cls[1, 2, 3, 'cat'])
    assert_equal(-1, @cls[] <=> @cls[1])
    assert_equal(1,  @cls[1] <=> @cls[])
    assert_equal(-1, @cls[1, 2, 3] <=> @cls[1, 2, 3, 'cat'])
    assert_equal(1,  @cls[1, 2, 3, 'cat'] <=> @cls[1, 2, 3])
    assert_equal(-1, @cls[1, 2, 3, 'cat'] <=> @cls[1, 2, 3, 'dog'])
    assert_equal(1,  @cls[1, 2, 3, 'dog'] <=> @cls[1, 2, 3, 'cat'])
  end

  def test_EQUAL # '=='
    assert(@cls[] == @cls[])
    assert(@cls[1] == @cls[1])
    assert(@cls[1, 1, 2, 2] == @cls[1, 1, 2, 2])
    assert(@cls[1.0, 1.0, 2.0, 2.0] == @cls[1, 1, 2, 2])
    assert(false)
  end

  def test_VERY_EQUAL # '==='
    assert(@cls[] === @cls[])
    assert(@cls[1] === @cls[1])
    assert(@cls[1, 1, 2, 2] === @cls[1, 1, 2, 2])
    assert(@cls[1.0, 1.0, 2.0, 2.0] === @cls[1, 1, 2, 2])
    assert(false)
  end

  def test_AREF # '[]'
    a = @cls[*(1..100).to_a]

    assert_equal(1, a[0])
    assert_equal(100, a[99])
    assert_nil(a[100])
    assert_equal(100, a[-1])
    assert_equal(99,  a[-2])
    assert_equal(1,   a[-100])
    assert_nil(a[-101])
    assert_nil(a[-101,0])
    assert_nil(a[-101,1])
    assert_nil(a[-101,-1])
    assert_nil(a[10,-1])

    assert_equal(@cls[1],   a[0,1])
    assert_equal(@cls[100], a[99,1])
    assert_equal(@cls[],    a[100,1])
    assert_equal(@cls[100], a[99,100])
    assert_equal(@cls[100], a[-1,1])
    assert_equal(@cls[99],  a[-2,1])
    assert_equal(@cls[],    a[-100,0])
    assert_equal(@cls[1],   a[-100,1])

    assert_equal(@cls[10, 11, 12], a[9, 3])
    assert_equal(@cls[10, 11, 12], a[-91, 3])

    assert_equal(@cls[1],   a[0..0])
    assert_equal(@cls[100], a[99..99])
    assert_equal(@cls[],    a[100..100])
    assert_equal(@cls[100], a[99..200])
    assert_equal(@cls[100], a[-1..-1])
    assert_equal(@cls[99],  a[-2..-2])

    assert_equal(@cls[10, 11, 12], a[9..11])
    assert_equal(@cls[10, 11, 12], a[-91..-89])
    
    assert_nil(a[10, -3])
    assert_nil(a[10..7])

    assert_exception(TypeError) {a['cat']}
  end

  def test_ASET # '[]='
    a = @cls[*(0..99).to_a]
    assert_equal(0, a[0] = 0)
    assert_equal(@cls[0] + @cls[*(1..99).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(0, a[10,10] = 0)
    assert_equal(@cls[*(0..9).to_a] + @cls[0] + @cls[*(20..99).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(0, a[-1] = 0)
    assert_equal(@cls[*(0..98).to_a] + @cls[0], a)

    a = @cls[*(0..99).to_a]
    assert_equal(0, a[-10, 10] = 0)
    assert_equal(@cls[*(0..89).to_a] + @cls[0], a)

    a = @cls[*(0..99).to_a]
    assert_equal(0, a[0,1000] = 0)
    assert_equal(@cls[0] , a)

    a = @cls[*(0..99).to_a]
    assert_equal(0, a[10..19] = 0)
    assert_equal(@cls[*(0..9).to_a] + @cls[0] + @cls[*(20..99).to_a], a)

    b = @cls[*%w( a b c )]
    a = @cls[*(0..99).to_a]
    assert_equal(b, a[0,1] = b)
    assert_equal(b + @cls[*(1..99).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(b, a[10,10] = b)
    assert_equal(@cls[*(0..9).to_a] + b + @cls[*(20..99).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(b, a[-1, 1] = b)
    assert_equal(@cls[*(0..98).to_a] + b, a)

    a = @cls[*(0..99).to_a]
    assert_equal(b, a[-10, 10] = b)
    assert_equal(@cls[*(0..89).to_a] + b, a)

    a = @cls[*(0..99).to_a]
    assert_equal(b, a[0,1000] = b)
    assert_equal(b , a)

    a = @cls[*(0..99).to_a]
    assert_equal(b, a[10..19] = b)
    assert_equal(@cls[*(0..9).to_a] + b + @cls[*(20..99).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(nil, a[0,1] = nil)
    assert_equal(@cls[*(1..99).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(nil, a[10,10] = nil)
    assert_equal(@cls[*(0..9).to_a] + @cls[*(20..99).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(nil, a[-1, 1] = nil)
    assert_equal(@cls[*(0..98).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(nil, a[-10, 10] = nil)
    assert_equal(@cls[*(0..89).to_a], a)

    a = @cls[*(0..99).to_a]
    assert_equal(nil, a[0,1000] = nil)
    assert_equal(@cls[] , a)

    a = @cls[*(0..99).to_a]
    assert_equal(nil, a[10..19] = nil)
    assert_equal(@cls[*(0..9).to_a] + @cls[*(20..99).to_a], a)

    a = @cls[1, 2, 3]
    a[1, 0] = a
    assert_equal([1, 1, 2, 3, 2, 3], a)

    a = @cls[1, 2, 3]
    a[-1, 0] = a
    assert_equal([1, 2, 1, 2, 3, 3], a)
  end

  def test_assoc
    a1 = @cls[*%w( cat feline )]
    a2 = @cls[*%w( dog canine )]
    a3 = @cls[*%w( mule asinine )]

    a = @cls[ a1, a2, a3 ]

    assert_equal(a1, a.assoc('cat'))
    assert_equal(a3, a.assoc('mule'))
    assert_equal(nil, a.assoc('asinine'))
    assert_equal(nil, a.assoc('wombat'))
    assert_equal(nil, a.assoc(1..2))
  end

  def test_at
    a = @cls[*(0..99).to_a]
    assert_equal(0,   a.at(0))
    assert_equal(10,  a.at(10))
    assert_equal(99,  a.at(99))
    assert_equal(nil, a.at(100))
    assert_equal(99,  a.at(-1))
    assert_equal(0,  a.at(-100))
    assert_equal(nil, a.at(-101))
    assert_exception(TypeError) { a.at('cat') }
  end

  def test_clear
    a = @cls[1, 2, 3]
    b = a.clear
    assert_equal(@cls[], a)
    assert_equal(@cls[], b)
    assert_equal(a.__id__, b.__id__)
  end

  def test_clone
    for taint in [ false, true ]
      for frozen in [ false, true ]
        a = @cls[*(0..99).to_a]
        a.taint  if taint
        a.freeze if frozen
        b = a.clone

        assert_equal(a, b)
        assert(a.__id__ != b.__id__)
        assert_equal(a.frozen?, b.frozen?)
        assert_equal(a.tainted?, b.tainted?)
      end
    end
  end

  def test_collect
    a = @cls[ 1, 'cat', 1..1 ]
    assert_equal([ ZFixnum, ZString, ZRange], a.collect {|e| e.class} )
    assert_equal([ 99, 99, 99], a.collect { 99 } )

    assert_equal([], @cls[].collect { 99 })

    assert_equal([1, 2, 3], @cls[1, 2, 3].collect)
  end

  # also update map!
  def test_collect!
    a = @cls[ 1, 'cat', 1..1 ]
    assert_equal([ ZFixnum, ZString, ZRange], a.collect! {|e| e.class} )
    assert_equal([ ZFixnum, ZString, ZRange], a)
   
    a = @cls[ 1, 'cat', 1..1 ]
    assert_equal([ 99, 99, 99], a.collect! { 99 } )
    assert_equal([ 99, 99, 99], a)

    a = @cls[ ]
    assert_equal([], a.collect! { 99 })
    assert_equal([], a)
  end

  def test_compact
    a = @cls[ 1, nil, nil, 2, 3, nil, 4 ]
    assert_equal(@cls[1, 2, 3, 4], a.compact)

    a = @cls[ nil, 1, nil, 2, 3, nil, 4 ]
    assert_equal(@cls[1, 2, 3, 4], a.compact)

    a = @cls[ 1, nil, nil, 2, 3, nil, 4, nil ]
    assert_equal(@cls[1, 2, 3, 4], a.compact)

    a = @cls[ 1, 2, 3, 4 ]
    assert_equal(@cls[1, 2, 3, 4], a.compact)
  end

  def test_compact!
    a = @cls[ 1, nil, nil, 2, 3, nil, 4 ]
    assert_equal(@cls[1, 2, 3, 4], a.compact!)
    assert_equal(@cls[1, 2, 3, 4], a)

    a = @cls[ nil, 1, nil, 2, 3, nil, 4 ]
    assert_equal(@cls[1, 2, 3, 4], a.compact!)
    assert_equal(@cls[1, 2, 3, 4], a)

    a = @cls[ 1, nil, nil, 2, 3, nil, 4, nil ]
    assert_equal(@cls[1, 2, 3, 4], a.compact!)
    assert_equal(@cls[1, 2, 3, 4], a)

    a = @cls[ 1, 2, 3, 4 ]
    assert_equal(nil, a.compact!)
    assert_equal(@cls[1, 2, 3, 4], a)
  end

  def test_concat
    assert_equal(@cls[1, 2, 3, 4],     @cls[1, 2].concat(@cls[3, 4]))
    assert_equal(@cls[1, 2, 3, 4],     @cls[].concat(@cls[1, 2, 3, 4]))
    assert_equal(@cls[1, 2, 3, 4],     @cls[1, 2, 3, 4].concat(@cls[]))
    assert_equal(@cls[],               @cls[].concat(@cls[]))
    assert_equal(@cls[@cls[1, 2], @cls[3, 4]], @cls[@cls[1, 2]].concat(@cls[@cls[3, 4]]))
    
    a = @cls[1, 2, 3]
    a.concat(a)
    assert_equal([1, 2, 3, 1, 2, 3], a)
  end

  def test_delete
    a = @cls[*('cab'..'cat').to_a]
    assert_equal('cap', a.delete('cap'))
    assert_equal(@cls[*('cab'..'cao').to_a] + @cls[*('caq'..'cat').to_a], a)

    a = @cls[*('cab'..'cat').to_a]
    assert_equal('cab', a.delete('cab'))
    assert_equal(@cls[*('cac'..'cat').to_a], a)

    a = @cls[*('cab'..'cat').to_a]
    assert_equal('cat', a.delete('cat'))
    assert_equal(@cls[*('cab'..'cas').to_a], a)

    a = @cls[*('cab'..'cat').to_a]
    assert_equal(nil, a.delete('cup'))
    assert_equal(@cls[*('cab'..'cat').to_a], a)

    a = @cls[*('cab'..'cat').to_a]
    assert_equal(99, a.delete('cup') { 99 } )
    assert_equal(@cls[*('cab'..'cat').to_a], a)
  end

  def test_delete_at
    a = @cls[*(1..5).to_a]
    assert_equals(3, a.delete_at(2))
    assert_equals(@cls[1, 2, 4, 5], a)

    a = @cls[*(1..5).to_a]
    assert_equals(4, a.delete_at(-2))
    assert_equals(@cls[1, 2, 3, 5], a)

    a = @cls[*(1..5).to_a]
    assert_equals(nil, a.delete_at(5))
    assert_equals(@cls[1, 2, 3, 4, 5], a)

    a = @cls[*(1..5).to_a]
    assert_equals(nil, a.delete_at(-6))
    assert_equals(@cls[1, 2, 3, 4, 5], a)
  end

  # also reject!
  def test_delete_if
    a = @cls[ 1, 2, 3, 4, 5 ]
    assert_equal(a, a.delete_if { false })
    assert_equal(@cls[1, 2, 3, 4, 5], a)

    a = @cls[ 1, 2, 3, 4, 5 ]
    assert_equal(a, a.delete_if { true })
    assert_equal(@cls[], a)

    a = @cls[ 1, 2, 3, 4, 5 ]
    assert_equal(a, a.delete_if { |i| i > 3 })
    assert_equal(@cls[1, 2, 3], a)
  end

  def test_dup
    for taint in [ false, true ]
      for frozen in [ false, true ]
        a = @cls[*(0..99).to_a]
        a.taint  if taint
        a.freeze if frozen
        b = a.dup

        assert_equal(a, b)
        assert(a.__id__ != b.__id__)
        assert_equals(false, b.frozen?)
        assert_equals(a.tainted?, b.tainted?)
      end
    end
  end

  def test_each
    a = @cls[*%w( ant bat cat dog )]
    i = 0
    a.each { |e|
      assert_equal(a[i], e)
      i += 1
    }
    assert_equal(4, i)

    a = @cls[]
    i = 0
    a.each { |e|
      assert_equal(a[i], e)
      i += 1
    }
    assert_equal(0, i)

    assert_equal(a, a.each {})
  end

  def test_each_index
    a = @cls[*%w( ant bat cat dog )]
    i = 0
    a.each_index { |ind|
      assert_equal(i, ind)
      i += 1
    }
    assert_equal(4, i)

    a = @cls[]
    i = 0
    a.each_index { |ind|
      assert_equal(i, ind)
      i += 1
    }
    assert_equal(0, i)

    assert_equal(a, a.each_index {})
  end

  def test_empty?
    assert(@cls[].empty?)
    assert(!@cls[1].empty?)
  end

  def test_eql?
    assert(@cls[].eql?(@cls[]))
    assert(@cls[1].eql?(@cls[1]))
    assert(@cls[1, 1, 2, 2].eql?(@cls[1, 1, 2, 2]))
    assert(!@cls[1.0, 1.0, 2.0, 2.0].eql?(@cls[1, 1, 2, 2]))
  end

  def test_fill
    assert_equal(@cls[],   @cls[].fill(99))
    assert_equal(@cls[],   @cls[].fill(99, 0))
    assert_equal(@cls[99], @cls[].fill(99, 0, 1))
    assert_equal(@cls[99], @cls[].fill(99, 0..0))

    assert_equal(@cls[99],   @cls[1].fill(99))
    assert_equal(@cls[99],   @cls[1].fill(99, 0))
    assert_equal(@cls[99],   @cls[1].fill(99, 0, 1))
    assert_equal(@cls[99],   @cls[1].fill(99, 0..0))

    assert_equal(@cls[99, 99], @cls[1, 2].fill(99))
    assert_equal(@cls[99, 99], @cls[1, 2].fill(99, 0))
    assert_equal(@cls[99, 99], @cls[1, 2].fill(99, nil))
    assert_equal(@cls[1,  99], @cls[1, 2].fill(99, 1, nil))
    assert_equal(@cls[99,  2], @cls[1, 2].fill(99, 0, 1))
    assert_equal(@cls[99,  2], @cls[1, 2].fill(99, 0..0))
  end

  def test_first
    assert_equal(3,   @cls[3, 4, 5].first)
    assert_equal(nil, @cls[].first)
  end

  def test_flatten
    a1 = @cls[ 1, 2, 3]
    a2 = @cls[ 5, 6 ]
    a3 = @cls[ 4, a2 ]
    a4 = @cls[ a1, a3 ]
    assert_equal(@cls[1, 2, 3, 4, 5, 6], a4.flatten)
    assert_equal(@cls[ a1, a3], a4)

    a5 = @cls[ a1, @cls[], a3 ]
    assert_equal(@cls[1, 2, 3, 4, 5, 6], a5.flatten)
    assert_equal(@cls[], @cls[].flatten)
    assert_equal(@cls[], 
                 @cls[@cls[@cls[@cls[],@cls[]],@cls[@cls[]],@cls[]],@cls[@cls[@cls[]]]].flatten)
  end

  def test_flatten!
    a1 = @cls[ 1, 2, 3]
    a2 = @cls[ 5, 6 ]
    a3 = @cls[ 4, a2 ]
    a4 = @cls[ a1, a3 ]
    assert_equal(@cls[1, 2, 3, 4, 5, 6], a4.flatten!)
    assert_equal(@cls[1, 2, 3, 4, 5, 6], a4)

    a5 = @cls[ a1, @cls[], a3 ]
    assert_equal(@cls[1, 2, 3, 4, 5, 6], a5.flatten!)
    assert_equal(@cls[1, 2, 3, 4, 5, 6], a5)

    assert_equal(@cls[], @cls[].flatten)
    assert_equal(@cls[], 
                 @cls[@cls[@cls[@cls[],@cls[]],@cls[@cls[]],@cls[]],@cls[@cls[@cls[]]]].flatten)
  end

  def test_hash
    a1 = @cls[ 'cat', 'dog' ]
    a2 = @cls[ 'cat', 'dog' ]
    a3 = @cls[ 'dog', 'cat' ]
    assert(a1.hash == a2.hash)
    assert(a1.hash != a3.hash)
  end

  def test_include?
    a = @cls[ 'cat', 99, /a/, @cls[ 1, 2, 3] ]
    assert(a.include?('cat'))
    assert(a.include?(99))
    assert(a.include?(/a/))
    assert(a.include?([1,2,3]))
    assert(!a.include?('ca'))
    assert(!a.include?([1,2]))
  end

  def test_index
    a = @cls[ 'cat', 99, /a/, 99, @cls[ 1, 2, 3] ]
    assert_equal(0, a.index('cat'))
    assert_equal(1, a.index(99))
    assert_equal(4, a.index([1,2,3]))
    assert_nil(a.index('ca'))
    assert_nil(a.index([1,2]))
  end

  Version.less_than("1.7.2") do
    def test_indexes
      generic_index_test(:indexes)
    end
  
    def test_indices
      generic_index_test(:indices)
    end
  end
  
  Version.greater_or_equal("1.7.2") do
    def test_select
      generic_index_test(:select)
    end
  end

  def generic_index_test(symbol)
    a = @cls[*('a'..'j').to_a]
    assert_equal(@cls['a', 'c', 'e'], a.send(symbol,0, 2, 4))
    assert_equal(@cls['j', 'h', 'f'], a.send(symbol,-1, -3, -5))
    assert_equal(@cls['h', nil, 'a'], a.send(symbol,-3, 99, 0))
  end

  def test_join
    $, = ""
    a = @cls[]
    assert_equal("", a.join)
    assert_equal("", a.join(','))

    $, = ""
    a = @cls[1, 2]
    assert_equal("12", a.join)
    assert_equal("1,2", a.join(','))

    $, = ""
    a = @cls[1, 2, 3]
    assert_equal("123", a.join)
    assert_equal("1,2,3", a.join(','))

    $, = ":"
    a = @cls[1, 2, 3]
    assert_equal("1:2:3", a.join)
    assert_equal("1,2,3", a.join(','))

    $, = ""
  end

  def test_last
    assert_equal(nil, @cls[].last)
    assert_equal(1, @cls[1].last)
    assert_equal(99, @cls[*(3..99).to_a].last)
  end

  def test_length
    assert_equal(0, @cls[].length)
    assert_equal(1, @cls[1].length)
    assert_equal(2, @cls[1, nil].length)
    assert_equal(2, @cls[nil, 1].length)
    assert_equal(234, @cls[*(0..233).to_a].length)
  end

  # also update collect!
  def test_map!
    a = @cls[ 1, 'cat', 1..1 ]
    assert_equal(@cls[ ZFixnum, ZString, ZRange], a.map! {|e| e.class} )
    assert_equal(@cls[ ZFixnum, ZString, ZRange], a)
   
    a = @cls[ 1, 'cat', 1..1 ]
    assert_equal(@cls[ 99, 99, 99], a.map! { 99 } )
    assert_equal(@cls[ 99, 99, 99], a)

    a = @cls[ ]
    assert_equal(@cls[], a.map! { 99 })
    assert_equal(@cls[], a)
  end

  def test_nitems
    assert_equal(0, @cls[].nitems)
    assert_equal(1, @cls[1].nitems)
    assert_equal(1, @cls[1, nil].nitems)
    assert_equal(1, @cls[nil, 1].nitems)
    assert_equal(3, @cls[1, nil, nil, 2, nil, 3, nil].nitems)
  end

  def test_pack
    a = @cls[*%w( cat wombat x yy)]
    assert_equals("catwomx  yy ", a.pack("A3A3A3A3"))
    assert_equals("cat", a.pack("A*"))
    assert_equals("cwx  yy ", a.pack("A3@1A3@2A3A3"))
    assert_equals("catwomx\000\000yy\000", a.pack("a3a3a3a3"))
    assert_equals("cat", a.pack("a*"))
    assert_equals("ca", a.pack("a2"))
    assert_equals("cat\000\000", a.pack("a5"))

    assert_equals("\x61",     @cls["01100001"].pack("B8"))
    assert_equals("\x61",     @cls["01100001"].pack("B*"))
    assert_equals("\x61",     @cls["0110000100110111"].pack("B8"))
    assert_equals("\x61\x37", @cls["0110000100110111"].pack("B16"))
    assert_equals("\x61\x37", @cls["01100001", "00110111"].pack("B8B8"))
    assert_equals("\x60",     @cls["01100001"].pack("B4"))
    assert_equals("\x40",     @cls["01100001"].pack("B2"))

    assert_equals("\x86",     @cls["01100001"].pack("b8"))
    assert_equals("\x86",     @cls["01100001"].pack("b*"))
    assert_equals("\x86",     @cls["0110000100110111"].pack("b8"))
    assert_equals("\x86\xec", @cls["0110000100110111"].pack("b16"))
    assert_equals("\x86\xec", @cls["01100001", "00110111"].pack("b8b8"))
    assert_equals("\x06",     @cls["01100001"].pack("b4"))
    assert_equals("\x02",     @cls["01100001"].pack("b2"))

    assert_equals("ABC",      @cls[ 65, 66, 67 ].pack("C3"))
    assert_equals("\377BC",   @cls[ -1, 66, 67 ].pack("C*"))
    assert_equals("ABC",      @cls[ 65, 66, 67 ].pack("c3"))
    assert_equals("\377BC",   @cls[ -1, 66, 67 ].pack("c*"))

    
    assert_equal("AB\n\x10",  @cls["4142", "0a", "12"].pack("H4H2H1"))
    assert_equal("AB\n\x02",  @cls["1424", "a0", "21"].pack("h4h2h1"))

    assert_equal("abc=02def=\ncat=\n=01=\n", 
                 @cls["abc\002def", "cat", "\001"].pack("M9M3M4"))

    assert_equal("aGVsbG8K\n",  @cls["hello\n"].pack("m"))
    assert_equal(",:&5L;&\\*:&5L;&\\*\n",  @cls["hello\nhello\n"].pack("u"))

    assert_equal("\xc2\xa9B\xe2\x89\xa0", @cls[0xa9, 0x42, 0x2260].pack("U*"))


    format = "c2x5CCxsdils_l_a6";
    # Need the expression in here to force ary[5] to be numeric.  This avoids
    # test2 failing because ary2 goes str->numeric->str and ary does not.
    ary = [1, -100, 127, 128, 32767, 987.654321098/100.0,
      12345, 123456, -32767, -123456, "abcdef"]
    x    = ary.pack(format)
    ary2 = x.unpack(format)

    assert_equal(ary.length, ary2.length)
    assert_equal(ary.join(':'), ary2.join(':'))
    assert_not_nil(x =~ /def/)



    skipping "Not tested:
        D,d & double-precision float, native format\\
        E & double-precision float, little-endian byte order\\
        e & single-precision float, little-endian byte order\\
        F,f & single-precision float, native format\\
        G & double-precision float, network (big-endian) byte order\\
        g & single-precision float, network (big-endian) byte order\\
        I & unsigned integer\\
        i & integer\\
        L & unsigned long\\
        l & long\\

        N & long, network (big-endian) byte order\\
        n & short, network (big-endian) byte-order\\
        P & pointer to a structure (fixed-length string)\\
        p & pointer to a null-terminated string\\
        S & unsigned short\\
        s & short\\
        V & long, little-endian byte order\\
        v & short, little-endian byte order\\
        X & back up a byte\\
        x & null byte\\
        Z & ASCII string (null padded, count is width)\\
"
  end

  def test_pop
    a = @cls[ 'cat', 'dog' ]
    assert_equal('dog', a.pop)
    assert_equal(@cls['cat'], a)
    assert_equal('cat', a.pop)
    assert_equal(@cls[], a)
    assert_nil(a.pop)
    assert_equal(@cls[], a)
  end

  def test_push
    a = @cls[1, 2, 3]
    assert_equal(@cls[1, 2, 3, 4, 5], a.push(4, 5))
    Version.greater_or_equal("1.6.2") do
      assert_exception(ArgumentError, "a.push()") { a.push() }
    end
    Version.less_than("1.6.2") do
      assert_equal(@cls[1, 2, 3, 4, 5], a.push())
    end
    assert_equal(@cls[1, 2, 3, 4, 5, nil], a.push(nil))
  end

  def test_rassoc
    a1 = @cls[*%w( cat  feline )]
    a2 = @cls[*%w( dog  canine )]
    a3 = @cls[*%w( mule asinine )]
    a  = @cls[ a1, a2, a3 ]

    assert_equal(a1,  a.rassoc('feline'))
    assert_equal(a3,  a.rassoc('asinine'))
    assert_equal(nil, a.rassoc('dog'))
    assert_equal(nil, a.rassoc('mule'))
    assert_equal(nil, a.rassoc(1..2))
  end

  # also delete_if
  def test_reject!
    a = @cls[ 1, 2, 3, 4, 5 ]
    assert_equal(nil, a.reject! { false })
    assert_equal(@cls[1, 2, 3, 4, 5], a)

    a = @cls[ 1, 2, 3, 4, 5 ]
    assert_equal(a, a.reject! { true })
    assert_equal(@cls[], a)

    a = @cls[ 1, 2, 3, 4, 5 ]
    assert_equal(a, a.reject! { |i| i > 3 })
    assert_equal(@cls[1, 2, 3], a)
  end

  def test_replace
    a = @cls[ 1, 2, 3]
    a_id = a.__id__
    assert_equal(@cls[4, 5, 6], a.replace(@cls[4, 5, 6]))
    assert_equal(@cls[4, 5, 6], a)
    assert_equal(a_id, a.__id__)
    assert_equal(@cls[], a.replace(@cls[]))
  end

  def test_reverse
    a = @cls[*%w( dog cat bee ant )]
    assert_equal(@cls[*%w(ant bee cat dog)], a.reverse)
    assert_equal(@cls[*%w(dog cat bee ant)], a)
    assert_equal(@cls[], @cls[].reverse)
  end

  def test_reverse!
    a = @cls[*%w( dog cat bee ant )]
    assert_equal(@cls[*%w(ant bee cat dog)], a.reverse!)
    assert_equal(@cls[*%w(ant bee cat dog)], a)
    assert_nil(@cls[].reverse!)
  end

  def test_reverse_each
    a = @cls[*%w( dog cat bee ant )]
    i = a.length
    a.reverse_each { |e|
      i -= 1
      assert_equal(a[i], e)
    }
    assert_equal(0, i)

    a = @cls[]
    i = 0
    a.reverse_each { |e|
      assert(false, "Never get here")
    }
    assert_equal(0, i)
  end

  def test_rindex
    a = @cls[ 'cat', 99, /a/, 99, [ 1, 2, 3] ]
    assert_equal(0, a.rindex('cat'))
    assert_equal(3, a.rindex(99))
    assert_equal(4, a.rindex([1,2,3]))
    assert_nil(a.rindex('ca'))
    assert_nil(a.rindex([1,2]))
  end

  def test_shift
    a = @cls[ 'cat', 'dog' ]
    assert_equal('cat', a.shift)
    assert_equal(@cls['dog'], a)
    assert_equal('dog', a.shift)
    assert_equal(@cls[], a)
    assert_nil(a.shift)
    assert_equal(@cls[], a)
  end

  def test_size
    assert_equal(0,   @cls[].size)
    assert_equal(1,   @cls[1].size)
    assert_equal(100, @cls[*(0..99).to_a].size)
  end

  def test_slice
    a = @cls[*(1..100).to_a]

    assert_equal(1, a.slice(0))
    assert_equal(100, a.slice(99))
    assert_nil(a.slice(100))
    assert_equal(100, a.slice(-1))
    assert_equal(99,  a.slice(-2))
    assert_equal(1,   a.slice(-100))
    assert_nil(a.slice(-101))

    assert_equal(@cls[1],   a.slice(0,1))
    assert_equal(@cls[100], a.slice(99,1))
    assert_equal(@cls[],    a.slice(100,1))
    assert_equal(@cls[100], a.slice(99,100))
    assert_equal(@cls[100], a.slice(-1,1))
    assert_equal(@cls[99],  a.slice(-2,1))

    assert_equal(@cls[10, 11, 12], a.slice(9, 3))
    assert_equal(@cls[10, 11, 12], a.slice(-91, 3))

    assert_equal(@cls[1],   a.slice(0..0))
    assert_equal(@cls[100], a.slice(99..99))
    assert_equal(@cls[],    a.slice(100..100))
    assert_equal(@cls[100], a.slice(99..200))
    assert_equal(@cls[100], a.slice(-1..-1))
    assert_equal(@cls[99],  a.slice(-2..-2))

    assert_equal(@cls[10, 11, 12], a.slice(9..11))
    assert_equal(@cls[10, 11, 12], a.slice(-91..-89))
    
    assert_nil(a.slice(10, -3))
    assert_nil(a.slice(10..7))
  end

  def test_slice!
    a = @cls[1, 2, 3, 4, 5]
    assert_equals(3, a.slice!(2))
    assert_equals(@cls[1, 2, 4, 5], a)

    a = @cls[1, 2, 3, 4, 5]
    assert_equals(4, a.slice!(-2))
    assert_equals(@cls[1, 2, 3, 5], a)

    a = @cls[1, 2, 3, 4, 5]
    assert_equals(@cls[3,4], a.slice!(2,2))
    assert_equals(@cls[1, 2, 5], a)

    a = @cls[1, 2, 3, 4, 5]
    assert_equals(@cls[4,5], a.slice!(-2,2))
    assert_equals(@cls[1, 2, 3], a)

    a = @cls[1, 2, 3, 4, 5]
    assert_equals(@cls[3,4], a.slice!(2..3))
    assert_equals(@cls[1, 2, 5], a)

    a = @cls[1, 2, 3, 4, 5]
    assert_equals(nil, a.slice!(20))
    assert_equals(@cls[1, 2, 3, 4, 5], a)
  end

  def test_sort
    a = @cls[ 4, 1, 2, 3 ]
    assert_equal(@cls[1, 2, 3, 4], a.sort)
    assert_equal(@cls[4, 1, 2, 3], a)

    assert_equal(@cls[4, 3, 2, 1], a.sort { |x, y| y <=> x} )
    assert_equal(@cls[4, 1, 2, 3], a)

    a.fill(1)
    assert_equal(@cls[1, 1, 1, 1], a.sort)
    
    assert_equal(@cls[], @cls[].sort)
  end

  def test_sort!
    a = @cls[ 4, 1, 2, 3 ]
    assert_equal(@cls[1, 2, 3, 4], a.sort!)
    assert_equal(@cls[1, 2, 3, 4], a)

    assert_equal(@cls[4, 3, 2, 1], a.sort! { |x, y| y <=> x} )
    assert_equal(@cls[4, 3, 2, 1], a)

    a.fill(1)
    assert_equal(@cls[1, 1, 1, 1], a.sort!)

    Version.less_than("1.7") do
      assert_nil(@cls[1].sort!)
      assert_nil(@cls[].sort!)
    end
    Version.greater_or_equal("1.7") do
      assert_equal(@cls[1], @cls[1].sort!)
      assert_equal(@cls[], @cls[].sort!)
    end
  end

  def test_to_a
    a = @cls[ 1, 2, 3 ]
    a_id = a.__id__
    assert_equal(a, a.to_a)
    assert_equal(a_id, a.to_a.__id__)
  end

  def test_to_ary
    a = [ 1, 2, 3 ]
    b = @cls[*a]

    a_id = a.__id__
    assert_equal(a, b.to_ary)
    if (@cls == Array)
      assert_equal(a_id, a.to_ary.__id__)
    end
  end

  def test_to_s
    $, = ""
    a = @cls[]
    assert_equal("", a.to_s)

    $, = ""
    a = @cls[1, 2]
    assert_equal("12", a.to_s)

    $, = ""
    a = @cls[1, 2, 3]
    assert_equal("123", a.to_s)

    $, = ":"
    a = @cls[1, 2, 3]
    assert_equal("1:2:3", a.to_s)

    $, = ""
  end

  def test_uniq
    a = @cls[ 1, 2, 3, 2, 1, 2, 3, 4, nil ]
    b = a.dup
    assert_equal(@cls[1, 2, 3, 4, nil], a.uniq)
    assert_equal(b, a)

    assert_equal(@cls[1, 2, 3], @cls[1, 2, 3].uniq)
  end

  def test_uniq!
    a = @cls[ 1, 2, 3, 2, 1, 2, 3, 4, nil ]
    assert_equal(@cls[1, 2, 3, 4, nil], a.uniq!)
    assert_equal(@cls[1, 2, 3, 4, nil], a)

    assert_nil(@cls[1, 2, 3].uniq!)
  end

  def test_unshift
    a = @cls[]
    assert_equal(@cls['cat'], a.unshift('cat'))
    assert_equal(@cls['dog', 'cat'], a.unshift('dog'))
    assert_equal(@cls[nil, 'dog', 'cat'], a.unshift(nil))
    assert_equal(@cls[@cls[1,2], nil, 'dog', 'cat'], a.unshift(@cls[1, 2]))
  end

  def test_OR # '|'
    assert_equals(@cls[],  @cls[]  | @cls[])
    assert_equals(@cls[1], @cls[1] | @cls[])
    assert_equals(@cls[1], @cls[]  | @cls[1])
    assert_equals(@cls[1], @cls[1] | @cls[1])

    assert_equals(@cls[1,2], @cls[1] | @cls[2])
    assert_equals(@cls[1,2], @cls[1, 1] | @cls[2, 2])
    assert_equals(@cls[1,2], @cls[1, 2] | @cls[1, 2])
  end

end

