require "tempfile"
require "rbconfig.rb"

require "rubicon_tests"

#
# Simple wrapper for RubyUnit, primarily designed to capture
# statistics and report them at the end.
#

# -------------------------------------------------------------
#
# Operating system classification. We use classes for this, as 
# we get lots of flexibility with comparisons.
#
# Use with
#
#   Unix.or_variant do ... end        # operating system is some Unix variant
#
#   Linux.only do .... end            # operating system is Linux
#
#   MsWin32.dont do .... end          # don't run under MsWin32
#
# If there is a known problem which is very, very unlikely ever to be
# fixed, you can say
#
#   Cygwin.known_problem do
#
#   end
#
# This runs the test, but squelches the error on that particular operating
# system

class OS
  def OS.or_variant
    yield if $os <= self
  end

  def OS.only
    yield if $os == self
  end

  def OS.dont
    yield unless $os <= self
  end

  def OS.known_problem
    if $os <= self
      begin
        yield
      rescue RUNIT::AssertionFailedError => err
        $stderr.puts
        $stderr.puts
        $stderr.puts "Ignoring known problem: #{err.message}"
        $stderr.puts err.backtrace[0]
        $stderr.puts
      end
    else
      yield
    end
  end
end

class Unix    < OS;      end
class Linux   < Unix;    end
class BSD     < Unix;    end
class FreeBSD < BSD;     end
class Solaris < Unix;    end
class HPUX    < Unix;    end

class JRuby   < OS;      end

class Windows < OS;      end
class Cygwin  < Windows; end

class WindowsNative < Windows; end
class MsWin32 < WindowsNative; end
class MinGW   < WindowsNative; end

$os = case RUBY_PLATFORM
      when /linux/   then  Linux
      when /bsd/     then BSD
      when /solaris/ then Solaris
      when /hpux/    then HPUX
      when /cygwin/  then Cygwin
      when /mswin32/ then MsWin32
      when /mingw32/ then MinGW
      when /java/    then JRuby
      else OS
      end


#
# Find the name of the interpreter.
# 

$interpreter = File.join(Config::CONFIG["bindir"], 
			 Config::CONFIG["RUBY_INSTALL_NAME"])

MsWin32.or_variant { $interpreter.tr! '/', '\\' }


######################################################################
#
# This is tacky, but... We need to be able tofind the executable
# files in the util subdirectory. However, we can be initiated by
# running a file in either the top-level rubicon directory or in
# one of its test subdirectories (such as language). We therefore
# need to hunt around for the util directory

run_dir = File.dirname(__FILE__)

for relative_path in [ ".", ".." ]
  util = File.join(run_dir, relative_path, "util")

  if File.exist?(util) and File.directory?(util)
    UTIL = util
    break
  end
end

raise "Cannot find 'util' directory" unless defined?(UTIL)

CHECKSTAT = File.join(UTIL, "checkstat")
TEST_TOUCH = File.join(UTIL, "test_touch")

if Config::CONFIG["EXEEXT"]
CHECKSTAT << Config::CONFIG["EXEEXT"]
TEST_TOUCH << Config::CONFIG["EXEEXT"]
end

for file in [CHECKSTAT, TEST_TOUCH]
  raise "Cannot find #{file}" unless File.exist?(file)
end


#
# Classification routines. We use these so that the code can
# test for operating systems, ruby versions, and other features
# without being platform specific
#

# -------------------------------------------------------
# Class to manipulate Ruby version numbers. We use this to 
# insulate ourselves from changes in version number format.
# Independent of the internal representation, we always allow 
# comparison against a string.
#
# Use in the code with stuff like:
#
#    Version.greater_than("1.6.2) do
#       assert(...)
#    end
#

class Version
  include Comparable
  
  def initialize(version)
    @version = version
  end
  
  def <=>(other)
    @version <=> other
  end

  # Specify a range of versions, and run a test block if the current version
  # falls within that range.  
  def Version.in(range)
    if(range.include?(VERSION)) then
      yield
    end
  end

  def Version.greater_than(version)
    if(VERSION > version) then
      yield
    end
  end

  def Version.greater_or_equal(version)
    if(VERSION >= version) then
      yield
    end
  end

  def Version.less_than(version)
    if(VERSION < version) then
      yield
    end
  end

  def Version.less_or_equal(version)
    if(VERSION <= version) then
      yield
    end
  end
 
end
