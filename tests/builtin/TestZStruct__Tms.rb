$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

Version.less_than("1.7") do
  TimesClass = Time
end
Version.greater_or_equal("1.7") do
  TimesClass = Process
end

class TestZStruct__Tms < Rubicon::TestCase

  MsWin32.dont do

    # Burn up some CPU in the parent and the child
    def setup
      pid = fork
      
      name = pid ? "_parent" : "_child"
      
      Dir.rmdir(name) if File.exists?(name)
      
      t = Time.now
      
      while Time.now - t < 3
	Dir.mkdir(name)
	Dir.rmdir(name)
      end
      
      exit unless pid
      
      Process.wait
    end
    
    def test_times
      assert(TimesClass.times.cstime > 0.0)
      assert(TimesClass.times.cutime > 0.0)
      assert(TimesClass.times.stime > 0.0)
      assert(TimesClass.times.utime > 0.0)
      assert(TimesClass.times['utime'] != 0)
      assert(TimesClass.times['stime'] != 0)
      assert(TimesClass.times['cutime'] != 0)
      assert(TimesClass.times['cstime'] != 0)
      assert_equals(4, TimesClass.times.members.length)
    end
  end

end

Rubicon::handleTests(TestStruct__Tms) if $0 == __FILE__
