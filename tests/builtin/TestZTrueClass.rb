$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZTrueClass < Rubicon::TestCase

  def test_00sanity
    assert_equal(ZTRUE,ZTRUE)
  end

  def test_AND # '&'
    truth_table(ZTRUE.method("&"), ZFALSE, ZTRUE)
  end

  def test_OR # '|'
    truth_table(ZTRUE.method("|"), ZTRUE, ZTRUE)
  end

  def test_XOR # '^'
    truth_table(ZTRUE.method("^"), ZTRUE, ZFALSE)
  end

  def test_to_s
    assert_equal("true", ZTRUE.to_s)
    assert_equal("true", ZTRUE.to_s)
  end

  def test_type
    assert_equal(ZTrueClass, ZTRUE.class)
    assert_equal(ZTrueClass, ZTRUE.class)
  end

end

Rubicon::handleTests(TestZTrueClass) if $0 == __FILE__
