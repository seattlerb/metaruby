$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZException < Rubicon::TestCase

  MSG = "duck"

  def test_s_exception
    e = ZException.exception
    assert_equal(ZException, e.class)

    e = ZException.exception(MSG)
    assert_equal(MSG, e.message)
  end

  def test_backtrace
    assert_nil(ZException.exception.backtrace)
    begin
      line=__LINE__; file=__FILE__; raise MSG
    rescue ZRuntimeError => detail
      assert_equal(ZRuntimeError, detail.class)
      assert_equal(MSG, detail.message)
      expected = "#{file}:#{line}:in `test_backtrace'"
      assert_equal(expected, detail.backtrace[0])
    end
  end

  def test_exception
    e = ZIOError.new
    assert_equal(ZIOError, e.class)
    assert_equal(ZIOError, e.exception.class)
    assert_equal(e,       e.exception)

    e = ZIOError.new
    e1 = e.exception(MSG)
    assert_equal(ZIOError, e1.class)
    assert_equal(MSG,     e1.message)
  end

  def test_message
    e = ZIOError.new(MSG)
    assert_equal(MSG, e.message)
  end

  def test_set_backtrace
    e = ZIOError.new
    a = %w( here there everywhere )
    assert_equal(a, e.set_backtrace(a))
    assert_equal(a, e.backtrace)
  end

end

Rubicon::handleTests(TestZException) if $0 == __FILE__
