require '../rubicon'



# We don't test the 'effective' part, as that would entail setting up
# special users. Instead, we do a quick sanity check that effective
# equals real.

class TestProcess < Rubicon::TestCase

  #
  # These three routines implement primitive synchronization between
  # a child and parent
  #
  #  fork_control do
  #
  #     fork do
  #        <setup>
  #        signal_parent
  #        <continue>
  #     end
  #
  #     wait_child
  #     <stuff>
  #  end
  #     

  def fork_control
    @running = false
    trap("SIGUSR2") { @running = true }
    yield
    trap("SIGUSR2", "DEFAULT")
  end

  def signal_parent
    Process.kill("SIGUSR2", Process.ppid)
  end

  def wait_child
    sleep 0.1 while !@running
  end


  def get_uid_gid
    info = `id`
    if $? != 0 || info !~ /uid=(\d+).* gid=(\d+)/
      skipping("Can't find system's idea of uid/gid")
    else
      @uid = $1.to_i
      @gid = $2.to_i
    end
  end

  def test_s_egid
    assert_instance_of(Fixnum, Process.egid)
    assert_equal(Process.gid, Process.egid)
  end

  def test_s_egid=
    skipping("need special user")
  end

  def test_s_euid
    assert_instance_of(Fixnum, Process.euid)
    assert_equal(Process.uid, Process.euid)
  end

  def test_s_euid=
    skipping("need special user")
  end

  def test_s_exit!
    IO.popen("-") do |pipe|
      if !pipe
        at_exit { puts "at exit" }
        trap "EXIT", proc { puts "EXIT" }
        exit!
      end
      assert_nil(pipe.gets)
      pipe.close
      assert_equal(255<<8, $?)
    end
  end

  def test_s_fork
    f = Process.fork
    if f.nil?
      File.open("_pid", "w") {|f| f.puts $$}
      exit 99
    end
    begin
      Process.wait
      assert_equal(99<<8, $?)
      File.open("_pid") do |file|
        assert_equal(file.gets.to_i, f)
      end
    ensure
      File.delete("_pid")
    end

    f = Process.fork do
      File.open("_pid", "w") {|f| f.puts $$}
    end
    begin
      Process.wait
      assert_equal(0<<8, $?)
      File.open("_pid") do |file|
        assert_equal(file.gets.to_i, f)
      end
    ensure
      File.delete("_pid")
    end
  end

  # tested under setpgid
#  def test_s_getpgid
#    skipping("...")
#  end

  def test_s_getpgrp
    skipping("...")
  end

  def test_s_getpriority
    prior = Process.getpriority(Process::PRIO_USER, 0)
    assert_instance_of(Fixnum, prior)
    prior = Process.getpriority(Process::PRIO_PGRP, 0)
    assert_instance_of(Fixnum, prior)
    prior = Process.getpriority(Process::PRIO_PROCESS, 0)
    assert_instance_of(Fixnum, prior)
    assert_equal(prior, Process.getpriority(Process::PRIO_PROCESS, Process.pid))
  end

  def test_s_gid
    get_uid_gid
    gid = Process.gid
    assert_instance_of(Fixnum, gid)
    assert_equal(@gid, gid) if @gid
  end

  def test_s_gid=
    skipping("need special user")
  end

  def test_s_kill
    res = nil
    trap("SIGUSR1") { res = "usr1" }
    Process.kill("USR1", 0)
    assert_equal("usr1", res)
    trap("SIGUSR1", "DEFAULT")

    fork_control do

      pid = fork
      if !pid
        trap("USR1") { exit! }
        signal_parent
        sleep(100)
        exit(0)
      end
      trap("USR1") { puts "not here!"; exit! }
      wait_child
      begin
        Process.kill("USR1", pid)
        assert_equal(pid, Process.wait)
        assert_equal(255<<8, $?)
      ensure
        trap("USR1", "DEFAULT")
      end
    end
  end

  # this seems somewhat self-referential, but...
  def test_s_pid
    assert_instance_of(Fixnum, Process.pid)
    assert_equal($$, Process.pid)
    IO.popen("-") do |pipe|
      if !pipe
        puts Process.pid
        puts Process.ppid
        exit
      end
      assert_equal(pipe.pid, pipe.gets.to_i)
      assert_equal(Process.pid, pipe.gets.to_i)
      pipe.close
    end
  end

  # tested in _s_pid
#  def test_s_ppid
#    assert_fail("untested")
#  end

  def test_s_setpgid
    fork_control do
      pid = fork
      if !pid
        puts "In child, #$$"
        trap("USR1") { puts "GOT USR!"; exit 99 }
        signal_parent
        50.times { sleep 0.1 }
        exit!
      end
      puts "child is #{pid}"
      res = nil
      wait_child
      trap("USR1") { res = "ouch!" }
      puts 1
      
      # this one won't touch the child
      Process.setpgid(pid, pid)
      puts 2
      Process.kill("USR1", Process.getpgid($$))
      puts 3
      assert_equal("ouch!", res);
      puts 4
      
      trap("USR1") { res = "stop that" }
      
      # this one will get the child
      Process.setpgid(pid, Process.getpgid($$))
      Process.kill("USR1", Process.getpgid($$))
      
      puts 3
      assert_equal("stop that", res);
      puts "about to wait"
      assert_equal([pid, 99<<8], Process.wait2)
    end
  end

  def test_s_setpgrp
    assert_fail("untested")
  end

  def test_s_setpriority
    assert_fail("untested")
  end

  def test_s_setsid
    assert_fail("untested")
  end

  def test_s_uid
    get_uid_gid
    uid = Process.uid
    assert_instance_of(Fixnum, uid)
    assert_equal(@uid, uid) if @uid
  end

  def test_s_uid=
    assert_fail("untested")
  end

  def test_s_wait
    assert_fail("untested")
  end

  def test_s_wait2
    assert_fail("untested")
  end

  def test_s_waitpid
    assert_fail("untested")
  end

end

Rubicon::handleTests(TestProcess) if $0 == __FILE__
