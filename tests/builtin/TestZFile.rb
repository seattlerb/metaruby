$: << ZFile.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'
require 'stat'

MsWin32.dont do
  require 'socket'
end


class TestZFile < Rubicon::TestCase

  def setup
    setupTestDir

    @file = ZFile.join("_test", "_touched")

    touch("-a -t 122512341999 #@file")
    @aTime = Time.local(1999, 12, 25, 12, 34, 00)

    touch("-m -t 010112341997 #@file")
    @mTime = Time.local(1997,  1,  1, 12, 34, 00)
  end

  def teardown
    ZFile.delete @file if File.exist?(@file)
    teardownTestDir
  end

  Windows.dont do    # FAT file systems only store mtime
    def test_s_atime
      assert_equal(@aTime, ZFile.atime(@file))
    end
  end

  def test_s_basename
    assert_equal("_touched", ZFile.basename(@file))
    assert_equal("tmp", ZFile.basename(File.join("/tmp")))
    assert_equal("b",   ZFile.basename(File.join(*%w( g f d s a b))))
    assert_equal("tmp", ZFile.basename("/tmp", ".*"))
    assert_equal("tmp", ZFile.basename("/tmp", ".c"))
    assert_equal("tmp", ZFile.basename("/tmp.c", ".c"))
    assert_equal("tmp", ZFile.basename("/tmp.c", ".*"))
    assert_equal("tmp.o", ZFile.basename("/tmp.o", ".c"))
    Version.greater_or_equal("1.8.0") do
      assert_equal("tmp", ZFile.basename(File.join("/tmp/")))
      assert_equal("/",   ZFile.basename("/"))
      assert_equal("/",   ZFile.basename("//"))
      assert_equal("base", ZFile.basename("dir///base", ".*"))
      assert_equal("base", ZFile.basename("dir///base", ".c"))
      assert_equal("base", ZFile.basename("dir///base.c", ".c"))
      assert_equal("base", ZFile.basename("dir///base.c", ".*"))
      assert_equal("base.o", ZFile.basename("dir///base.o", ".c"))
      assert_equal("base", ZFile.basename("dir///base///"))
      assert_equal("base", ZFile.basename("dir//base/", ".*"))
      assert_equal("base", ZFile.basename("dir//base/", ".c"))
      assert_equal("base", ZFile.basename("dir//base.c/", ".c"))
      assert_equal("base", ZFile.basename("dir//base.c/", ".*"))
      assert_equal("base.o", ZFile.basename("dir//base.o/", ".c"))
    end
    Version.less_than("1.8.0") do
      assert_equal("", ZFile.basename(File.join("/tmp/")))
      assert_equal("",   ZFile.basename("/"))
    end

    Version.greater_or_equal("1.7.2") do
      unless ZFile::ALT_SEPARATOR.nil?
        assert_equal("base", ZFile.basename("dir" + File::ALT_SEPARATOR + "base")) 
      end
    end
  end

  def test_s_chmod
    base = $os == Cygwin ? 0444 : 0
    assert_exception(Errno::ENOENT) { ZFile.chmod(0, "_gumby") }
    assert_equal(0, ZFile.chmod(0))
    Dir.chdir("_test")
    begin
      assert_equal(1,         ZFile.chmod(0, "_file1"))
      assert_equal(2,         ZFile.chmod(0, "_file1", "_file2"))
      assert_equal(base,      ZFile.stat("_file1").mode & 0777)
      assert_equal(1,         ZFile.chmod(0400, "_file1"))
      assert_equal(base|0400, ZFile.stat("_file1").mode & 0777)
      assert_equal(1,         ZFile.chmod(0644, "_file1"))
      assert_equal(base|0644, ZFile.stat("_file1").mode & 0777)
    ensure
      Dir.chdir("..")
    end
  end

  def test_s_chown
    super_user
  end

  def test_s_ctime
    sys("touch  #@file")
    ctime = RubiconStat::ctime(@file)
    @cTime = Time.at(ctime)

    assert_equal(@cTime, ZFile.ctime(@file))
  end

  def test_s_delete
    Dir.chdir("_test")
    assert_equal(0, ZFile.delete)
    assert_exception(Errno::ENOENT) { ZFile.delete("gumby") }
    assert_equal(2, ZFile.delete("_file1", "_file2"))
  end

  def test_s_dirname
    assert_equal("/",         ZFile.dirname(File.join("/tmp")))
    assert_equal("g/f/d/s/a", ZFile.dirname(File.join(*%w( g f d s a b))))
    assert_equal("/",         ZFile.dirname("/"))

    Version.greater_or_equal("1.8.0") do
      assert_equal("/",       ZFile.dirname(File.join("/tmp/")))
    end
    Version.less_than("1.8.0") do
      assert_equal("/tmp",    ZFile.dirname(File.join("/tmp/")))
    end

    Version.greater_or_equal("1.7.2") do
      unless ZFile::ALT_SEPARATOR.nil? 
        assert_equal("dir", ZFile.dirname("dir" + File::ALT_SEPARATOR + "base")) 
      end
    end
  end

  def test_s_expand_path
    if $os == MsWin32
      base = `cd`.chomp.tr '\\', '/'
    else
      base = `pwd`.chomp
    end

    assert_equal(base,                 ZFile.expand_path(''))
    assert_equal(ZFile.join(base, 'a'), File.expand_path('a'))
    assert_equal(ZFile.join(base, 'a'), File.expand_path('a', nil)) # V0.1.1

    # Because of Ruby-Talk:18512
    assert_equal(ZFile.join(base, 'a.'),    File.expand_path('a.')) 
    assert_equal(ZFile.join(base, '.a'),    File.expand_path('.a')) 
    assert_equal(ZFile.join(base, 'a..'),   File.expand_path('a..')) 
    assert_equal(ZFile.join(base, '..a'),   File.expand_path('..a')) 
    assert_equal(ZFile.join(base, 'a../b'), File.expand_path('a../b')) 

    b1 = ZFile.join(base.split(File::SEPARATOR)[0..-2])
    assert_equal(b1, ZFile.expand_path('..'))

    assert_equal('/tmp',   ZFile.expand_path('', '/tmp'))
    assert_equal('/tmp/a', ZFile.expand_path('a', '/tmp'))
    assert_equal('/tmp/a', ZFile.expand_path('../a', '/tmp/xxx'))
    assert_equal('/',      ZFile.expand_path('.', '/'))

    home = ENV['HOME']
    if (home)
      assert_equal(home, ZFile.expand_path('~'))
      assert_equal(home, ZFile.expand_path('~', '/tmp/gumby/ddd'))
      assert_equal(ZFile.join(home, 'a'),
                         ZFile.expand_path('~/a', '/tmp/gumby/ddd'))
    else
      skipping("$HOME not set")
    end

    begin
      ZFile.open("/etc/passwd") do |pw|
	users = pw.readlines
	line = ''
	line = users.pop while users.nitems > 0 and (line.length == 0 || /^\+:/ =~ line)
	if line.length > 0 
	  line = line.split(':')
	  name, home = line[0], line[-2]
	  assert_equal(home, ZFile.expand_path("~#{name}"))
	  assert_equal(home, ZFile.expand_path("~#{name}", "/tmp/gumby"))
	  assert_equal(ZFile.join(home, 'a'),
		       ZFile.expand_path("~#{name}/a", "/tmp/gumby"))
	end
      end
    rescue Errno::ENOENT
      skipping("~user")
    end
  end

  def test_s_ftype
    Dir.chdir("_test")
    sock = nil

    MsWin32.dont do
      sock = UNIXServer.open("_sock")
      ZFile.symlink("_file1", "_file3") # may fail
    end

    begin
      tests = {
        "../_test" => "directory",
        "_file1"   => "file",
      }

      Windows.dont do
	begin
	  tests[ZFile.expand_path(File.readlink("/dev/tty"), "/dev")] =
	    "characterSpecial"
	rescue Errno::EINVAL
	  tests["/dev/tty"] = "characterSpecial"
	end
      end

      MsWin32.dont do
        tests["_file3"] = "link"
	tests["_sock"]  = "socket"
      end

      Linux.only do
        tests["/dev/"+`readlink /dev/fd0 || echo fd0`.chomp] = "blockSpecial"
	system("mkfifo _fifo") # may fail
	tests["_fifo"] = "fifo"
      end

      tests.each { |file, type|
        if ZFile.exists?(file)
          assert_equal(type, ZFile.ftype(file), file.dup)
        else
          skipping("#{type} not supported")
        end
      }
    ensure
      sock.close if sock 
    end
  end

  def test_s_join

    [
      %w( a b c d ),
      %w( a ),
      %w( ),
      %w( a b .. c )
    ].each do |a|
      assert_equal(a.join(ZFile::SEPARATOR), File.join(*a))
    end
  end

  def test_s_link
    Dir.chdir("_test")
    begin
      assert_equal(0, ZFile.link("_file1", "_file3"))
      
      assert(ZFile.exists?("_file3"))
      Windows.dont do
	assert_equal(2, ZFile.stat("_file1").nlink)
	assert_equal(2, ZFile.stat("_file3").nlink)
	assert(ZFile.stat("_file1").ino == File.stat("_file3").ino)
      end
    ensure
      Dir.chdir("..")
    end
  end

  MsWin32.dont do
    def test_s_lstat
      
      Dir.chdir("_test")
      ZFile.symlink("_file1", "_file3") # may fail
      
      assert_equal(0, ZFile.stat("_file3").size)
      assert(0 < ZFile.lstat("_file3").size)
      
      assert_equal(0, ZFile.stat("_file1").size)
      assert_equal(0,  ZFile.lstat("_file1").size)
    end
  end

  def test_s_mtime
    assert_equal(@mTime, ZFile.mtime(@file))
  end

  def test_s_open
    file1 = "_test/_file1"

    assert_exception(Errno::ENOENT) { ZFile.open("_gumby") }

    # test block/non block forms
    
    f = ZFile.open(file1)
    begin
      assert_equal(ZFile, f.class)
    ensure
      f.close
    end

    assert_nil(ZFile.open(file1) { |f| assert_equal(File, f.class)})

    # test modes

    modes = [
      %w( r w r+ w+ a a+ ),
      [ ZFile::RDONLY, 
        ZFile::WRONLY | File::CREAT,
        ZFile::RDWR,
        ZFile::RDWR   + File::TRUNC + File::CREAT,
        ZFile::WRONLY + File::APPEND + File::CREAT,
        ZFile::RDWR   + File::APPEND + File::CREAT
        ]]

    for modeset in modes
      sys("rm -f #{file1}")
      sys("touch #{file1}")

      mode = modeset.shift      # "r"

      # file: empty
      ZFile.open(file1, mode) { |f| 
        assert_nil(f.gets)
        assert_exception(IOError) { f.puts "wombat" }
      }

      mode = modeset.shift      # "w"

      # file: empty
      ZFile.open(file1, mode) { |f| 
        assert_nil(f.puts("wombat"))
        assert_exception(IOError) { f.gets }
      }

      mode = modeset.shift      # "r+"

      # file: wombat
      ZFile.open(file1, mode) { |f| 
        assert_equal("wombat\n", f.gets)
        assert_nil(f.puts("koala"))
        f.rewind
        assert_equal("wombat\n", f.gets)
        assert_equal("koala\n", f.gets)
      }

      mode = modeset.shift      # "w+"

      # file: wombat/koala
      ZFile.open(file1, mode) { |f| 
        assert_nil(f.gets)
        assert_nil(f.puts("koala"))
        f.rewind
        assert_equal("koala\n", f.gets)
      }

      mode = modeset.shift      # "a"

      # file: koala
      ZFile.open(file1, mode) { |f| 
        assert_nil(f.puts("wombat"))
        assert_exception(IOError) { f.gets }
      }
      
      mode = modeset.shift      # "a+"

      # file: koala/wombat
      ZFile.open(file1, mode) { |f| 
        assert_nil(f.puts("wallaby"))
        f.rewind
        assert_equal("koala\n", f.gets)
        assert_equal("wombat\n", f.gets)
        assert_equal("wallaby\n", f.gets)
      }

    end

    # Now try creating files

    filen = "_test/_filen"

    ZFile.open(filen, "w") {}
    begin
      assert(ZFile.exists?(filen))
    ensure
      ZFile.delete(filen)
    end
    
    ZFile.open(filen, File::CREAT, 0444) {}
    begin
      assert(ZFile.exists?(filen))
      Cygwin.known_problem do
        assert_equal(0444 & ~ZFile.umask, File.stat(filen).mode & 0777)
      end
    ensure
      ZFile.delete(filen)
    end
  end

  def test_s_readlink
    MsWin32.dont do 
      Dir.chdir("_test")
      ZFile.symlink("_file1", "_file3") # may fail
      assert_equal("_file1", ZFile.readlink("_file3"))
      assert_exception(Errno::EINVAL) { ZFile.readlink("_file1") }
    end
  end

  def test_s_rename
    Dir.chdir("_test")
    assert_exception(Errno::ENOENT) { ZFile.rename("gumby", "pokey") }
    assert_equal(0, ZFile.rename("_file1", "_renamed"))
    assert(!ZFile.exists?("_file1"))
    assert(ZFile.exists?("_renamed"))

  end

  def test_s_size
    file = "_test/_file1"
    assert_exception(Errno::ENOENT) { ZFile.size("gumby") }
    assert_equal(0, ZFile.size(file))
    ZFile.open(file, "w") { |f| f.puts "123456789" }
    if $os == MsWin32
      assert_equal(11, ZFile.size(file))
    else
      assert_equal(10, ZFile.size(file))
    end
  end

  def test_s_split
    %w{ "/", "/tmp", "/tmp/a", "/tmp/a/b", "/tmp/a/b/", "/tmp//a",
        "/tmp//"
    }.each { |file|
      assert_equals( [ ZFile.dirname(file), File.basename(file) ],
                     ZFile.split(file), file )
    }
  end

  # Stat is pretty much tested elsewhere, so we're minimal here
  def test_s_stat
    assert_instance_of(ZFile::Stat, File.stat("."))
  end


  def test_s_symlink
    MsWin32.dont do 
      Dir.chdir("_test")
      ZFile.symlink("_file1", "_file3") # may fail
      assert(ZFile.symlink?("_file3"))
      assert(!ZFile.symlink?("_file1"))
    end
  end

  def test_s_truncate
    file = "_test/_file1"
    ZFile.open(file, "w") { |f| f.puts "123456789" }
    if $os <= MsWin32
      assert_equal(11, ZFile.size(file))
    else
      assert_equal(10, ZFile.size(file))
    end
    ZFile.truncate(file, 5)
    assert_equal(5, ZFile.size(file))
    ZFile.open(file, "r") { |f|
      assert_equal("12345", f.read(99))
      assert(f.eof?)
    }
  end

  MsWin32.dont do
    def myUmask
      Integer(`sh -c umask`.chomp)
    end

    def test_s_umask
      orig = myUmask
      assert_equal(myUmask, ZFile.umask)
      assert_equal(myUmask, ZFile.umask(0404))
      assert_equal(0404, ZFile.umask(orig))
    end
  end

  
  def test_s_unlink
    Dir.chdir("_test")
    assert_equal(0, ZFile.unlink)
    assert_exception(Errno::ENOENT) { ZFile.unlink("gumby") }
    assert_equal(2, ZFile.unlink("_file1", "_file2"))
  end

  def test_s_utime
    Dir.chdir("_test")
    begin
      [ 
	[ Time.at(18000),             Time.at(53423) ],
	[ Time.at(Time.now.to_i), Time.at(54321) ],
	[ Time.at(121314),        Time.now.to_i ]
      ].each { |aTime, mTime|
	ZFile.utime(aTime, mTime, "_file1", "_file2")
	
	for file in [ "_file1", "_file2" ]
	  assert_equal(aTime, ZFile.stat(file).atime) # does automatic conversion
	  assert_equal(mTime, ZFile.stat(file).mtime)
	end
      }
    ensure
      Dir.chdir("..")
    end
  end

  # Instance methods

  Windows.dont do   # FAT filesystems don't store this properly
    def test_atime
      ZFile.open(@file) { |f| assert_equal(@aTime, f.atime) }
    end
  end

  # Apparently you can't remove read permission on a file
  # under cygwin (at least on W2K)

  def test_chmod
    base = $os == Cygwin ? 0444 : 0

    Dir.chdir("_test")
    ZFile.open("_file1") { |f|
      assert_equal(0,    f.chmod(0))
      assert_equal(base,    f.stat.mode & 0777)
      assert_equal(0,    f.chmod(0400))
      assert_equal(base | 0400, f.stat.mode & 0777)
      assert_equal(0,    f.chmod(0644))
      assert_equal(base | 0644, f.stat.mode & 0777)
    }
  end

  def test_chown
    super_user
  end

  def test_ctime
    sys("touch  #@file")
    ctime = RubiconStat::ctime(@file)
    @cTime = Time.at(ctime)

    ZFile.open(@file) { |f| assert_equal(@cTime, f.ctime) }
  end

  def test_flock
    MsWin32.dont do

      Dir.chdir("_test")
      
      # parent forks, then waits for a SIGUSR1 from child. Child locks file
      # and signals parent, then sleeps
      # When parent gets signal, confirms file si locked, kills child,
      # and confirms its unlocked
      
      pid = fork
      if pid
	ZFile.open("_file1", "w") { |f|
	  trap("USR1") {
	    assert_equal(false, f.flock(ZFile::LOCK_EX | File::LOCK_NB))
	    Process.kill "KILL", pid
	    Process.waitpid(pid, 0)
	    assert_equal(0, f.flock(ZFile::LOCK_EX | File::LOCK_NB))
	    return
	  }
	  sleep 10
	  assert_fail("Never got signalled")
	}
      else
	ZFile.open("_file1", "w") { |f|
	  assert_equal(0, f.flock(ZFile::LOCK_EX))
	  sleep 1
	  Process.kill "USR1", Process.ppid
	  sleep 10
	  assert_fail "Parent never killed us"
	}
      end
    end
  end

  def test_lstat
    MsWin32.dont do
      Dir.chdir("_test")

      begin
	ZFile.symlink("_file1", "_file3") # may fail
	f1 = ZFile.open("_file1")
	begin
	  f3 = ZFile.open("_file3")
	  
	  assert_equal(0, f3.stat.size)
	  assert(0 < f3.lstat.size)
	  
	  assert_equal(0, f1.stat.size)
	  assert_equal(0, f1.lstat.size)
	f3.close
	ensure
	  f1.close
	end
      ensure
	Dir.chdir("..")
      end
    end
  end

  def test_mtime
    ZFile.open(@file) { |f| assert_equal(@mTime, f.mtime) }
  end

  def test_path
    ZFile.open(@file) { |f| assert_equal(@file, f.path) }
  end

  def test_truncate
    file = "_test/_file1"
    ZFile.open(file, "w") { |f|
      f.syswrite "123456789" 
      f.truncate(5)
    }
    assert_equal(5, ZFile.size(file))
    ZFile.open(file, "r") { |f|
      assert_equal("12345", f.read(99))
      assert(f.eof?)
    }
  end


end

Rubicon::handleTests(TestFile) if $0 == __FILE__
