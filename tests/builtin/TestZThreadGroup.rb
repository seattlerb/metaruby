$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZThreadGroup < Rubicon::TestCase

  def test_00sanity
    tg = ZThreadGroup::Default
    assert_equal(Thread.current, tg.list[0])
  end

  def test_add
    tg = ZThreadGroup.new
    tg.add(Thread.current)
    assert_equal(1, tg.list.length)
    assert_equal(0, ZThreadGroup::Default.list.length)
    ZThreadGroup::Default.add(Thread.current)
    assert_equal(0, tg.list.length)
    assert_equal(1, ZThreadGroup::Default.list.length)
  end

  def test_list
    tg = ZThreadGroup.new
    10.times do
      Thread.critical = true
      t = Thread.new { Thread.stop }
      tg.add(t)
    end
    assert_equals(10, tg.list.length)
    tg.list.each {|t| t.wakeup; t.join }
  end

  def test_s_new
    tg = ZThreadGroup.new
    assert_equal(0, tg.list.length)
  end

end

Rubicon::handleTests(TestZThreadGroup) if $0 == __FILE__
