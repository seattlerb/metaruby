require "dl"
require "dl/import"
require "dl/struct"

class DL::Importable::Internal::Memory

  def inspect
    i = "#<#{self.class}:0x#{self.object_id.to_s(16)} "
    data = []
    @names.each { |name| data << "#{name}=#{self.send(name).inspect}" }
    i << data.join(', ') << ">"
    return i
  end

end

module LIBC

  extend DL::Importable

  begin
    dlload "libc.so"
  rescue
    dlload "libc.dylib"
  end

  typealias "const time_t *", "long ref"

  Timeval = struct [
    "long tv_sec",  # seconds since Jan. 1, 1970
    "long tv_usec", # and microseconds
  ]

  Timezone = struct [
    "int tz_minuteswest", # of Greenwich
    "int tz_dsttime",     # type of dst correction to apply
  ]

  StructTm = struct [
    "int tm_sec",     # seconds (0 - 60)
    "int tm_min",     # minutes (0 - 59)
    "int tm_hour",    # hours (0 - 23)
    "int tm_mday",    # day of month (1 - 31)
    "int tm_mon",     # month of year (0 - 11)
    "int tm_year",    # year - 1900
    "int tm_wday",    # day of week (Sunday = 0)
    "int tm_yday",    # day of year (0 - 365)
    "int tm_isdst",   # is summer time in effect?
    "long tm_gmtoff", # offset from UTC in seconds
    "char *tm_zone",  # abbreviation of timezone name
  ]

  extern "int gettimeofday(struct timeval *, struct timezone *)"

  def self.c_gettimeofday
    tv = LIBC::Timeval.malloc
    tz = LIBC::Timezone.malloc
    if 0 == LIBC.gettimeofday(tv, tz) then
      return [tv.tv_sec, tv.tv_usec, tz.tz_minuteswest, tz.tz_dsttime]
    else
      return nil
    end
  end

  extern "struct tm * localtime(const time_t *)"

  def self.c_localtime(clock)
    tm = LIBC.localtime(clock)
    return LIBC::StructTm.new(tm)
  end

end

if $0 == __FILE__ then
  now = LIBC.c_gettimeofday.first
  puts "At the sound of the beep, the time will be shortly after #{now}\007"
  puts "Just for kicks, here's a StructTm:"
  p LIBC.c_localtime(now)
end
