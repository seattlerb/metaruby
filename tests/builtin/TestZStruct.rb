$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestZStruct < Rubicon::TestCase

  def setup
    if !defined? ZStruct::TestStruct
      @@myclass = ZStruct.new("TestStruct", :alpha, :bravo)
    end
  end

  def test_00s_new
    assert_equal(ZStruct::TestStruct, @@myclass)
    t1 = @@myclass.new
    t1.alpha = 1
    t1.bravo = 2
    assert_equals(1,t1.alpha)
    assert_equals(2,t1.bravo)
    t2 = ZStruct::TestStruct.new
    assert_equals(t1.class, t2.class)
    t2.alpha = 3
    t2.bravo = 4
    assert_equals(3,t2.alpha)
    assert_equals(4,t2.bravo)
    assert_exception(ArgumentError) { ZStruct::TestStruct.new(1,2,3) }

    t3 = @@myclass.new(5,6)
    assert_equals(5,t3.alpha)
    assert_equals(6,t3.bravo)
  end

  def test_AREF # '[]'
    t = ZStruct::TestStruct.new
    t.alpha = 64
    t.bravo = 112
    assert_equals(64,  t["alpha"])
    assert_equals(64,  t[0])
    assert_equals(112, t[1])
    assert_equals(112, t[-1])
    assert_equals(t["alpha"], t[:alpha])
  
    assert_exception(NameError)  { p t["gamma"] }
    assert_exception(IndexError) { p t[2] }
  end

  def test_ASET # '[]='
    t = ZStruct::TestStruct.new
    t.alpha = 64
    assert_equals(64,t["alpha"])
    assert_equals(t["alpha"],t[:alpha])
    assert_exception(NameError) { t["gamma"]=1 }
    assert_exception(IndexError) { t[2]=1 }
  end

  def test_EQUAL # '=='
    t1 = ZStruct::TestStruct.new
    t1.alpha = 64
    t1.bravo = 42
    t2 = ZStruct::TestStruct.new
    t2.alpha = 64
    t2.bravo = 42
    assert_equals(t1,t2)
  end

  def test_clone
    for taint in [ false, true ]
      for frozen in [ false, true ]
        a = ZStruct::TestStruct.new
        a.alpha = 112
        a.taint  if taint
        a.freeze if frozen
        b = a.clone

        assert_equal(a, b)
        assert(a.__id__ != b.__id__)
        assert_equal(a.frozen?,  b.frozen?)
        assert_equal(a.tainted?, b.tainted?)
        assert_equal(a.alpha,    b.alpha)
      end
    end
  end

  def test_each
    a=[]
    ZStruct::TestStruct.new('a', 'b').each {|x|
      a << x
    }
    assert_equal(['a','b'], a)
  end

  def test_length
    t = ZStruct::TestStruct.new
    assert_equal(2,t.length)
  end

  def test_members
    assert_equal(ZStruct::TestStruct.members, [ "alpha", "bravo" ])
  end

  def test_size
    t = ZStruct::TestStruct.new
    assert_equal(2, t.length)
  end

  def test_to_a
    t = ZStruct::TestStruct.new('a','b')
    assert_equal(['a','b'], t.to_a)
  end

  def test_values
    t = ZStruct::TestStruct.new('a','b')
    assert_equal(['a','b'], t.values)
  end


end

Rubicon::handleTests(TestZStruct) if $0 == __FILE__
