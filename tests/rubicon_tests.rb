#
# This is the main Rubicon module, implemented as a module to
# protect the namespace a tad
#

RUBICON_VERSION = "V0.3.5"

# HACK: this really sucks... make the tests sane
$: << File.dirname($0) << File.join(File.dirname($0), "..") << File.join(File.dirname($0), "../..")

require 'metaruby.rb'

module Rubicon

  require 'runit/testcase'
  require 'runit/cui/testrunner'

  # -------------------------------------------------------

  class TestResult < RUNIT::TestResult
  end

  # -------------------------------------------------------

  class TestRunner < RUNIT::CUI::TestRunner
    def create_result
      TestResult.new
    end
  end

  # -------------------------------------------------------

  class TestSuite < RUNIT::TestSuite
  end


  # -------------------------------------------------------

  class TestCase < RUNIT::TestCase

    # Local routine to check that a set of bits, and only a set of bits,
    # is set!
    def checkBits(bits, num)
      0.upto(90)  { |n|
        expected = bits.include?(n) ? 1 : 0
        assert_equal(expected, num[n], "bit %d" % n)
      }
    end

    def truth_table(method, *result)
      for a in [ ZFALSE, ZTRUE ]
        res = result.shift
        assert_equal(method.call(a), res)
        assert_equal(method.call(a ? self : nil), res)
      end
    end

    # 
    # Report we're skipping a test
    #
    def skipping(info, from=nil)
      unless from
        caller[0] =~ /`(.*)'/ #`
        from = $1
      end
      if true
        $stderr.print "S"
      else
        $stderr.puts "\nSkipping: #{from} - #{info}"
      end
    end

    #
    # Check a float for approximate equality
    #
    def assert_flequal(exp, actual, msg='')
      if exp == 0.0
        error = 1e-7
      else
        error = exp.abs/1e7
      end
      
      assert((exp - actual).abs < error, 
             "#{msg} Expected #{'%f' % exp} got #{'%f' % actual}")
    end

    def assert_kindof_exception(exception, message="")
      setup_assert
      block = proc
      exception_raised = true
      err = ""
      ret = nil
      begin
	block.call
	exception_raised = false
	err = 'NO EXCEPTION RAISED'
      rescue Exception
	if $!.kind_of?(exception)
	  exception_raised = true
	  ret = $!
	else
	  raise $!.type, $!.message, $!.backtrace
	end
      end
      if !exception_raised
      	msg = edit_message(message)
        msg.concat "expected:<"
	msg.concat to_str(exception)
	msg.concat "> but was:<"
	msg.concat to_str(err)
	msg.concat ">"
	raise_assertion_error(msg, 2)
      end
      ret
    end

    #
    # Skip a test if not super user
    #
    def super_user
      caller[0] =~ /`(.*)'/ #`
      skipping("not super user", $1)
    end

    #
    # Issue a system and abort on error
    #
    def sys(cmd)
      if $os == MsWin32
	assert(system(cmd), "command failed: #{cmd}")
      else
	assert(system(cmd), cmd + ": #{$? >> 8}")
	assert_equal(0, $?, "cmd: #{$?}")
      end
    end

    #
    # Use our 'test_touch' utility to touch a file
    #
    def touch(arg)
#      puts("#{TEST_TOUCH} #{arg}")
      sys("#{TEST_TOUCH} #{arg}")
    end

    #
    # And out checkstat utility to get the status
    #
    def checkstat(arg)
#      puts("#{CHECKSTAT} #{arg}")
      `#{CHECKSTAT} #{arg}`
    end

    #
    # Check two arrays for set equality
    #
    def assert_set_equal(expected, actual)
      assert_equal([], (expected - actual) | (actual - expected),
                   "Expected: #{expected.inspect}, Actual: #{actual.inspect}")
    end

    #
    # Run a block in a sub process and return exit status
    #
    def runChild(&block)
      pid = fork 
      if pid.nil?
	block.call
        exit 0
      end
      Process.waitpid(pid, 0)
      return ($? >> 8) & 0xff
    end

    def setup
      super
    end

    def teardown
      if $os != MsWin32 && $os != JRuby
	begin
	  loop { Process.wait; $stderr.puts "\n\nCHILD REAPED\n\n" }
	rescue Errno::ECHILD
	end
      end
      super
    end
    #
    # Setup some files in a test directory.
    #
    def setupTestDir
      @start = Dir.getwd
      teardownTestDir
      begin
	Dir.mkdir("_test")
      rescue
        $stderr.puts "Cannot run a file or directory test: " + 
          "will destroy existing directory _test"
        exit(99)
      end
      File.open(File.join("_test", "_file1"), "w", 0644) {}
      File.open(File.join("_test", "_file2"), "w", 0644) {}
      @files = %w(. .. _file1 _file2)
    end
    
    def deldir(name)
      File.chmod(0755, name)
      Dir.foreach(name) do |f|
        next if f == '.' || f == '..'
        f = File.join(name, f)
        if File.lstat(f).directory?
          deldir(f) 
        else
          File.chmod(0644, f) rescue true
          File.delete(f)
        end 
      end
      Dir.rmdir(name)
    end

    def teardownTestDir
      Dir.chdir(@start)
      deldir("_test") if (File.exists?("_test"))
    end
    
  end

    
  #
  # Common code to run the tests in a class
  #
  def handleTests(testClass)
    testrunner = TestRunner.new
