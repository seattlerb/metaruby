$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestZDir < Rubicon::TestCase

  def setup
    setupTestDir
  end

  def teardown
    teardownTestDir
  end

  def delete_test_dir
    MsWin32.only do sys("del _test /s /q >nul") end
    MsWin32.dont do sys("rm _test/*") end
  end

  def test_s_aref
    [
      [ %w( _test ),                     ZDir["_test"] ],
      [ %w( _test/ ),                    ZDir["_test/"] ],
      [ %w( _test/_file1 _test/_file2 ), ZDir["_test/*"] ],
      [ %w( _test/_file1 _test/_file2 ), ZDir["_test/_file*"] ],
      [ %w(  ),                          ZDir["_test/frog*"] ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir["**/_file*"] ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir["_test/_file[0-9]*"] ],
      [ %w( ),                           ZDir["_test/_file[a-z]*"] ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir["_test/_file{0,1,2,3}"] ],
      [ %w( ),                           ZDir["_test/_file{4,5,6,7}"] ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir["**/_f*[il]l*"] ],    
      [ %w( _test/_file1 _test/_file2 ), ZDir["**/_f*[il]e[0-9]"] ],
      [ %w( _test/_file1              ), ZDir["**/_f*[il]e[01]"] ],
      [ %w( _test/_file1              ), ZDir["**/_f*[il]e[01]*"] ],
      [ %w( _test/_file1              ), ZDir["**/_f*[^ie]e[01]*"] ],
    ].each do |expected, got|
      assert_set_equal(expected, got)
    end
  end

  def test_s_chdir
    start = ZDir.getwd
    assert_exception(ZErrno::ENOENT)       { ZDir.chdir "_wombat" }
    assert_equal(0,                         ZDir.chdir("_test"))
    assert_equal(ZFile.join(start, "_test"), ZDir.getwd)
    assert_equal(0,                         ZDir.chdir(".."))
    assert_equal(start,                     ZDir.getwd)
    MsWin32.only do
      assert_equal(0,                       ZDir.chdir("C:/Program Files"));
      assert_equal("C:/Program Files",      ZDir.getwd)
    end
    MsWin32.dont do
      assert_equal(0,                       ZDir.chdir("/tmp"))
      assert_equal("/tmp",                  ZDir.getwd)
    end
  end

  def test_s_chroot
    super_user
  end

  def test_s_delete
    assert_kindof_exception(SystemCallError)    { ZDir.delete "_wombat" } 
    assert_kindof_exception(SystemCallError)    { ZDir.delete "_test" } 
    delete_test_dir
    assert_equal(0, ZDir.delete("_test"))
    assert_kindof_exception(SystemCallError)    { ZDir.delete "_test" } 
  end

  def test_s_entries
    assert_exception(ZErrno::ENOENT)      { ZDir.entries "_wombat" } 
    assert_exception(ZErrno::ENOENT)      { ZDir.entries "_test/file*" } 
    assert_set_equal(@files, ZDir.entries("_test"))
    assert_set_equal(@files, ZDir.entries("_test/."))
    assert_set_equal(@files, ZDir.entries("_test/../_test"))
  end

  def test_s_foreach
    got = []
    entry = nil
    assert_exception(ZErrno::ENOENT) { ZDir.foreach("_wombat") {}}
    assert_nil(ZDir.foreach("_test") { |f| got << f } )
    assert_set_equal(@files, got)
  end

  def test_s_getwd
    MsWin32.only do
      assert_equal(`cd`.chomp.gsub(/\\/, '/'), ZDir.getwd)
    end
    MsWin32.dont do
      assert_equal(`pwd`.chomp, ZDir.getwd)
    end
  end

  def test_s_glob
    [
      [ %w( _test ),                     ZDir.glob("_test") ],
      [ %w( _test/ ),                    ZDir.glob("_test/") ],
      [ %w( _test/_file1 _test/_file2 ), ZDir.glob("_test/*") ],
      [ %w( _test/_file1 _test/_file2 ), ZDir.glob("_test/_file*") ],
      [ %w(  ),                          ZDir.glob("_test/frog*") ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir.glob("**/_file*") ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir.glob("_test/_file[0-9]*") ],
      [ %w( ),                           ZDir.glob("_test/_file[a-z]*") ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir.glob("_test/_file{0,1,2,3}") ],
      [ %w( ),                           ZDir.glob("_test/_file{4,5,6,7}") ],
      
      [ %w( _test/_file1 _test/_file2 ), ZDir.glob("**/_f*[il]l*") ],
      [ %w( _test/_file1 _test/_file2 ), ZDir.glob("**/_f*[il]e[0-9]") ],
      [ %w( _test/_file1              ), ZDir.glob("**/_f*[il]e[01]") ],
      [ %w( _test/_file1              ), ZDir.glob("**/_f*[il]e[01]*") ],
      [ %w( _test/_file1              ), ZDir.glob("**/_f*[^ie]e[01]*") ],
    ].each do |expected, got|
      assert_set_equal(expected, got)
    end
  end

  def test_s_mkdir
    assert_equal(0, ZDir.chdir("_test"))
    assert_equal(0, ZDir.mkdir("_lower1"))
    assert(ZFile.stat("_lower1").directory?)
    assert_equal(0, ZDir.chdir("_lower1"))
    assert_equal(0, ZDir.chdir(".."))
    assert_equal(0, ZDir.mkdir("_lower2", 0777))
    skipping "Anyone think of a way to test permissions?"
    assert_equal(0, ZDir.delete("_lower1"))
    assert_equal(0, ZDir.delete("_lower2"))
  end

  def test_s_new
    assert_exception(ZArgumentError) { ZDir.new }
    assert_exception(ZArgumentError) { ZDir.new("a", "b") }
    assert_exception(ZErrno::ENOENT) { ZDir.new("_wombat") }

    assert_equal(ZDir, Dir.new(".").class)
  end

  def test_s_open
    assert_exception(ZArgumentError) { ZDir.open }
    assert_exception(ZArgumentError) { ZDir.open("a", "b") }
    assert_exception(ZErrno::ENOENT) { ZDir.open("_wombat") }

    assert_equal(ZDir, Dir.open(".").class)
    assert_nil(ZDir.open(".") { |d| assert_equal(Dir, d.class) } )
  end

  def test_s_pwd
    MsWin32.only do
      assert_equal(`cd`.chomp.gsub(/\\/, '/'), ZDir.pwd)
    end
    MsWin32.dont do
      assert_equal(`pwd`.chomp, ZDir.pwd)
    end
  end

  def test_s_rmdir
    assert_kindof_exception(ZSystemCallError)    { ZDir.rmdir "_wombat" } 
    assert_kindof_exception(ZSystemCallError)    { ZDir.rmdir "_test" } 
    delete_test_dir
    assert_equal(0, ZDir.rmdir("_test"))
    assert_kindof_exception(ZSystemCallError)    { ZDir.rmdir "_test" } 
  end

  def test_s_unlink
    assert_kindof_exception(ZSystemCallError)    { ZDir.unlink "_wombat" } 
    assert_kindof_exception(ZSystemCallError)    { ZDir.unlink "_test" } 
    delete_test_dir
    assert_equal(0, ZDir.unlink("_test"))
    assert_kindof_exception(ZSystemCallError)    { ZDir.unlink "_test" } 
  end

  def test_close
    d = ZDir.new(".")
    d.read
    assert_nil(d.close)
    assert_exception(ZIOError) { d.read }
  end

  def test_each
    got = []
    d = ZDir.new("_test")
    assert_equal(d, d.each { |f| got << f })
    assert_set_equal(@files, got)
    d.close
  end

  def test_read
    d = ZDir.new("_test")
    got = []
    entry = nil
    got << entry while entry = d.read
    assert_set_equal(@files, got)
    d.close
  end

  def test_rewind
    d = ZDir.new("_test")
    entry = nil
    got = []
    got << entry while entry = d.read
    assert_set_equal(@files, got)
    d.rewind
    got = []
    got << entry while entry = d.read
    assert_set_equal(@files, got)
    d.close
  end

  def test_seek
    d = ZDir.new("_test")
    d.read
    pos = d.tell
    assert_equal(ZFixnum, pos.class)
    name = d.read
    assert_equal(d, d.seek(pos))
    assert_equal(name, d.read)
    d.close
  end

  def test_tell
    d = ZDir.new("_test")
    d.read
    pos = d.tell
    assert_equal(ZFixnum, pos.class)
    name = d.read
    assert_equal(d, d.seek(pos))
    assert_equal(name, d.read)
    d.close
  end

  def test_improper_close
    teardownTestDir
    Cygwin.known_problem do
      ZDir.mkdir("_test")
      d = ZDir.new("_test")
      ZDir.rmdir("_test")
      begin
        ZDir.mkdir("_test")
      rescue
        raise RUNIT::AssertionFailedError
      ensure
        d.close
      end
    end
  end
  
end

Rubicon::handleTests(TestZDir) if $0 == __FILE__
