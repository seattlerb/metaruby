$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestMethods < Rubicon::TestCase

  def aaa(a, b=100, *rest)
    res = [a, b]
    res += rest if rest
    res
  end

  def testNotEnoughArguments
    assert_exception(ArgumentError) { aaa() }
    assert_exception(ArgumentError) { aaa }
  end

  def testArgumentPassing
    assert_equal([1, 100], aaa(1))
    assert_equal([1, 2], aaa(1, 2))
    assert_equal([1, 2, 3, 4], aaa(1, 2, 3, 4))
    assert_equal([1, 2, 3, 4], aaa(1, *[2, 3, 4]))
  end
end

# Run these tests if invoked directly

Rubicon::handleTests(TestMethods) if $0 == __FILE__
