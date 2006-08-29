#!/usr/local/bin/ruby -w

# require 'rubygems'
require 'inline'

class LIBC

  inline do |builder|
    builder.include("<time.h>")
    builder.include("<stdio.h>")
    builder.add_type_converter("time_t", 'NUM2ULONG', 'ULONG2NUM')
    builder.add_type_converter("VALUE", '', '')
    builder.add_compile_flags "-Wall"
    builder.add_compile_flags "-W"
    builder.add_compile_flags "-Wpointer-arith"
    builder.add_compile_flags "-Wcast-qual"
    builder.add_compile_flags "-Wcast-align"
    builder.add_compile_flags "-Wwrite-strings"
    builder.add_compile_flags "-Wmissing-noreturn"
    builder.add_compile_flags "-Werror"

    builder.prefix "#define RBOOL(x) ((x) ? Qtrue : Qfalse)"

    builder.c_raw %q{
      static VALUE c_gettimeofday() {
        struct timeval tv;
        struct timezone tz;
        VALUE result = Qnil;
        if (!gettimeofday(&tv, &tz)) {
            result = rb_ary_new();
            rb_ary_push(result, INT2NUM(tv.tv_sec));
            rb_ary_push(result, INT2NUM(tv.tv_usec));
            rb_ary_push(result, INT2NUM(tz.tz_minuteswest));
            rb_ary_push(result, INT2NUM(tz.tz_dsttime));
        }
        return result;
      }
    }

    builder.c %q{
      static VALUE c_localtime(time_t t) {
        VALUE result = Qnil;
        struct tm * tv = localtime(&t);
        (void)self;

        if (tv) {
          result = rb_ary_new();

          rb_ary_push(result, INT2NUM(tv->tm_sec));
          rb_ary_push(result, INT2NUM(tv->tm_min));
          rb_ary_push(result, INT2NUM(tv->tm_hour));
          rb_ary_push(result, INT2NUM(tv->tm_mday));
          rb_ary_push(result, INT2NUM(tv->tm_mon + 1));
          rb_ary_push(result, INT2NUM(tv->tm_year + 1900));
          rb_ary_push(result, INT2NUM(tv->tm_wday));
          rb_ary_push(result, INT2NUM(tv->tm_yday + 1));
          rb_ary_push(result, RBOOL(tv->tm_isdst));
          // rb_ary_push(result, INT2NUM(tv->tm_gmtoff));
          rb_ary_push(result, rb_str_new2(tv->tm_zone));
        } else {
          printf("ERROR: %ld returned null\n", t);
        }
        return result;
      }
    }

    builder.c %q{
      static VALUE c_gmtime(time_t t) {
        VALUE result = Qnil;
        struct tm * tv = gmtime(&t);
        (void)self;

        if (tv) {
          result = rb_ary_new();
          rb_ary_push(result, INT2NUM(tv->tm_sec));
          rb_ary_push(result, INT2NUM(tv->tm_min));
          rb_ary_push(result, INT2NUM(tv->tm_hour));
          rb_ary_push(result, INT2NUM(tv->tm_mday));
          rb_ary_push(result, INT2NUM(tv->tm_mon + 1));
          rb_ary_push(result, INT2NUM(tv->tm_year + 1900));
          rb_ary_push(result, INT2NUM(tv->tm_wday));
          rb_ary_push(result, INT2NUM(tv->tm_yday + 1));
          rb_ary_push(result, RBOOL(tv->tm_isdst));
          // rb_ary_push(result, INT2NUM(tv->tm_gmtoff));
          rb_ary_push(result, rb_str_new2(tv->tm_zone));
        } else {
          printf("ERROR: %ld returned null\n", t);
        }
        return result;
      }
    }

    builder.c %q{
      static time_t c_mktime(int year, int month, int day, int hour, int min, int sec) {
        struct tm tv;
        time_t result;

        (void)self;

        tv.tm_sec = sec;
        tv.tm_min = min;
        tv.tm_hour = hour;
        tv.tm_mday = day;
        tv.tm_mon  = month - 1;
        tv.tm_year = year - 1900;

        tv.tm_wday = -1;
        tv.tm_yday = -1;
        tv.tm_isdst = -1;
        tv.tm_gmtoff = 0;
        tv.tm_zone = NULL;

        result = mktime(&tv);

        return result;
      }
    }

    builder.c %q{
      static time_t c_timegm(int year, int month, int day, int hour, int min, int sec) {
        struct tm tv;
        time_t result;

        (void)self;

        tv.tm_sec = sec;
        tv.tm_min = min;
        tv.tm_hour = hour;
        tv.tm_mday = day;
        tv.tm_mon  = month - 1;
        tv.tm_year = year - 1900;

        tv.tm_wday = -1;
        tv.tm_yday = -1;
        tv.tm_isdst = -1;
        tv.tm_gmtoff = 0;
        tv.tm_zone = NULL;

        result = timegm(&tv);

        return result;
      }
    }

    builder.c %q{
      static char * c_strftime(char * format, VALUE vals) {
        struct tm tv;
        char buf[128];
        int len;
        VALUE zone;

        (void)self;

        tv.tm_sec   = NUM2INT(rb_ary_entry(vals, 0));
        tv.tm_min   = NUM2INT(rb_ary_entry(vals, 1));
        tv.tm_hour  = NUM2INT(rb_ary_entry(vals, 2));
        tv.tm_mday  = NUM2INT(rb_ary_entry(vals, 3));
        tv.tm_mon   = NUM2INT(rb_ary_entry(vals, 4)) - 1;
        tv.tm_year  = NUM2INT(rb_ary_entry(vals, 5)) - 1900;
        tv.tm_wday  = NUM2INT(rb_ary_entry(vals, 6));
        tv.tm_yday  = NUM2INT(rb_ary_entry(vals, 7)) - 1;
        tv.tm_isdst = RTEST(  rb_ary_entry(vals, 8));
        zone  = rb_ary_entry(vals, 9);
        tv.tm_zone = StringValueCStr(zone);

        len = strftime(buf, 128, format, &tv);
        return buf;
      }
    }

    builder.include("<sys/types.h>")
    builder.include("<sys/stat.h>")

    stat_vals = <<-END
      rb_ary_push(result, INT2NUM(retval));

      if (retval == 0) {
        VALUE stat_values = rb_ary_new();
        VALUE tspec = Qnil;
        rb_ary_push(stat_values, INT2NUM(sb.st_dev));
        rb_ary_push(stat_values, INT2NUM(sb.st_ino));
        rb_ary_push(stat_values, INT2NUM(sb.st_mode));
        rb_ary_push(stat_values, INT2NUM(sb.st_nlink));
        rb_ary_push(stat_values, INT2NUM(sb.st_uid));
        rb_ary_push(stat_values, INT2NUM(sb.st_gid));
        rb_ary_push(stat_values, INT2NUM(sb.st_rdev));

        /* st_atimespec */
          tspec = rb_ary_new();
        rb_ary_push(tspec, INT2NUM(sb.st_atimespec.tv_sec));
        rb_ary_push(tspec, INT2NUM(sb.st_atimespec.tv_nsec));
        rb_ary_push(stat_values, tspec);

        /* st_mtimespec */
          tspec = rb_ary_new();
        rb_ary_push(tspec, INT2NUM(sb.st_mtimespec.tv_sec));
        rb_ary_push(tspec, INT2NUM(sb.st_mtimespec.tv_nsec));
        rb_ary_push(stat_values, tspec);

        /* st_ctimespec */
          tspec = rb_ary_new();
        rb_ary_push(tspec, INT2NUM(sb.st_mtimespec.tv_sec));
        rb_ary_push(tspec, INT2NUM(sb.st_mtimespec.tv_nsec));
        rb_ary_push(stat_values, tspec);

        rb_ary_push(stat_values, INT2NUM(sb.st_size));
        rb_ary_push(stat_values, INT2NUM(sb.st_blocks));
        rb_ary_push(stat_values, INT2NUM(sb.st_blksize));
        rb_ary_push(stat_values, INT2NUM(sb.st_flags));
        rb_ary_push(stat_values, INT2NUM(sb.st_gen));

        rb_ary_push(result, stat_values);
      }
      return result;
    END

    %w[stat lstat].each do |function|
      builder.c %{
        static VALUE c_#{function}(const char * path) {
          VALUE result = rb_ary_new();
          struct stat sb;
          int retval = #{function}(path, &sb);
          (void)self;

          #{stat_vals}
        }
      }
    end

    builder.c %{
      static VALUE c_fstat(int fd) {
        VALUE result = rb_ary_new();
        struct stat sb;
        int retval = fstat(fd, &sb);
        (void)self;

        #{stat_vals}
      }
    }
  end # inline

end # LIBC

# TODO: (maybe)
# require 'dl/import'
# libc = DL.dlopen('/usr/lib/libc.dylib')
# localtime = libc['localtime', 'LP']
# localtime.call(0)
# module LIBC
#   extend DL::Importable
#   dlload "libc.dylib"
#   typealias("time_t", "unsigned int")
#   extern "void * localtime(const time_t *clock)"
#   extern "void * gmtime(const time_t *clock)"
#   extern "time_t mktime(void *tm)"
#   extern "time_t timegm(void *tm)"
# end

# p LIBC.strlen("abc") # => 3