#    TestRunner.quiet_mode = true
    if ARGV.size == 0
      suite = testClass.suite
    else
      suite = RUNIT::TestSuite.new
      ARGV.each do |testmethod|
        suite.add_test(testClass.new(testmethod))
      end
    end
    results = testrunner.run(suite)
  end
  module_function :handleTests


  # Record a particule failure, which is a location
  # and an error message. We simply ape the runit
  # TestFailure class.

  class Failure
    attr_accessor :at
    attr_accessor :err
    
    def Failure.from_real_failures(f)
      f.collect do |a_failure|
        my_f = Failure.new
        my_f.at = a_failure.at
        my_f.err = a_failure.err
        my_f
      end
    end
  end

  # Objects of this class get generated from the TestResult
  # passed back by RUnit. We don't use it's class for two reasons:
  # 1. We decouple better this way
  # 2. We can't serialize the RUnit class, as it contains IO objects
  #

  
  class Results
    attr_reader :failure_size
    attr_reader :error_size
    attr_reader :run_tests
    attr_reader :run_asserts
    attr_reader :failures
    attr_reader :errors

    def initialize_from(test_result)
      @failure_size = test_result.failure_size
      @error_size   = test_result.error_size
      @run_tests    = test_result.run_tests
      @run_asserts  = test_result.run_asserts
      @succeed      = test_result.succeed?
      @failures     = Failure.from_real_failures(test_result.failures)
      @errors       = Failure.from_real_failures(test_result.errors)
      self
    end

    def succeed?
      @succeed
    end
  end

  # And here is where we gather the results of all the tests. This is
  # also the object exported to XML

  class ResultGatherer

    attr_reader   :results
    attr_accessor :name
    attr_reader   :config
    attr_reader   :date
    attr_reader   :rubicon_version
    attr_reader   :ruby_version
    attr_reader   :ruby_release_date
    attr_reader   :ruby_architecture

    attr_reader   :failure_count

    # Two sage initialization, so that Rubric doesn't create all the
    # internals when we unmarshal

    def initialize(name = '')
      @name    = ''
      @failure_count = 0
    end

    def setup
      @results = {}
      @config  = Config::CONFIG
      @date    = Time.now
      @rubicon_version = RUBICON_VERSION

      ver = `#$interpreter --version`
      # ruby 1.7.1 (2001-07-26) [i686-linux]  
      unless ver =~ /ruby (\d+\.\d+\.\d+)\s+\((.*?)\)\s+\[(.*?)\]/
        raise "Couldn't find version in '#{ver}'" 
      end
      @ruby_version      = $1
      @ruby_release_date = $2
      @ruby_architecture = $3
      self
    end

    def add(klass, result_set)
      @results[klass.name] = Results.new.initialize_from(result_set)
      @failure_count += result_set.error_size + result_set.failure_size
    end
    
  end

  # Run a set of tests in a file. This would be a TestSuite, but we
  # want to run each file separately, and to summarize the results
  # differently

  class BulkTestRunner

    def initialize(args, group_name)
      @groupName = group_name
      @files     = []
      @results   = ResultGatherer.new.setup
      @results.name   = group_name
      @op_class_file  = "ascii"

      # Look for a -op <class> argument, which controls
      # where our output goes

      if args.size > 1 and args[0] == "-op"
        args.shift
        @op_class_file = args.shift
      end

      @op_class_file = "result_" + @op_class_file
      require @op_class_file
    end

    def addFile(fileName)
      @files << fileName
    end

    def run
      @files.each do |file|
        require file
        className = File.basename(file)
        className.sub!(/\.rb$/, '')
        klass = eval className
        runner = TestRunner.new
        TestRunner.quiet_mode = true
        $stderr.print "\n", className, ": "

        @results.add(klass, runner.run(klass.suite))
      end

      reporter = ResultDisplay.new(@results)
      reporter.reportOn $stdout
      return @results.failure_count
    end

  end
end
