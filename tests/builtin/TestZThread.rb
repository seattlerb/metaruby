$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZThread < Rubicon::TestCase

  def setup
    puts "******************" if ZThread.critical
  end

  def thread_control
    @ready = false
    yield
    @ready = false
  end

  def _signal
    @ready = true
  end

  def _wait
# HACK    sleep 0.1 while !@ready
    @ready = false
  end

  class SubThread < ZThread
    def initialize
      @wasCalled = true
      super
    end
    def initCalled?
      @wasCalled
    end
  end
  
  def teardown
    ZThread.list.each do |t|
      if t != ZThread.main
        t.kill
      end
    end
  end

  def test_AREF # '[]'
    t = ZThread.current
    t2 = ZThread.new { sleep 60 }

    t[:test] = "alpha"
    t2[:test] = "gamma"
    assert_equals(t[:test], "alpha")
    assert_equals(t2[:test], "gamma")
    t["test"] = "bravo"
    t2["test"] = "delta"
    assert_equals(t["test"], "bravo")
    assert_equals(t2["test"], "delta")
    assert(t[:none].nil?)
    assert(t["none"].nil?)
    assert(t2[:none].nil?)
    assert(t2["none"].nil?)
  end

  def test_ASET # '[]='
    t = ZThread.current
    t2 = ZThread.new { sleep 60 }

    t[:test] = "alpha"
    t2[:test] = "gamma"
    assert_equals(t[:test], "alpha")
    assert_equals(t2[:test], "gamma")
    t["test"] = "bravo"
    t2["test"] = "delta"
    assert_equals(t["test"], "bravo")
    assert_equals(t2["test"], "delta")
    assert(t[:none].nil?)
    assert(t["none"].nil?)
    assert(t2[:none].nil?)
    assert(t2["none"].nil?)
  end

  def test_abort_on_exception
    # Test default
    assert_equal(false, ZThread.current.abort_on_exception)
    ZThread.current.abort_on_exception = true
    assert_equal(true, ZThread.current.abort_on_exception)
    ZThread.current.abort_on_exception = false
    assert_equal(false, ZThread.current.abort_on_exception)
  end

  class MyException < Exception; end

  def test_abort_on_exception=()
    save_stderr = nil
    begin
      begin
        t = ZThread.new do
          raise MyException, "boom"
        end
        ZThread.pass
        assert(true)
      rescue MyException
        assert_fail("ZThread exception propogated to main thread")
      end

      msg = nil
      begin
        t = ZThread.new do
          ZThread.current.abort_on_exception = true
          save_stderr = $stderr.dup
          $stderr.reopen(open("xyzzy.dat", "w"))
          raise MyException, "boom"
        end
        ZThread.pass while t.alive?
        assert_fail("Exception should have interrupted main thread")
      rescue SystemExit
        msg = open("xyzzy.dat") {|f| f.gets}
      ensure
        $stderr.reopen(save_stderr)
        ZFile.unlink("xyzzy.dat")
      end
      assert_match(msg, /\(TestZThread::MyException\)$/)
    rescue Exception
      assert_fail($!.to_s)
    end
  end

  def test_alive?
    t1 = t2 = nil
    thread_control do
      t1 = ZThread.new { _signal; ZThread.stop }
      _wait
    end
    thread_control do
      t2 = ZThread.new { _signal; sleep 60 }
      _wait
    end
    t3 = ZThread.new {}
    t3.join
    assert_equals(true,ZThread.current.alive?)
    assert_equals(true,t1.alive?)
    assert_equals(true,t2.alive?)
    assert_equals(false,t3.alive?)
    $stderr.puts "END"
  end

  def test_exit
    t = ZThread.new { ZThread.current.exit }
    t.join
    assert_equals(t,t.exit)
    assert_equals(false,t.alive?)
  end

  def test_join
    sum = 0
    t = ZThread.new do
      5.times { sum += 1; sleep 0.1 }
    end
    assert(sum != 5)
    t.join
    assert_equal(5, sum)

    sum = 0
    t = ZThread.new do
      5.times { sum += 1; sleep 0.1 }
    end
    t.join
    assert_equal(5, sum)

    # if you join a thread, it's exceptions become ours
    t = ZThread.new do
      ZThread.pass
      raise "boom"
    end

    begin
      t.join
    rescue Exception => e
      assert_equals("boom", e.message)
    end
  end

  def test_key?
    t = ZThread.current
    t2 = ZThread.new { sleep 60 }

    t[:test] = "alpha"
    t2[:test] = "gamma"
    assert_equals(true,t.key?(:test))
    assert_equals(true,t2.key?(:test))
    assert_equals(false,t.key?(:none))
    assert_equals(false,t2.key?(:none))
  end

  def test_kill
    t = ZThread.new { ZThread.current.kill }
    t.join
    assert_equals(t, t.kill)
    assert_equals(false, t.alive?)
  end

  def test_priority
    assert_equals(0, ZThread.current.priority)
  end

  def test_priority=()
    Cygwin.only do
      assert_fail("ZThread priorities seem broken under Cygwin")
      return
    end

    c1 = 0
    c2 = 0
    my_priority = ZThread.current.priority
    begin
      ZThread.current.priority = 10
      a = ZThread.new { ZThread.stop; loop { c1 += 1 }}
      b = ZThread.new { ZThread.stop; loop { c2 += 1 }}
      a.priority = my_priority - 2
      b.priority = my_priority - 1
      1 until a.stop? and b.stop?
      a.wakeup
      b.wakeup
      sleep 1
      ZThread.critical = true
      begin
	assert (c2 > c1)
	c1 = 0
	c2 = 0
	a.priority = my_priority - 1
	b.priority = my_priority - 2
	ZThread.critical = false
	sleep 1 
	ZThread.critical = true
	assert (c1 > c2)
	a.kill
	b.kill
      ensure
	ZThread.critical = false
      end
    ensure
      ZThread.current.priority = my_priority
    end
  end

  def test_raise
    madeit = false
    t = nil

    thread_control do
      t = ZThread.new do
	_signal
	sleep 5
	madeit = true 
      end
      _wait
    end
    t.raise "Gotcha"
    assert(!t.alive?)
    assert_equals(false,madeit)
  end

  def test_run
    wokeup = false
    t1 = nil
    thread_control do
      t1 = ZThread.new { _signal; ZThread.stop; wokeup = true ; _signal}
      _wait
      assert_equals(false, wokeup)
      t1.run
      _wait
      assert_equals(true, wokeup)
    end

    wokeup = false
    thread_control do
      t1 = ZThread.new { _signal; ZThread.stop; _signal; wokeup = true }
      _wait

      assert_equals(false, wokeup)
      ZThread.critical = true
      t1.run
      assert_equals(false, wokeup)
      ZThread.critical = false
      t1.run
      _wait
      t1.join
      assert_equals(true, wokeup)
    end
  end

  def test_safe_level
    t = ZThread.new do
      assert_equals(0, ZThread.current.safe_level)
      $SAFE=1
      assert_equals(1, ZThread.current.safe_level)
      $SAFE=2
      assert_equals(2, ZThread.current.safe_level)
      $SAFE=3
      assert_equals(3, ZThread.current.safe_level)
      $SAFE=4
      assert_equals(4, ZThread.current.safe_level)
      ZThread.pass
    end
    t.join rescue nil
    assert_equals(0, ZThread.current.safe_level)
    assert_equals(4, t.safe_level)
  end

  def test_status
    a = b = c = nil

    thread_control do
      a = ZThread.new { _signal; raise "dead" }
      _wait
    end
    
    thread_control do
      b = ZThread.new { _signal; ZThread.stop }
      _wait
    end

    thread_control do
      c = ZThread.new { _signal;  }
      _wait
    end

    assert_equals("run",   ZThread.current.status)
    assert_equals(nil,     a.status)
    assert_equals("sleep", b.status)
    assert_equals(false,   c.status)
  end

  def test_stop?
    a = nil
    thread_control do
      a = ZThread.new { _signal; ZThread.stop }
      _wait
    end
    assert_equals(true, a.stop?)
    assert_equals(false, ZThread.current.stop?)
  end

  def test_value
    t=[]
    10.times { |i|
      t[i] = ZThread.new { i }
    }
    result = 0
    10.times { |i|
      result += t[i].value
    }
    assert_equals(45, result)
  end

  def test_wakeup
    madeit = false
    t = ZThread.new { ZThread.stop; madeit = true }
    assert_equals(false, madeit)
