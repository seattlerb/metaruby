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

  def self._load(arg1)
    raise "not implemented yet"
  end

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
    else
      raise "wtf?: #{t.inspect}:#{t.class}"
    end
    return r
  end

  # Time.local( year [, month, day, hour, min, sec, usec] ) => time
  # Time.local( sec, min, hour, day, month, year, wday, yday, isdst, tz ) => time
  # Time.mktime( year [, month, day, hour, min, sec, usec] ) => time
  # Time.mktime( sec, min, hour, day, month, year, wday, yday, isdst, tz) => time
  def self.mktime(*a)
    args = a.dup
    case args.size
    when 1..7 then
      default_args = [nil, 1, 1, 0, 0, 0, 0] # filler, month, day, hour, min, sec, usec
      args.push *default_args[args.size..-1]
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

  def self.now
    return self.new
  end

  def self.times
    return Process.times
  end

  # Time.utc( year [, month, day, hour, min, sec, usec] ) => time
  # Time.utc( sec, min, hour, day, month, year, wday, yday, isdst, tz) => time
  # Time.gm( year [, month, day, hour, min, sec, usec] ) => time
  # Time.gm( sec, min, hour, day, month, year, wday, yday, isdst, tz) => time
  # day is 1 based

  def self.utc(*a)
    args = a.dup
    case args.size
    when 1..7 then
      default_args = [nil, 1, 1, 0, 0, 0, 0] # filler, month, day, hour, min, sec, usec
      args.push *default_args[args.size..-1]
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
      if @_utc then
        return Time.at(@tv_sec + o.to_i, @tv_usec + ((o - o.to_i) * 1e6).to_i).utc
      else
        return Time.at(@tv_sec + o.to_i, @tv_usec + ((o - o.to_i) * 1e6).to_i)
      end
    else
      raise "wtf?: #{t.inspect}:#{t.class}"
    end
  end

  def -(o)
    case o
    when Fixnum, Bignum, Float then
      return self + -o
    when Time
      return self.to_f - o.to_f
    else
      raise "wtf?: #{t.inspect}:#{t.class}"
    end
    return self
  end

  def <=>(other)
    cmp = @tv_sec <=> other.tv_sec
    return cmp unless cmp == 0
    return @tv_usec <=> other.tv_usec
  end

  def _dump(*args)
    raise "not implemented yet"
  end

  def asctime
    format = 
      if @_utc then
        "%a %b %e %H:%M:%S %Y"
      else
        "%a %b %e %H:%M:%S %Y"
      end
    return LIBC.new.c_strftime(format, @vals)
  end

  def day
    self.to_a[IDX_DAY]
  end

  def dst?
    self.to_a[IDX_ISDST]
  end

  def eql?(other)
    self.to_i == other.to_i &&
      self.usec == other.usec &&
      self.to_a == other.to_a
  end

  def getlocal
    return Time.at(self).localtime
  end

  def getutc
    return Time.at(self).utc
  end

  def hash
    self.to_f.hash
  end

  def hour
    self.to_a[IDX_HOUR]
  end

  def inspect
    return self.to_s
  end

  def isdst
    dst?
  end

  def localtime
    if @_utc then
      @tv_sec += self.utc_offset
      @_utc = false
      @vals = LIBC.new.c_localtime(@tv_sec)
    end
    return self
  end

  def mday
    self.to_a[IDX_DAY]
  end

  def min
    self.to_a[IDX_MINUTE]
  end

  def month
    self.to_a[IDX_MONTH]
  end

  def sec
    self.to_a[IDX_SECOND]
  end

  def strftime(format)
    return LIBC.new.c_strftime(format, @vals)
  end

  def succ
    return self + 1
  end

  def to_a
    return @vals
  end

  def to_f
    @tv_sec.to_f + (@tv_usec / 1e6)
  end

  def to_i
    @tv_sec
  end

  def to_s
    format = 
      if @_utc then
        "%a %b %d %H:%M:%S UTC %Y"
      else
        "%a %b %d %H:%M:%S %Z %Y"
      end
    return LIBC.new.c_strftime(format, @vals)
  end

  def tv_sec
    @tv_sec
  end

  def tv_usec
    @tv_usec
  end

  def utc
    unless @_utc then
      @_utc = true
      @vals = LIBC.new.c_gmtime(@tv_sec)
    end
    return self
  end

  def utc?
    raise "undefined @_utc" unless defined? @_utc
    return @_utc
  end

  def utc_offset
    return 0 if @_utc

    utc = self.getutc

    off = self.year != utc.year ? self.year < utc.year : nil
    off = self.mon  != utc.mon  ? self.mon  < utc.mon  : nil if off.nil?
    off = self.mday != utc.mday ? self.mday < utc.mday : nil if off.nil?

    off = off.nil? ? 0 : off ? -1 : 1

    off = off * 24 + self.hour - utc.hour;
    off = off * 60 + self.min  - utc.min;
    off = off * 60 + self.sec  - utc.sec;
    
    return off
  end

  def wday
    self.to_a[IDX_WDAY]
  end

  def yday
    self.to_a[IDX_YDAY]
  end

  def year
    self.to_a[IDX_YEAR]
  end

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

end
