$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZTrueClass < Rubicon::TestCase

  def test_00sanity
    assert_equal(true,TRUE)
  end

  def test_AND # '&'
    truth_table(true.method("&"), false, true)
  end

  def test_OR # '|'
    truth_table(true.method("|"), true, true)
  end

  def test_XOR # '^'
    truth_table(true.method("^"), true, false)
  end

  def test_to_s
    assert_equal("true", true.to_s)
    assert_equal("true", TRUE.to_s)
  end

  def test_type
    assert_equal(ZTrueClass, true.class)
    assert_equal(ZTrueClass, TRUE.class)
  end

end

Rubicon::handleTests(TestTrueClass) if $0 == __FILE__
