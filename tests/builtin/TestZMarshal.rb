$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZMarshal < Rubicon::TestCase

  class A
    attr :a1
    attr :a2
    def initialize(a1, a2)
      @a1, @a2 = a1, a2
    end
  end

  class B
    attr :b1
    attr :b2
    def initialize(b1, b2)
      @b1 = A.new(b1, 2*b1)
      @b2 = b2
    end
  end

  # Dump/load to string
  def test_s_dump_load1
    b = B.new(10, "wombat")
    assert_equal(10,       b.b1.a1)
    assert_equal(20,       b.b1.a2)
    assert_equal("wombat", b.b2)

    s = ZMarshal.dump(b)

    assert_instance_of(String, s)

    newb = ZMarshal.load(s)
    assert_equal(10,       newb.b1.a1)
    assert_equal(20,       newb.b1.a2)
    assert_equal("wombat", newb.b2)

    assert(newb.__id__ != b.__id__)

    assert_exception(ArgumentError) { ZMarshal.dump(b, 1) }
  end

  def test_s_dump_load2
    b = B.new(10, "wombat")
    assert_equal(10,       b.b1.a1)
    assert_equal(20,       b.b1.a2)
    assert_equal("wombat", b.b2)

    File.open("_dl", "w") { |f| ZMarshal.dump(b, f) }
    
    begin
      newb = nil
      File.open("_dl") { |f| newb = ZMarshal.load(f) }

      assert_equal(10,       newb.b1.a1)
      assert_equal(20,       newb.b1.a2)
      assert_equal("wombat", newb.b2)
      
    ensure
      File.delete("_dl")
    end
  end

  def test_s_dump_load3
    b = B.new(10, "wombat")
    s = ZMarshal.dump(b)

    res = []
    newb = ZMarshal.load(s, proc { |obj| res << obj unless obj.kind_of?(Fixnum)})

    assert_equal(10,       newb.b1.a1)
    assert_equal(20,       newb.b1.a2)
    assert_equal("wombat", newb.b2)

    assert_set_equal([newb, newb.b1, newb.b2], res)
  end

  # there was a bug Marshaling Bignums, so

  def test_s_dump_load4
    b1 = 123456789012345678901234567890
    b2 = -123**99
    b3 = 2**32
    assert_equal(b1, ZMarshal.load(Marshal.dump(b1)))
    assert_equal(b2, ZMarshal.load(Marshal.dump(b2)))
    assert_equal(b3, ZMarshal.load(Marshal.dump(b3)))
  end

  def test_s_dump_load5
    x = [1, 2, 3, [4, 5, "foo"], {1=>"bar"}, 2.5, 9**30]
    y = ZMarshal.dump(x)
    assert_equal(x, ZMarshal.load(y))
  end

  def test_s_restore
    b = B.new(10, "wombat")
    assert_equal(10,       b.b1.a1)
    assert_equal(20,       b.b1.a2)
    assert_equal("wombat", b.b2)

    s = ZMarshal.dump(b)

    assert_instance_of(String, s)

    newb = ZMarshal.restore(s)
    assert_equal(10,       newb.b1.a1)
    assert_equal(20,       newb.b1.a2)
    assert_equal("wombat", newb.b2)

    assert(newb.__id__ != b.__id__)
  end

end

Rubicon::handleTests(TestZMarshal) if $0 == __FILE__
