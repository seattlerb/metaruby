$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

# TODO: add ZRange.to_z

class TestZRange < Rubicon::TestCase

  def test_VERY_EQUAL # '==='
    gotit = false
    case 52
      when 0..49
        assert_fail("Shouldn't have matched")
      when 50..75
        gotit = true
      else
        assert_fail("Shouldn't have matched")
    end
    assert_equal(true,gotit)

    gotit = false
    case 50
      when 0..49
        assert_fail("Shouldn't have matched")
      when 50..75
        gotit = true
      else
        assert_fail("Shouldn't have matched")
    end
    assert_equal(true,gotit)

    gotit = false
    case 75
      when 0..49
        assert_fail("Shouldn't have matched")
      when 50..75
        gotit = true
      else
        assert_fail("Shouldn't have matched")
    end
    assert_equal(true,gotit)
  end

  def test_begin
    assert_equal(1, (1..10).begin)
    assert_equal("a", ("a".."z").begin)
    assert_equal(1, (1...10).begin)
    assert_equal("a", ("a"..."z").begin)
  end

  def test_each
    index = 1
    count = 0
    (1..10).each {|x| assert_equal(index, x)
      index += 1
      count += 1 }
    assert_equal(10,count)

    index = "A"
    count = 0
    ("A".."J").each {|x| assert_equal(index, x)
      index.succ!
      count += 1 }
    assert_equal(10,count)

  end

  def test_end
    assert_equal(10, (1..10).end)
    assert_equal(11, (1...11).end)
    assert_equal("z", ("a".."z").end)
    assert_equal("A", ("a"..."A").end)
  end

  def test_exclude_end?
    assert_equal(true, (1...10).exclude_end?)
    assert_equal(false,(1..10).exclude_end?)
    assert_equal(true, ("A"..."Z").exclude_end?)
    assert_equal(false,("A".."Z").exclude_end?)
  end

  def test_first
    assert_equal(1, (1..10).first)
    assert_equal("a", ("a".."z").first)
    assert_equal(1, (1...10).first)
    assert_equal("a", ("a"..."z").first)
  end

  def test_last
    assert_equal(10, (1..10).last)
    assert_equal(11, (1...11).last)
    assert_equal("z", ("a".."z").last)
    assert_equal("A", ("a"..."A").last)
  end

  def test_length
    Version.less_than("1.7") do
      assert_equal(10, (1..10).length)
      assert_equal(10, (1...11).length)
      assert_equal(1000, (1..1000).length)
      assert_equal(26, ("A".."Z").length)
    end
  end

  def test_size
    Version.less_than("1.7") do
      assert_equal(10, (1..10).size)
      assert_equal(10, (1...11).size)
      assert_equal(1000, (1..1000).size)
      assert_equal(26, ("A".."Z").size)
    end
  end

  def test_to_s
    assert_equal("1..10",(1..10).to_s)
  end

end

Rubicon::handleTests(TestZRange) if $0 == __FILE__
