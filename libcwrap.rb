#!/usr/local/bin/ruby -w

# TODO:
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

begin
  require 'rubygems'
  require_gem 'RubyInline'
rescue LoadError
  require 'inline'
end


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
        (void)self;
        VALUE result = Qnil;
        struct tm * tv = localtime(&t);

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
        (void)self;
        VALUE result = Qnil;
        struct tm * tv = gmtime(&t);

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
        (void)self;
        (void)argc;

        struct tm tv;

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

        time_t result = mktime(&tv);

        return result;
      }
    }

    builder.c %q{
      static time_t c_timegm(int year, int month, int day, int hour, int min, int sec) {
        (void)self;
        (void)argc;

        struct tm tv;

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

        time_t result = timegm(&tv);

        return result;
      }
    }

    builder.c %q{
      static char * c_strftime(char * format, VALUE vals) {
        (void)self;

        struct tm tv;
        tv.tm_sec   = NUM2INT(rb_ary_entry(vals, 0));
        tv.tm_min   = NUM2INT(rb_ary_entry(vals, 1));
        tv.tm_hour  = NUM2INT(rb_ary_entry(vals, 2));
        tv.tm_mday  = NUM2INT(rb_ary_entry(vals, 3));
        tv.tm_mon   = NUM2INT(rb_ary_entry(vals, 4)) - 1;
        tv.tm_year  = NUM2INT(rb_ary_entry(vals, 5)) - 1900;
        tv.tm_wday  = NUM2INT(rb_ary_entry(vals, 6));
        tv.tm_yday  = NUM2INT(rb_ary_entry(vals, 7)) - 1;
        tv.tm_isdst = RTEST(  rb_ary_entry(vals, 8));
        VALUE zone  = rb_ary_entry(vals, 9);
        tv.tm_zone = StringValueCStr(zone);

        char buf[128];
        int len;
        len = strftime(buf, 128, format, &tv);
        return buf;
      }
    }

  end # inline
end # LIBC
