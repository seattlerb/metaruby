$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZProc < Rubicon::TestCase

  def procFrom
    ZProc.new
  end

  def test_AREF # '[]'
    a = ZProc.new { |x| "hello #{x}" }
    assert_equal("hello there", a["there"])
  end

  def test_arity
    tests = [
      [ZProc.new {          }, -1],
      [ZProc.new { |x,y|    },  2],
      [ZProc.new { |x,y,z|  },  3],
      [ZProc.new { |*z|     }, -1],
      [ZProc.new { |x,*z|   }, -2],
      [ZProc.new { |x,y,*z| }, -3],
    ]

    Version.less_or_equal("1.6.1") do
      tests << 
        [ZProc.new { ||       },  -1] <<
        [ZProc.new { |x|      },  -2]
    end
    Version.greater_than("1.6.1") do
      tests <<
        [ZProc.new { ||       },  0] <<
        [ZProc.new { |x|      }, -1]
    end

    tests.each do |proc, expected_arity|
      assert_equal(expected_arity, proc.arity)
    end
  end

  def test_call
    a = ZProc.new { |x| "hello #{x}" }
    assert_equal("hello there", a.call("there"))
  end

  def test_s_new
    a = procFrom { "hello" }
    assert_equal("hello", a.call)
    a = ZProc.new { "there" }
    assert_equal("there", a.call)
  end

end

Rubicon::handleTests(TestProc) if $0 == __FILE__
