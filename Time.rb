require 'libcwrap'

class Time

  MONTHS = { 
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

  attr_accessor :vals
  attr_accessor :tv_sec
  attr_accessor :tv_usec
  attr_accessor :utc_offset
  attr_accessor :dsttime
  attr_accessor :_utc

  # indices into values from self.to_a:
  IDX_SECOND = 0
  IDX_MINUTE = 1
  IDX_HOUR = 2
  IDX_DAY = 3
  IDX_MONTH = 4
  IDX_YEAR = 5
  IDX_WDAY = 6
  IDX_YDAY = 7
  IDX_ISDST = 8
  IDX_ZONE = 9

  ##
  # call-seq:
  #   Time._load(string)   => time
  #
  # Unmarshal a dumped <tt>Time</tt> object.

  def self._load(arg1)
    raise "not implemented yet"
  end

  ##
  # call-seq:
  #   Time.at( aTime ) => time
  #   Time.at( seconds [, microseconds] ) => time
  #
  # Creates a new time object with the value given by <em>aTime</em>, or
  # the given number of <em>seconds</em> (and optional
  # <em>microseconds</em>) from epoch. A non-portable feature allows the
  # offset to be negative on some systems.
  #
  #    Time.at(0)            #=> Wed Dec 31 18:00:00 CST 1969
  #    Time.at(946702800)    #=> Fri Dec 31 23:00:00 CST 1999
  #    Time.at(-284061600)   #=> Sat Dec 31 00:00:00 CST 1960

  def self.at(t, ms=nil)
    r = self.allocate
    r._utc  = false

    case t
    when Time then
      raise ArgumentError, "wrong number of arguments (2 for 1) (tee hee)" unless ms.nil?
      r.tv_sec  = t.tv_sec
      r.tv_usec = t.tv_usec
      r.vals    = t.vals.dup
      r._utc    = t._utc
    when Fixnum, Bignum then
      r.vals = LIBC.new.c_localtime(t)
      r.tv_sec = t
      r.tv_usec = ms.nil? ? 0 : ms
    when Float then
      t2, ms2 = t.divmod(1.0)
      r.vals = LIBC.new.c_localtime(t2)
      r.tv_sec = t2
      r.tv_usec = ms.nil? ? (ms2 * 1e6) : ms
    else
      raise "wtf?: #{t.inspect}:#{t.class}"
    end
    return r
  end

  ##
  # call-seq:
  #   Time.local( year [, month, day, hour, min, sec, usec] ) => time
  #   Time.local( sec, min, hour, day, month, year, wday, yday, isdst, tz ) => time
  #   Time.mktime( year, month, day, hour, min, sec, usec )   => time
  #
  # Same as <tt>Time::gm</tt>, but interprets the values in the local
  # time zone.
  #
  #    Time.local(2000,"jan",1,20,15,1)   #=> Sat Jan 01 20:15:01 CST 2000

  def self.mktime(*a)
    args = a.dup
    case args.size
    when 1..7 then
      default_args = [nil, 1, 1, 0, 0, 0, 0] # filler, month, day, hour, min, sec, usec
      args.push(*default_args[args.size..-1])
      args.each_with_index do |n,i|
        case i
        when 1
          args[i] = default_args[i] if n.nil?
          args[i] = MONTHS[args[i]] if MONTHS.has_key?(args[i])
        else
          args[i] = default_args[i] if n.nil?
        end
      end

      raise ArgumentError, "argument out of range" unless (1..12).include? args[1] # month
      raise ArgumentError, "argument out of range" unless (0..31).include? args[2] # day
      raise ArgumentError, "argument out of range" unless (0..23).include? args[3] # hour
      raise ArgumentError, "argument out of range" unless (0..59).include? args[4] # min
      raise ArgumentError, "argument out of range" unless (0..59).include? args[5] # sec
      
    when 10 then
      args = args[0..5].reverse
      args.push 0
    else
      raise ArgumentError, "Unknown arg size #{args.size}"
    end

    usec = args.pop
    time_t = LIBC.new.c_mktime(*args)
    result = self.at(time_t)
    result.tv_usec = usec
    return result
  end

  ##
  # call-seq:
  #   Time.new -> time
  #
  # Document-method: now
  #
  # Synonym for <tt>Time.new</tt>. Returns a <tt>Time</tt> object
  # initialized tot he current system time.
  #
  # Returns a <tt>Time</tt> object initialized to the current system
  # time. <b>Note:</b> The object created will be created using the
  # resolution available on your system clock, and so may include
  # fractional seconds.
  #
  #    a = Time.new      #=> Wed Apr 09 08:56:03 CDT 2003
  #    b = Time.new      #=> Wed Apr 09 08:56:03 CDT 2003
  #    a == b            #=> false
  #    "%.6f" % a.to_f   #=> "1049896563.230740"
  #    "%.6f" % b.to_f   #=> "1049896563.231466"

  def self.now
    return self.new
  end

  ##
  # call-seq:
  #   Time.times => struct_tms
  #
  # Deprecated in favor of <tt>Process::times</tt>

  def self.times
    return Process.times
  end

  ##
  # call-seq:
  #   Time.utc( year [, month, day, hour, min, sec, usec] ) => time
  #   Time.utc( sec, min, hour, day, month, year, wday, yday, isdst, tz) => time
  #   Time.gm( year [, month, day, hour, min, sec, usec] ) => time
  #   Time.gm( sec, min, hour, day, month, year, wday, yday, isdst, tz) => time
  #
  # Creates a time based on given values, interpreted as UTC (GMT). The
  # year must be specified. Other values default to the minimum value
  # for that field (and may be <tt>nil</tt> or omitted). Months may be
  # specified by numbers from 1 to 12, or by the three-letter English
  # month names. Hours are specified on a 24-hour clock (0..23). Raises
  # an <tt>ArgumentError</tt> if any values are out of range. Will also
  # accept ten arguments in the order output by <tt>Time#to_a</tt>.
  #
  #    Time.utc(2000,"jan",1,20,15,1)  #=> Sat Jan 01 20:15:01 UTC 2000
  #    Time.gm(2000,"jan",1,20,15,1)   #=> Sat Jan 01 20:15:01 UTC 2000

  def self.utc(*a)
    args = a.dup
    case args.size
    when 1..7 then
      default_args = [nil, 1, 1, 0, 0, 0, 0] # filler, month, day, hour, min, sec, usec
      args.push(*default_args[args.size..-1])
      args.each_with_index do |n,i|
        case i
        when 1
          args[i] = default_args[i] if n.nil?
          args[i] = MONTHS[args[i]] if MONTHS.has_key?(args[i])
        else
          args[i] = default_args[i] if n.nil?
        end
      end

      raise ArgumentError, "argument out of range" unless (1..12).include? args[1] # month
      raise ArgumentError, "argument out of range" unless (0..31).include? args[2] # day
      raise ArgumentError, "argument out of range" unless (0..23).include? args[3] # hour
      raise ArgumentError, "argument out of range" unless (0..59).include? args[4] # min
      raise ArgumentError, "argument out of range" unless (0..59).include? args[5] # sec
      
    when 10 then
      args = args[0..5].reverse
      args.push 0
    else
      raise ArgumentError, "Unknown arg size #{args.size}"
    end

    usec = args.pop
    time_t = LIBC.new.c_timegm(*args)

    result = self.allocate
    result._utc  = true
    result.vals = LIBC.new.c_gmtime(time_t)
    result.tv_sec = time_t
    result.tv_usec = usec

    return result
  end

  ##
  # call-seq:
  #   Time.new -> time
  #
  # Synonym for <tt>Time.new</tt>. Returns a <tt>Time</tt> object
  # initialized tot he current system time.
  #
  # Returns a <tt>Time</tt> object initialized to the current system
  # time. <b>Note:</b> The object created will be created using the
  # resolution available on your system clock, and so may include
  # fractional seconds.
  #
  #    a = Time.new      #=> Wed Apr 09 08:56:03 CDT 2003
  #    b = Time.new      #=> Wed Apr 09 08:56:03 CDT 2003
  #    a == b            #=> false
  #    "%.6f" % a.to_f   #=> "1049896563.230740"
  #    "%.6f" % b.to_f   #=> "1049896563.231466"

  def initialize
    t = LIBC.new.c_gettimeofday
    @tv_sec = t[0]
    @tv_usec = t[1]
    @utc_offset = t[2]
    @dsttime = t[3]
    @_utc = false
    @vals = LIBC.new.c_localtime(@tv_sec)
  end

  class << self
    alias :gm :utc
    alias :local :mktime
  end
  
  ############################################################
  # Instance Methods:

  ##
  # call-seq:
  #   time + numeric => time
  #
  # Addition---Adds some number of seconds (possibly fractional) to
  # <em>time</em> and returns that value as a new time.
  #
  #    t = Time.now         #=> Wed Apr 09 08:56:03 CDT 2003
  #    t + (60 * 60 * 24)   #=> Thu Apr 10 08:56:03 CDT 2003

  def +(o)
    offset = Time.now.utc_offset
    case o
    when Integer then
      if @_utc then
        return Time.at(@tv_sec + o, @tv_usec).utc
      else
        return Time.at(@tv_sec + o, @tv_usec)
      end
    when Float then
      s, u = o.divmod(1.0)
      if @_utc then
        return Time.at(@tv_sec + s, @tv_usec + (u * 1e6).to_i).utc
      else
        return Time.at(@tv_sec + s, @tv_usec + (u * 1e6).to_i)
      end
    else
      raise "wtf?: #{t.inspect}:#{t.class}"
    end
  end

  ##
  # call-seq:
  #   time - other_time => float
  #   time - numeric    => time
  #
  # Difference---Returns a new time that represents the difference
  # between two times, or subtracts the given number of seconds in
  # <em>numeric</em> from <em>time</em>.
  #
  #    t = Time.now       #=> Wed Apr 09 08:56:03 CDT 2003
  #    t2 = t + 2592000   #=> Fri May 09 08:56:03 CDT 2003
  #    t2 - t             #=> 2592000.0
  #    t2 - 2592000       #=> Wed Apr 09 08:56:03 CDT 2003

  def -(o)
    case o
    when Fixnum, Bignum, Float then
      return self + -o
    when Time
      return self.to_f - o.to_f
    else
      raise "wtf?: #{t.inspect}:#{t.class}"
    end
  end

  ##
  # call-seq:
  #   time <=> other_time => -1, 0, +1 
  #   time <=> numeric    => -1, 0, +1
  #
  # Comparison---Compares <em>time</em> with <em>other_time</em> or with
  # <em>numeric</em>, which is the number of seconds (possibly
  # fractional) since epoch.
  #
  #    t = Time.now       #=> Wed Apr 09 08:56:03 CDT 2003
  #    t2 = t + 2592000   #=> Fri May 09 08:56:03 CDT 2003
  #    t <=> t2           #=> -1
  #    t2 <=> t           #=> 1
  #    t <=> t            #=> 0

  def <=>(other)
    cmp = @tv_sec <=> other.tv_sec
    return cmp unless cmp == 0
    return @tv_usec <=> other.tv_usec
  end

  ##
  # call-seq:
  #   time._dump   => string
  #
  # Dump <em>time</em> for marshaling.

  def _dump(*args)
    raise "not implemented yet"
  end

  ##
  # call-seq:
  #   time.asctime => string
  #   time.ctime   => string
  #
  # Returns a canonical string representation of <em>time</em>.
  #
  #    Time.now.asctime   #=> "Wed Apr  9 08:56:03 2003"

  def asctime
    format = 
      if @_utc then
        "%a %b %e %H:%M:%S %Y"
      else
        "%a %b %e %H:%M:%S %Y"
      end
    return LIBC.new.c_strftime(format, @vals)
  end

  ##
  # call-seq:
  #   time.day  => fixnum
  #   time.mday => fixnum
  #
  # Returns the day of the month (1..n) for <em>time</em>.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:03 CDT 2003
  #    t.day          #=> 9
  #    t.mday         #=> 9

  def day
    return self.to_a[IDX_DAY]
  end

  ##
  # call-seq:
  #   time.isdst => true or false
  #   time.dst?  => true or false
  #
  # Returns <tt>true</tt> if <em>time</em> occurs during Daylight Saving
  # Time in its time zone.
  #
  #    Time.local(2000, 7, 1).isdst   #=> true
  #    Time.local(2000, 1, 1).isdst   #=> false
  #    Time.local(2000, 7, 1).dst?    #=> true
  #    Time.local(2000, 1, 1).dst?    #=> false

  def dst?
    return self.to_a[IDX_ISDST]
  end

  ##
  # call-seq:
  #   time.eql?(other_time)
  #
  # Return <tt>true</tt> if <em>time</em> and <em>other_time</em> are
  # both <tt>Time</tt> objects with the same seconds and fractional
  # seconds.

  def eql?(other)
    return self.to_i == other.to_i && self.usec == other.usec
  end

  ##
  # call-seq:
  #   time.getlocal => new_time
  #
  # Returns a new <tt>new_time</tt> object representing <em>time</em> in
  # local time (using the local time zone in effect for this process).
  #
  #    t = Time.gm(2000,1,1,20,15,1)   #=> Sat Jan 01 20:15:01 UTC 2000
  #    t.gmt?                          #=> true
  #    l = t.getlocal                  #=> Sat Jan 01 14:15:01 CST 2000
  #    l.gmt?                          #=> false
  #    t == l                          #=> true

  def getlocal
    return Time.at(self).localtime
  end

  ##
  # call-seq:
  #   time.getgm  => new_time
  #   time.getutc => new_time
  #
  # Returns a new <tt>new_time</tt> object representing <em>time</em> in
  # UTC.
  #
  #    t = Time.local(2000,1,1,20,15,1)   #=> Sat Jan 01 20:15:01 CST 2000
  #    t.gmt?                             #=> false
  #    y = t.getgm                        #=> Sun Jan 02 02:15:01 UTC 2000
  #    y.gmt?                             #=> true
  #    t == y                             #=> true

  def getutc
    return Time.at(self).utc
  end

  ##
  # call-seq:
  #   time.hash   => fixnum
  #
  # Return a hash code for this time object.

  def hash
    self.to_f.hash
  end

  ##
  # call-seq:
  #   time.hour => fixnum
  #
  # Returns the hour of the day (0..23) for <em>time</em>.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:03 CDT 2003
  #    t.hour         #=> 8

  def hour
    return self.to_a[IDX_HOUR]
  end

  ##
  # call-seq:
  #   time.inspect => string
  #   time.to_s    => string
  #
  # Returns a string representing <em>time</em>. Equivalent to calling
  # <tt>Time#strftime</tt> with a format string of ``<tt>%a</tt>
  # <tt>%b</tt> <tt>%d</tt> <tt>%H:%M:%S</tt> <tt>%Z</tt> <tt>%Y</tt>''.
  #
  #    Time.now.to_s   #=> "Wed Apr 09 08:56:04 CDT 2003"

  def inspect
    return self.to_s
  end

  ##
  # call-seq:
  #   time.localtime => time
  #
  # Converts <em>time</em> to local time (using the local time zone in
  # effect for this process) modifying the receiver.
  #
  #    t = Time.gm(2000, "jan", 1, 20, 15, 1)
  #    t.gmt?        #=> true
  #    t.localtime   #=> Sat Jan 01 14:15:01 CST 2000
  #    t.gmt?        #=> false

  def localtime
    if @_utc then
      @tv_sec += self.utc_offset
      @_utc = false
      @vals = LIBC.new.c_localtime(@tv_sec)
    end
    return self
  end

  ##
  # call-seq:
  #   time.day  => fixnum
  #   time.mday => fixnum
  #
  # Returns the day of the month (1..n) for <em>time</em>.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:03 CDT 2003
  #    t.day          #=> 9
  #    t.mday         #=> 9

  def mday
    return self.to_a[IDX_DAY]
  end

  ##
  # call-seq:
  #   time.min => fixnum
  #
  # Returns the minute of the hour (0..59) for <em>time</em>.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:03 CDT 2003
  #    t.min          #=> 56

  def min
    return self.to_a[IDX_MINUTE]
  end

  ##
  # call-seq:
  #   time.mon   => fixnum
  #   time.month => fixnum
  #
  # Returns the month of the year (1..12) for <em>time</em>.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:03 CDT 2003
  #    t.mon          #=> 4
  #    t.month        #=> 4

  def month
    return self.to_a[IDX_MONTH]
  end

  ##
  # call-seq:
  #   time.sec => fixnum
  #
  # Returns the second of the minute (0..60)<em>[Yes, seconds really can
  # range from zero to 60. This allows the system to inject leap seconds
  # every now and then to correct for the fact that years are not really
  # a convenient number of hours long.]</em> for <em>time</em>.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:04 CDT 2003
  #    t.sec          #=> 4

  def sec
    return self.to_a[IDX_SECOND]
  end

  ##
  # call-seq:
  #   time.strftime( string ) => string
  #
  # Formats <em>time</em> according to the directives in the given
  # format string. Any text not listed as a directive will be passed
  # through to the output string.
  #
  # Format meaning:
  #
  #   %a - The abbreviated weekday name (``Sun'')
  #   %A - The  full  weekday  name (``Sunday'')
  #   %b - The abbreviated month name (``Jan'')
  #   %B - The  full  month  name (``January'')
  #   %c - The preferred local date and time representation
  #   %d - Day of the month (01..31)
  #   %H - Hour of the day, 24-hour clock (00..23)
  #   %I - Hour of the day, 12-hour clock (01..12)
  #   %j - Day of the year (001..366)
  #   %m - Month of the year (01..12)
  #   %M - Minute of the hour (00..59)
  #   %p - Meridian indicator (``AM''  or  ``PM'')
  #   %S - Second of the minute (00..60)
  #   %U - Week  number  of the current year,
  #           starting with the first Sunday as the first
  #           day of the first week (00..53)
  #   %W - Week  number  of the current year,
  #           starting with the first Monday as the first
  #           day of the first week (00..53)
  #   %w - Day of the week (Sunday is 0, 0..6)
  #   %x - Preferred representation for the date alone, no time
  #   %X - Preferred representation for the time alone, no date
  #   %y - Year without a century (00..99)
  #   %Y - Year with century
  #   %Z - Time zone name
  #   %% - Literal ``%'' character
  #    t = Time.now
  #    t.strftime("Printed on %m/%d/%Y")   #=> "Printed on 04/09/2003"
  #    t.strftime("at %I:%M%p")            #=> "at 08:56AM"

  def strftime(format)
    return LIBC.new.c_strftime(format, @vals)
  end

  ##
  # call-seq:
  #   time.succ   => new_time
  #
  # Return a new time object, one second later than <tt>time</tt>.

  def succ
    return self + 1
  end

  ##
  # call-seq:
  #   time.to_a => array
  #
  # Returns a ten-element <em>array</em> of values for <em>time</em>:
  # {<tt>[ sec, min, hour, day, month, year, wday, yday, isdst, zone
  # ]</tt>}. See the individual methods for an explanation of the valid
  # ranges of each value. The ten elements can be passed directly to
  # <tt>Time::utc</tt> or <tt>Time::local</tt> to create a new
  # <tt>Time</tt>.
  #
  #    now = Time.now   #=> Wed Apr 09 08:56:04 CDT 2003
  #    t = now.to_a     #=> [4, 56, 8, 9, 4, 2003, 3, 99, true, "CDT"]

  def to_a
    return @vals
  end

  ##
  # call-seq:
  #   time.to_f => float
  #
  # Returns the value of <em>time</em> as a floating point number of
  # seconds since epoch.
  #
  #    t = Time.now
  #    "%10.5f" % t.to_f   #=> "1049896564.13654"
  #    t.to_i              #=> 1049896564

  def to_f
    return @tv_sec.to_f + (@tv_usec / 1e6)
  end

  ##
  # call-seq:
  #   time.to_i   => int
  #   time.tv_sec => int
  #
  # Returns the value of <em>time</em> as an integer number of seconds
  # since epoch.
  #
  #    t = Time.now
  #    "%10.5f" % t.to_f   #=> "1049896564.17839"
  #    t.to_i              #=> 1049896564

  def to_i
    return @tv_sec
  end

  ##
  # call-seq:
  #   time.inspect => string
  #   time.to_s    => string
  #
  # Returns a string representing <em>time</em>. Equivalent to calling
  # <tt>Time#strftime</tt> with a format string of ``<tt>%a</tt>
  # <tt>%b</tt> <tt>%d</tt> <tt>%H:%M:%S</tt> <tt>%Z</tt> <tt>%Y</tt>''.
  #
  #    Time.now.to_s   #=> "Wed Apr 09 08:56:04 CDT 2003"

  def to_s
    format = 
      if @_utc then
        "%a %b %d %H:%M:%S UTC %Y"
      else
        "%a %b %d %H:%M:%S %Z %Y"
      end
    return LIBC.new.c_strftime(format, @vals)
  end

  ##
  # call-seq:
  #   time.to_i   => int
  #   time.tv_sec => int
  #
  # Returns the value of <em>time</em> as an integer number of seconds
  # since epoch.
  #
  #    t = Time.now
  #    "%10.5f" % t.to_f   #=> "1049896564.17839"
  #    t.to_i              #=> 1049896564

  def tv_sec
    return @tv_sec
  end

  ##
  # call-seq:
  #   time.usec    => int
  #   time.tv_usec => int
  #
  # Returns just the number of microseconds for <em>time</em>.
  #
  #    t = Time.now        #=> Wed Apr 09 08:56:04 CDT 2003
  #    "%10.6f" % t.to_f   #=> "1049896564.259970"
  #    t.usec              #=> 259970

  def tv_usec
    return @tv_usec
  end

  ##
  # call-seq:
  #   time.gmtime    => time
  #   time.utc       => time
  #
  # Converts <em>time</em> to UTC (GMT), modifying the receiver.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:03 CDT 2003
  #    t.gmt?         #=> false
  #    t.gmtime       #=> Wed Apr 09 13:56:03 UTC 2003
  #    t.gmt?         #=> true
  #    t = Time.now   #=> Wed Apr 09 08:56:04 CDT 2003
  #    t.utc?         #=> false
  #    t.utc          #=> Wed Apr 09 13:56:04 UTC 2003
  #    t.utc?         #=> true

  def utc
    unless @_utc then
      @_utc = true
      @vals = LIBC.new.c_gmtime(@tv_sec)
    end
    return self # .to_i # TOTAL FUCKING HACK
  end

  ##
  # call-seq:
  #   time.utc? => true or false
  #   time.gmt? => true or false
  #
  # Returns <tt>true</tt> if <em>time</em> represents a time in UTC
  # (GMT).
  #
  #    t = Time.now                        #=> Wed Apr 09 08:56:04 CDT 2003
  #    t.utc?                              #=> false
  #    t = Time.gm(2000,"jan",1,20,15,1)   #=> Sat Jan 01 20:15:01 UTC 2000
  #    t.utc?                              #=> true
  #    t = Time.now                        #=> Wed Apr 09 08:56:03 CDT 2003
  #    t.gmt?                              #=> false
  #    t = Time.gm(2000,1,1,20,15,1)       #=> Sat Jan 01 20:15:01 UTC 2000
  #    t.gmt?                              #=> true

  def utc?
    raise "undefined @_utc" unless defined? @_utc
    return @_utc
  end

  ##
  # call-seq:
  #   time.gmt_offset => fixnum
  #   time.gmtoff     => fixnum
  #   time.utc_offset => fixnum
  #
  # Returns the offset in seconds between the timezone of <em>time</em>
  # and UTC.
  #
  #    t = Time.gm(2000,1,1,20,15,1)   #=> Sat Jan 01 20:15:01 UTC 2000
  #    t.gmt_offset                    #=> 0
  #    l = t.getlocal                  #=> Sat Jan 01 14:15:01 CST 2000
  #    l.gmt_offset                    #=> -21600

  def utc_offset
    return 0 if @_utc

    utc = self.getutc

    off = self.year != utc.year ? (self.year < utc.year ? 1 : 0) : -1
    off = self.mon  != utc.mon  ? (self.mon  < utc.mon ? 1 : 0) : -1 if off < 0
    off = self.mday != utc.mday ? (self.mday < utc.mday ? 1 : 0) : -1 if off < 0

    off = off < 0 ? 0 : off != 0 ? -1 : 1

    off = off * 24 + self.hour - utc.hour
    off = off * 60 + self.min  - utc.min
    off = off * 60 + self.sec  - utc.sec
    
    return off
  end

  ##
  # call-seq:
  #   time.wday => fixnum
  #
  # Returns an integer representing the day of the week, 0..6, with
  # Sunday == 0.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:04 CDT 2003
  #    t.wday         #=> 3

  def wday
    return self.to_a[IDX_WDAY]
  end

  ##
  # call-seq:
  #   time.yday => fixnum
  #
  # Returns an integer representing the day of the year, 1..366.
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:04 CDT 2003
  #    t.yday         #=> 99

  def yday
    return self.to_a[IDX_YDAY]
  end

  ##
  # call-seq:
  #   time.year => fixnum
  #
  # Returns the year for <em>time</em> (including the century).
  #
  #    t = Time.now   #=> Wed Apr 09 08:56:04 CDT 2003
  #    t.year         #=> 2003

  def year
    return self.to_a[IDX_YEAR]
  end

  ##
  # call-seq:
  #   time.zone => string
  #
  # Returns the name of the time zone used for <em>time</em>. As of Ruby
  # 1.8, returns ``UTC'' rather than ``GMT'' for UTC times.
  #
  #    t = Time.gm(2000, "jan", 1, 20, 15, 1)
  #    t.zone   #=> "UTC"
  #    t = Time.local(2000, "jan", 1, 20, 15, 1)
  #    t.zone   #=> "CST"

  def zone
    if @_utc then
      return "UTC"
    else
      return self.to_a[IDX_ZONE]
    end
  end

  alias :==         :eql?
  alias :ctime      :asctime
  alias :getgm      :getutc
  alias :gmt        :utc
  alias :gmt?       :utc?
  alias :gmt_offset :utc_offset
  alias :gmtime     :utc
  alias :gmtoff     :utc_offset
  alias :mon        :month
  alias :usec       :tv_usec
  alias :isdst      :dst?
end
