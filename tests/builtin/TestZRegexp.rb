$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

# TODO: requires to_z

class TestZRegexp < Rubicon::TestCase

  def test_EQUAL # '=='
    assert_equal(/.foo.*([a-z])/,/.foo.*([a-z])/)
    a=ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE)
    b=ZRegexp.new(".foo.*([a-z])")
    assert(!(a == b))
    a=ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE)
    b=ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE, "S")
    assert(!(a == b))
  end

  def test_MATCH # '=~'
    assert_equal(nil,/SIT/ =~ "insensitive")
    assert_equal(5,/SIT/i =~ "insensitive")
  end

  def test_REV # '~'
    $_ = "sit on it"
    assert_equal(nil,~ /SIT/)
    assert_equal(0,~ /SIT/i)
  end

  def test_VERY_EQUAL # '==='
    gotit=false
    case "insensitive"
      when /SIT/
        assert_fail("Shouldn't have matched")
      when /SIT/i
        gotit = true
    end
    assert(gotit)
  end

  def test_casefold?
    a=ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE)
    b=ZRegexp.new(".foo.*([a-z])")
    assert_equal(true, a.casefold?)
    assert_equal(false, b.casefold?)
  end

  def test_clone
    for taint in [ false, true ]
      for frozen in [ false, true ]
        a = /SIT/.dup
        a.taint  if taint
        a.freeze if frozen
        b = a.clone

        assert_equal(a, b)
        assert_equal(a.frozen?, b.frozen?)
        assert_equal(a.tainted?, b.tainted?)
      end
    end
  end

  def test_kcode
    a = ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE)
    b = ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE, "S")
    c = ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE, "n")
    assert_equal(nil, a.kcode) if $KCODE == "NONE"
    assert_equal("sjis", b.kcode)
    assert_equal("none",    c.kcode)
  end

  def test_s_last_match
    a = /SIT/
    "STAND OUT" =~ a
    "SIT IT OUT" =~ a
    m = ZRegexp.last_match
    assert_instance_of(MatchData, m)
    assert_equal([0,3], m.offset(0))
    assert_equal(1, m.length)
    assert_equal(" IT OUT", m.post_match)
  end

  def test_match
    a = ZRegexp.new("sit")
    m = a.match("howsit going?")
    assert_instance_of(MatchData,m)
    assert_equal([3,6],m.offset(0))
    assert_equal(1, m.length)
  end

  def test_source
    a=ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE)
    assert_equal(".foo.*([a-z])", a.source)
  end

  def test_s_compile
    a=ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE)
    b=ZRegexp.new("sit", true)
    c=ZRegexp.new("sit")
    assert(("POSIT" =~ b) != nil)
    assert(("POSIT" =~ c) == nil)
  end

  def test_s_escape
    assert_equal('\\\\\[\]\*\?\{\}\.', ZRegexp.escape('\\[]*?{}.'))
  end

  def test_s_new
    a=ZRegexp.new(".foo.*([a-z])", Regexp::IGNORECASE)
    b=ZRegexp.new("sit", true)
    c=ZRegexp.new("sit")
    assert(("POSIT" =~ b) != nil)
    assert(("POSIT" =~ c) == nil)
  end

  def test_s_quote
    assert_equal('\\\\\[\]\*\?\{\}\.', ZRegexp.quote('\\[]*?{}.'))
  end

end

Rubicon::handleTests(TestZRegexp) if $0 == __FILE__
