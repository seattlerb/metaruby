$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZMethod < Rubicon::TestCase

  def setup
    @m1 = 12.zmethod("+")
  end

  def test_AREF # '[]'
    assert_equal(15, @m1[3])
    assert_equal(9,  @m1[-3])
  end

  def dummy1(a, b=0, c=1)
  end

  def test_arity
    assert_equal(1, @m1.arity)
    assert_equal(0, self.zmethod("test_arity").arity)
    assert_equal(-2, self.zmethod("dummy1").arity)
    assert_equal(-1, @m1.zmethod("call").arity)
    assert_equal(-1, @m1.zmethod("respond_to?").arity)
  end

  def test_call
    assert_equal(15, @m1.call(3))
    assert_equal(9,  @m1.call(-3))
  end

  def test_to_proc
    p = @m1.to_proc
    assert_instance_of(ZProc, p)
    assert_equal(15, p.call(3))
  end

end

Rubicon::handleTests(TestZMethod) if $0 == __FILE__
