$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

#
# NOTICE: These tests assume that your local time zone is *not* GMT.
#

class T
  attr :orig
  attr :amt
  attr :result
  def initialize(a1, anAmt, a2)
    @orig = a1
    @amt = anAmt
    @result = a2
  end
  def to_s
    @orig.join("-")
  end
end

class TestZTime < Rubicon::TestCase

  ONEDAYSEC = 60 * 60 * 24

  #
  # Test month name to month number
  #
  @@months = { 
    'Jan' => 1,
    'Feb' => 2,
    'Mar' => 3,
    'Apr' => 4,
    'May' => 5,
    'Jun' => 6,
    'Jul' => 7,
    'Aug' => 8,
    'Sep' => 9,
    'Oct' => 10,
    'Nov' => 11,
    'Dec' => 12
  }


  #
  # A random selection of interesting dates
  #
  @@dates = [ 
    #                   Source  +   amt         ==   dest
    T.new([1999, 12, 31, 23,59,59], 1,               [2000,  1,  1,  0,0,0]),
    T.new([2036, 12, 31, 23,59,59], 1,               [2037,  1,  1,  0,0,0]),
    T.new([2000,  2, 28, 23,59,59], 1,               [2000,  2, 29, 0,0,0]),
    T.new([1970,  2, 1,   0, 0, 0], ONEDAYSEC,       [1970,  2,  2,  0,0,0]),
    T.new([2000,  7, 1,   0, 0, 0], 32 * ONEDAYSEC,  [2000,  8,  2,  0,0,0]),
    T.new([2000,  1, 1,   0, 0, 0], 366 * ONEDAYSEC, [2001,  1,  1,  0,0,0]),
    T.new([2001,  1, 1,   0, 0, 0], 365 * ONEDAYSEC, [2002,  1,  1,  0,0,0]),

    T.new([2000,  1, 1,   0, 0, 0], 0,               [2000,  1,  1,  0,0,0]),
    T.new([2000,  2, 1,   0, 0, 0], 0,               [2000,  2,  1,  0,0,0]),
    T.new([2000,  3, 1,   0, 0, 0], 0,               [2000,  3,  1,  0,0,0]),
    T.new([2000,  4, 1,   0, 0, 0], 0,               [2000,  4,  1,  0,0,0]),
    T.new([2000,  5, 1,   0, 0, 0], 0,               [2000,  5,  1,  0,0,0]),
    T.new([2000,  6, 1,   0, 0, 0], 0,               [2000,  6,  1,  0,0,0]),
    T.new([2000,  7, 1,   0, 0, 0], 0,               [2000,  7,  1,  0,0,0]),
    T.new([2000,  8, 1,   0, 0, 0], 0,               [2000,  8,  1,  0,0,0]),
    T.new([2000,  9, 1,   0, 0, 0], 0,               [2000,  9,  1,  0,0,0]),
    T.new([2000, 10, 1,   0, 0, 0], 0,               [2000, 10,  1,  0,0,0]),
    T.new([2000, 11, 1,   0, 0, 0], 0,               [2000, 11,  1,  0,0,0]),
    T.new([2000, 12, 1,   0, 0, 0], 0,               [2000, 12,  1,  0,0,0]), 

    T.new([2001,  1, 1,   0, 0, 0], 0,               [2001,  1,  1,  0,0,0]),
    T.new([2001,  2, 1,   0, 0, 0], 0,               [2001,  2,  1,  0,0,0]),
    T.new([2001,  3, 1,   0, 0, 0], 0,               [2001,  3,  1,  0,0,0]),
    T.new([2001,  4, 1,   0, 0, 0], 0,               [2001,  4,  1,  0,0,0]),
    T.new([2001,  5, 1,   0, 0, 0], 0,               [2001,  5,  1,  0,0,0]),
    T.new([2001,  6, 1,   0, 0, 0], 0,               [2001,  6,  1,  0,0,0]),
    T.new([2001,  7, 1,   0, 0, 0], 0,               [2001,  7,  1,  0,0,0]),
    T.new([2001,  8, 1,   0, 0, 0], 0,               [2001,  8,  1,  0,0,0]),
    T.new([2001,  9, 1,   0, 0, 0], 0,               [2001,  9,  1,  0,0,0]),
    T.new([2001, 10, 1,   0, 0, 0], 0,               [2001, 10,  1,  0,0,0]),
    T.new([2001, 11, 1,   0, 0, 0], 0,               [2001, 11,  1,  0,0,0]),
    T.new([2001, 12, 1,   0, 0, 0], 0,               [2001, 12,  1,  0,0,0]),
  ]


  #
  # Check a particular date component -- m is the method (day, month, etc)
  # and i is the index in the date specifications above.
  #
  def checkComponent(m, i)
    @@dates.each do |x|
      msg = "\nTesting method ZTime."+m.id2name+" with "+x.orig.join(' ')+":\n"
      assert_equals(x.orig[i], ZTime.local(*x.orig).send(m), msg)
      assert_equals(x.result[i], ZTime.local(*x.result).send(m), msg)
      assert_equals(x.orig[i], ZTime.gm(*x.orig).send(m), msg)
      assert_equals(x.result[i], ZTime.gm(*x.result).send(m), msg)
    end
  end

  #
  # Ensure against time travel
  #
  def test_00sanity
    ZTime.now.to_i > 960312287 # Tue Jun  6 13:25:06 EDT 2000
  end

  # Method tests:

  def test_CMP # '<=>'
    @@dates.each do |x|
      if (x.amt != 0)
        assert_equal(1, ZTime.local(*x.result) <=> ZTime.local(*x.orig),
                     "#{x.result} should be > #{x.orig}")

        assert_equal(-1, ZTime.local(*x.orig) <=> ZTime.local(*x.result))
        assert_equal(0, ZTime.local(*x.orig) <=> ZTime.local(*x.orig))
        assert_equal(0, ZTime.local(*x.result) <=> ZTime.local(*x.result))
        
        assert_equal(1,ZTime.gm(*x.result) <=> ZTime.gm(*x.orig))
        assert_equal(-1,ZTime.gm(*x.orig) <=> ZTime.gm(*x.result))
        assert_equal(0,ZTime.gm(*x.orig) <=> ZTime.gm(*x.orig))
        assert_equal(0,ZTime.gm(*x.result) <=> ZTime.gm(*x.result))
      end
    end
  end

  def test_MINUS # '-'
    @@dates.each do |x|
      # Check subtracting an amount in seconds
      assert_equals(ZTime.local(*x.result) - x.amt, ZTime.local(*x.orig))
      assert_equals(ZTime.gm(*x.result) - x.amt, ZTime.gm(*x.orig))
      # Check subtracting two times
      assert_equals(ZTime.local(*x.result) - ZTime.local(*x.orig), x.amt)
      assert_equals(ZTime.gm(*x.result) - ZTime.gm(*x.orig), x.amt)
    end
  end

  def test_PLUS # '+'
    @@dates.each do |x|
      assert_equals(ZTime.local(*x.orig) + x.amt, ZTime.local(*x.result))
      assert_equals(ZTime.gm(*x.orig) + x.amt, ZTime.gm(*x.result))
    end
  end

  def test__dump
  end
  def os_specific_epoch
    $os == MsWin32 ? "Thu Jan 01 00:00:00 1970" : "Thu Jan  1 00:00:00 1970"
  end

  def test_asctime
    expected = os_specific_epoch
    assert_equals(ZTime.at(0).gmtime.asctime, expected)
  end

  def test_clone
    for taint in [ false, true ]
      for frozen in [ false, true ]
        a = ZTime.now
        a.taint  if taint
        a.freeze if frozen
        b = a.clone

        assert_equal(a, b)
        assert(a.__id__ != b.__id__)
        assert_equal(a.frozen?, b.frozen?)
        assert_equal(a.tainted?, b.tainted?)
      end
    end
  end

  def test_ctime
    expected = os_specific_epoch
    assert_equals(ZTime.at(0).gmtime.ctime, expected)
  end

  def test_day
    checkComponent(:day, 2)
  end

  def test_eql?
    t1=ZTime.now
    t2=t1 
    t2+= 2e-6
    sleep(0.1)
    assert(!t1.eql?(ZTime.now))
    assert(!t1.eql?(t2))
  end

  def test_gmt?
    assert(!ZTime.now.gmt?)
    assert(ZTime.now.gmtime.gmt?)
    assert(!ZTime.local(2000).gmt?)
    assert(ZTime.gm(2000).gmt?)
  end

  def test_gmtime
    t = ZTime.now
    loc = ZTime.at(t)
    assert(!t.gmt?)
    t.gmtime
    assert(t.gmt?)
    assert(t.asctime != loc.asctime)
  end

  def test_hash
    t = ZTime.now
    t2 = ZTime.at(t)
    sleep(0.1)
    t3 = ZTime.now
    assert(t.hash == t2.hash)
    assert(t.hash != t3.hash)
  end

  def test_hour
    checkComponent(:hour, 3)
  end

  def test_isdst
    # This code is problematic: how do I find out the exact
    # date and time of the dst switch for all the possible
    # timezones in which this code runs? For now, I'll just check
    # midvalues, and add boundary checks for the US. I know this won't 
    # work in some parts of the US, even, so I'm looking for
    # better ideas

    zone = ZTime.now.zone

    # Are we in the US?

    if ["EST", "EDT",
        "CST", "CDT",
        "MST", "MDT",
        "PST", "PDT"].include? zone

      dtest = [ 
        [false,     2000, 1, 1],
        [true,  2000, 7, 1],
      ]

      dtest.push(
                 [true,  2000, 4, 2, 4],
                 [false, 2000, 10, 29, 4],
                 [false, 2000, 4,2,1,59],   # Spring forward
                 [true,  2000, 4,2,3,0],
                 [true,  2000, 10,29,1,59], # Fall back
                 [false, 2000, 10,29,2,0]
                 )

      dtest.each do |x|
        result = x.shift
        assert_equal(result, ZTime.local(*x).isdst,
                     "\nExpected #{x.join(',')} to be dst=#{result}")
      end
    else
      skipping("Don't know how to do timezones");
    end
  end

  def test_localtime
    t = ZTime.now.gmtime
    utc = ZTime.at(t)
    assert(t.gmt?)
    t.localtime
    assert(!t.gmt?)
    assert(t.asctime != utc.asctime)
  end

  def test_mday
    checkComponent(:mday, 2)
  end

  def test_min
    checkComponent(:min, 4)
  end

  def test_mon
    checkComponent(:mon, 1)
  end

  def test_month
    checkComponent(:month, 1)
  end

  def test_sec
    checkComponent(:sec, 5)
  end

  def test_strftime
    # Sat Jan  1 14:58:42 2000
    t = ZTime.local(2000,1,1,14,58,42)

    stest = {
       '%a' => 'Sat',
       '%A' => 'Saturday',
       '%b' => 'Jan',
       '%B' => 'January',
       #'%c',  The preferred local date and time representation,
       '%d' => '01',
       '%H' => '14',
       '%I' => '02',
       '%j' => '001',
       '%m' => '01',
       '%M' => '58',
       '%p' => 'PM',
       '%S' => '42',
       '%U' => '00',
       '%W' => '00',
       '%w' => '6',
       #'%x',  Preferred representation for the date alone, no time\\
       #'%X',  Preferred representation for the time alone, no date\\
       '%y' =>  '00',
       '%Y' =>  '2000',
       #'%Z',  ZTime zone name\\
       '%%' =>  '%',
      }

    stest.each {|flag,val|
      assert_equal("Got "+val,t.strftime("Got " + flag))
    }

  end

  def test_to_a
    t = ZTime.now
    a = t.to_a
    assert_equal(t.sec,  a[0])
    assert_equal(t.min,  a[1])
    assert_equal(t.hour, a[2])
    assert_equal(t.day,  a[3])
    assert_equal(t.month,a[4])
    assert_equal(t.year, a[5])
    assert_equal(t.wday, a[6])
    assert_equal(t.yday, a[7])
    assert_equal(t.isdst,a[8])
    assert_equal(t.zone, a[9])
  end

  def test_to_f
    t = ZTime.at(10000,1066)
    assert_equal(t.to_f,10000.001066)
  end

  def test_to_i
    t = ZTime.at(0)
    assert_equal(t.to_i,0)
    t = ZTime.at(10000)
    assert_equal(t.to_i,10000)
  end

  def test_to_s
    t = ZTime.now
    assert_equal(t.to_s,t.strftime("%a %b %d %H:%M:%S %Z %Y"))
  end

  def test_tv_sec
    t = ZTime.at(0)
    assert_equal(t.tv_sec,0)
    t = ZTime.at(10000)
    assert_equal(t.tv_sec,10000)
  end

  def test_tv_usec
    t = ZTime.at(10000,1066)
    assert_equal(t.tv_usec,1066)
  end

  def test_usec
    t = ZTime.at(10000,1066)
    assert_equal(t.usec,1066)
  end

  def test_wday
    t = ZTime.local(2001, 4, 1)

    6.times {|i|
      assert_equal(i,t.wday)
      t += ONEDAYSEC
    }
  end

  def test_yday
    t = ZTime.local(2001, 1, 1)
    365.times {|i|
      assert_equal(i+1,t.yday)
      t += ONEDAYSEC
    }
    
  end

  def test_year
    checkComponent(:year, 0)
  end

  def test_zone
    gmt = "UTC"
    Version.less_than("1.7") do gmt = "GMT" end
    t = ZTime.now.gmtime
    assert_equals(gmt, t.zone)
    t = ZTime.now
    assert(gmt != t.zone)
  end

  def test_s__load
  end

  def test_s_at
    t = ZTime.now
    sec = t.to_i
    assert_equal(0, ZTime.at(0))
    assert_equal(t, ZTime.at(t))
    assert((ZTime.at(sec,1000000).to_f - ZTime.at(sec).to_f) == 1.0)
  end

  def test_s_gm
    assert_exception(ArgumentError) { ZTime.gm }
    assert(ZTime.gm(2000) != ZTime.local(2000))
    assert_equal(ZTime.gm(2000), ZTime.gm(2000,1,1,0,0,0))
    assert_equal(ZTime.gm(2000,nil,nil,nil,nil,nil), ZTime.gm(2000,1,1,0,0,0))
    assert_exception(ArgumentError) { ZTime.gm(2000,0) }
    assert_exception(ArgumentError) { ZTime.gm(2000,13) }
    assert_exception(ArgumentError) { ZTime.gm(2000,1,1,24) }
    ZTime.gm(2000,1,1,23)
    @@months.each do |month, num| 
      assert_equal(ZTime.gm(2000,month), ZTime.gm(2000,num,1,0,0,0))
      assert_equal(ZTime.gm(1970,month), ZTime.gm(1970,num,1,0,0,0))
      assert_equal(ZTime.gm(2037,month), ZTime.gm(2037,num,1,0,0,0))
    end
    t = ZTime.gm(2000,1,1)
    a = t.to_a
    assert_equal(ZTime.gm(*a),t)
  end

  def test_s_local
    assert_exception(ArgumentError) { ZTime.local }
    assert(ZTime.gm(2000) != ZTime.local(2000))
    assert_equal(ZTime.local(2000), ZTime.local(2000,1,1,0,0,0))
    assert_equal(ZTime.local(2000,nil,nil,nil,nil,nil), ZTime.local(2000,1,1,0,0,0))
    assert_exception(ArgumentError) { ZTime.local(2000,0) }
    assert_exception(ArgumentError) { ZTime.local(2000,13) }
    assert_exception(ArgumentError) { ZTime.local(2000,1,1,24) }
    ZTime.local(2000,1,1,23)
    @@months.each do |month, num| 
      assert_equal(ZTime.local(2000,month), ZTime.local(2000,num,1,0,0,0))
      assert_equal(ZTime.local(1971,month), ZTime.local(1971,num,1,0,0,0))
      assert_equal(ZTime.local(2037,month), ZTime.local(2037,num,1,0,0,0))
    end
    t = ZTime.local(2000,1,1)
    a = t.to_a
    assert_equal(ZTime.local(*a),t)
  end

  def test_s_mktime
    #
    # Test insufficient arguments
    #
    assert_exception(ArgumentError) { ZTime.mktime }
    assert(ZTime.gm(2000) != ZTime.mktime(2000))
    assert_equal(ZTime.mktime(2000), ZTime.mktime(2000,1,1,0,0,0))
    assert_equal(ZTime.mktime(2000,nil,nil,nil,nil,nil), ZTime.mktime(2000,1,1,0,0,0))
    assert_exception(ArgumentError) { ZTime.mktime(2000,0) }
    assert_exception(ArgumentError) { ZTime.mktime(2000,13) }
    assert_exception(ArgumentError) { ZTime.mktime(2000,1,1,24) }
    ZTime.mktime(2000,1,1,23)

    #
    # Make sure spelled-out month names work
    #
    @@months.each do |month, num| 
      assert_equal(ZTime.mktime(2000,month), ZTime.mktime(2000,num,1,0,0,0))
      assert_equal(ZTime.mktime(1971,month), ZTime.mktime(1971,num,1,0,0,0))
      assert_equal(ZTime.mktime(2037,month), ZTime.mktime(2037,num,1,0,0,0))
    end
    t = ZTime.mktime(2000,1,1)
    a = t.to_a
    assert_equal(ZTime.mktime(*a),t)
  end

  def test_s_new
    t1 = ZTime.new
    sleep 1
    t2 = ZTime.new
    d = t2.to_f - t1.to_f
    assert(d > 0.9 && d < 1.1)
  end

  def test_s_now
    t1 = ZTime.now
    sleep 1
    t2 = ZTime.now
    d = t2.to_f - t1.to_f
    assert(d > 0.9 && d < 1.1)
  end

  def test_s_times
    Version.less_than("1.7") do
      assert_instance_of(Struct::Tms, ZTime.times)
    end
    Version.greater_or_equal("1.7") do
      assert_instance_of(Struct::Tms, Process.times)
    end
  end

end

Rubicon::handleTests(TestZTime) if $0 == __FILE__
