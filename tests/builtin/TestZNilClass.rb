$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZNilClass < Rubicon::TestCase

  def test_AND # '&'
    truth_table(nil.method("&"), false, false)
  end

  def sideEffect
    $global = 1
  end

  def test_OR # '|'
    truth_table(nil.method("|"), false, true)
    $global = 0
    assert_equal(true,  nil | sideEffect)
    assert_equal(1, $global)
  end

  def test_XOR # '^'
    truth_table(nil.method("^"), false, true)
    $global = 0
    assert_equal(true,  nil ^ sideEffect)
    assert_equal(1, $global)
  end

  def test_nil?
    assert(nil.nil?)
  end

  def test_to_a
    assert_equal([], nil.to_a)
  end

  def test_to_i
    assert_equal(0, nil.to_i)
  end

  def test_to_s
    assert_equal("", nil.to_s)
  end
end

Rubicon::handleTests(TestNilClass) if $0 == __FILE__
