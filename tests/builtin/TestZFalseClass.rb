$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZFalseClass < Rubicon::TestCase

  def test_00_sanity
    assert_equal(ZFALSE, ZFALSE)
  end

  def test_AND # '&'
    truth_table(ZFALSE.method("&"), ZFALSE, ZFALSE)
  end

  def test_OR # '|'
    truth_table(ZFALSE.method("|"), ZFALSE, ZTRUE)
  end

  def test_XOR # '^'
    truth_table(ZFALSE.method("^"), ZFALSE, ZTRUE)
  end

  def test_to_s
    assert_equal("false", ZFALSE.to_s)
    assert_equal("false", ZFALSE.to_s)
  end

  def test_type
    assert_equal(ZFalseClass, ZFALSE.class)
    assert_equal(ZFalseClass, ZFALSE.class)
  end

end

Rubicon::handleTests(TestZFalseClass) if $0 == __FILE__