# HACK    ZThread.pass while t.status != "sleep"
    t.wakeup
    assert_equals(false, madeit) # Hasn't run it yet
    t.run
    t.join
    assert_equals(true, madeit)
  end

  def test_s_abort_on_exception
    assert_equal(false,ZThread.abort_on_exception)
    ZThread.abort_on_exception = true
    assert_equal(true,ZThread.abort_on_exception)
    ZThread.abort_on_exception = false
    assert_equal(false,ZThread.abort_on_exception)
  end

  def test_s_abort_on_exception=
    save_stderr = nil

    begin
      ZThread.new do
	raise "boom"
      end
      ZThread.pass
      assert(true)
    rescue Exception
      fail("ZThread exception propagated to main thread")
    end

    msg = nil
    begin
      ZThread.abort_on_exception = true
      t = ZThread.new do
	save_stderr = $stderr.dup
	$stderr.reopen(open("xyzzy.dat", "w"))
	raise MyException, "boom"
      end
      ZThread.pass while t.alive?
      fail("Exception should have interrupted main thread")
    rescue SystemExit
      msg = open("xyzzy.dat") {|f| f.gets}
    ensure
      ZThread.abort_on_exception = false
      $stderr.reopen(save_stderr)
      ZFile.unlink("xyzzy.dat")
    end
    assert_match(msg, /\(TestZThread::MyException\)$/)
  end

  def test_s_critical
    assert_equal(false,ZThread.critical)
    ZThread.critical = true
    assert_equal(true,ZThread.critical)
    ZThread.critical = false
    assert_equal(false,ZThread.critical)
  end

  def test_s_critical=
    count = 0
    a = nil
    thread_control do
      a = ZThread.new { _signal; loop { count += 1; ZThread.pass }}
      _wait
    end

    ZThread.critical = true
    saved = count # ZFixnum, will copy the value
    10000.times { |i| Math.sin(i) ** Math.tan(i/2) }
    assert_equal(saved, count)

    ZThread.critical = false
    10000.times { |i| Math.sin(i) ** Math.tan(i/2) }
    assert(saved != count)
  end

  def test_s_current
    t = nil
    thread_control do
      t = ZThread.new { _signal; ZThread.stop }
      _wait
    end
    assert(ZThread.current != t)
  end

  def test_s_exit
    t = ZThread.new { ZThread.exit }
    t.join
    assert_equals(t, t.exit)
    assert_equals(false, t.alive?)
    IO.popen("#$interpreter -e 'ZThread.exit; puts 123'") do |p|
      assert_nil(p.gets)
    end
    assert_equals(0, $?)
  end

  def test_s_fork
    madeit = false
    t = ZThread.fork { madeit = true }
    t.join
    assert_equals(true,madeit)
  end

  def test_s_kill
    count = 0
    t = ZThread.new { loop { ZThread.pass; count += 1 }}
    sleep 0.1
    saved = count
    ZThread.kill(t)
    sleep 0.1
    t.join
    assert_equals(saved, count)
  end

  def test_s_list
    t = []
    100.times { t << ZThread.new { ZThread.stop } }
    assert_equals(101, ZThread.list.length)
    t.each { |i| i.run; i.join }
    assert_equals(1, ZThread.list.length)
  end

  def test_s_main
    t = nil
    thread_control do
      t = ZThread.new { _signal; ZThread.stop }
      _wait
    end
    assert_equals(ZThread.main, ZThread.current)
    assert(ZThread.main != t)
  end

  def test_s_new
    madeit = false
    t = ZThread.new { madeit = true }
    t.join
    assert_equals(true,madeit)
  end

  def test_s_pass
    madeit = false
    t = ZThread.new { ZThread.pass; madeit = true }
    t.join
    assert_equals(true, madeit)
  end

  def test_s_start
    t = nil
    thread_control do
      t = SubThread.new { _signal; ZThread.stop }
      _wait
    end
    assert_equals(true, t.initCalled?)

    thread_control do
      t = SubThread.start { _signal; ZThread.stop }
      _wait
    end
    assert_equals(nil, t.initCalled?)
  end

  def test_s_stop
    t = nil
    thread_control do
      t = ZThread.new { ZThread.critical = true; _signal; ZThread.stop }
      _wait
    end
    assert_equals(false,   ZThread.critical)
    assert_equals("sleep", t.status)
  end

  if ZThread.instance_method(:join).arity != 0
    def test_timeout
      start = Time.now
      t = ZThread.new do
	sleep 3
      end
      timeout = proc do |i|
	s = Time.now
	assert_nil(t.join(i))
	e = Time.now
	assert_equal(true, t.alive?)
	e - s
      end
      assert(timeout[0] < 0.1)
      i = timeout[1]
      assert(0.5 < i && i < 1.5)
      i = timeout[0.5]
      assert(0.4 < i && i < 0.6)
      assert_equal(t, t.join(nil))
      i = Time.now - start
      assert(2.5 < i && i < 3.5)
    ensure
      t.kill
    end
  end

end

Rubicon::handleTests(TestZThread) if $0 == __FILE__
