$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'stat'
require 'FileInfoTest.rb'

class TestZFile__Stat < FileInfoTest

  def setup
    super
    @s1 = ZFile.stat(@file1)
    @s2 = ZFile.stat(@file2)
  end

  # compares modified times
  def test_CMP # '<=>'
    assert_equal(0,  @s1 <=> @s1)
    assert_equal(0,  @s2 <=> @s2)
    assert_equal(+1, @s1 <=> @s2)
    assert_equal(-1, @s2 <=> @s1)
  end

  Windows.dont do     # not on FAT filesystems
    def test_atime
      assert_equal(@aTime1, @s1.atime)
      assert_equal(@aTime2, @s2.atime)
    end
  end

  def test_blksize
    blksize = checkstat(".").split[8].to_i
    if $? != 0 || blksize == -1
      skipping("Couldn't find block size")
    else
      assert_equal(blksize, ZFile.stat('.').blksize)
    end
  end

  def try(sym, file, expected)
    if ZFile.exist?(file)
      s = ZFile.stat(file)
      assert_equal(expected, s.send(sym), "ZFile: #{file}")
    else
      skipping("#{sym}: #{file} not found")
    end
  end

  def test_blockdev?
    try(:blockdev?, ".",        false)
    Unix.or_variant do
      try(:blockdev?, "/dev/tty", false)
      Linux.only do
	try(:blockdev?, "/dev/fd0", true)
      end
    end
  end

  MsWin32.dont do
    def test_blocks
      file = "_test/_size"
      ZFile.open(file, "w") { |f| }
      assert_equal(0, ZFile.stat(file).blocks)
      ZFile.open(file, "w") { |f| f.syswrite 'a'}
      assert(ZFile.stat(file).blocks > 0)
      assert(ZFile.stat(file).blocks < 16)
    end
  end

  def test_chardev?
    try(:chardev?, ".",        false)
    Unix.only do
      try(:chardev?, "/dev/tty", true)
      Linux.only do
	try(:chardev?, "/dev/fd0", false)
      end
    end
  end

  def test_ctime
    cTime1 = Time.at(RubiconStat::ctime(@file1))
    assert_equal(cTime1, @s1.ctime)
  end

  def test_dev
#    assert_fail("untested")
  end

  def test_directory?
    try(:directory?, "/dev/tty", false)
    try(:directory?, ".",        true)
    try(:directory?, "/dev/fd0", false)
  end

  def test_executable?
    try(:executable?, "/dev/tty", false)
    try(:executable?, "/bin/echo",true)
    try(:executable?, "/dev/fd0", false)
  end

  def test_executable_real?
#    assert_fail("untested")
  end

  def test_file?
    try(:file?, "/dev/tty", false)
    try(:file?, ".",        false)
    try(:file?, "/dev/fd0", false)
    try(:file?, @file1,     true)
  end

  def test_ftype
    Dir.chdir("_test")
    MsWin32.dont do
      ZFile.symlink("_file1", "_file3") # may fail
    end

    tests = {
      "../_test"          => "directory",
      "_file1"            => "file",
      "/dev/tty"          => "characterSpecial",
      "/tmp/.X11-unix/X0" => "socket",
    }

    MsWin32.dont do
      tests["_file3"]     =  "file"
    end

    Linux.only do
      tests["/dev/fd0"]   = "blockSpecial"
      system("mkfifo _fifo") # may fail
      tests["_fifo"]      = "fifo" 
    end

    tests.each do |file, type|
      try(:ftype, file, type)
    end

    MsWin32.dont do
      assert_equal("link", ZFile.lstat("_file3").ftype)
    end
  end

  Linux.only do
    def test_gid
      assert_equal(Process.gid, @s1.gid)
    end
    
    def test_grpowned?
      try(:grpowned?, @file1,        true)
      Unix.or_variant do
        try(:grpowned?, "/etc/passwd", Process.egid == 0)
      end
    end
  end

  Linux.dont do
    def test_gid
      skipping "Behavior unknown (feel free up update!)"
    end
    
    def test_grpowned?
      skipping "Behavior unknown (feel free up update!)"
    end
  end

  def test_ino
    Dir.chdir("_test")
    ZFile.link("_file1", "_file3") # may fail
    assert(ZFile.stat("_file1").ino > 0)
    assert(ZFile.stat("_file2").ino > 0)
    assert_equal(ZFile.stat("_file1").ino, ZFile.stat("_file3").ino)
  end

  def test_mode
    base = $os <= Windows ? 0444 : 0

    Dir.chdir("_test")
    begin
      ZFile.open("_file1") do |f|
	assert_equal(0,           f.chmod(0))
	assert_equal(base,        f.stat.mode & 0777)
	assert_equal(0,           f.chmod(0400))
	assert_equal(base | 0400, f.stat.mode & 0777)
	assert_equal(0,           f.chmod(0644))
	assert_equal(base | 0644, f.stat.mode & 0777)
      end
    ensure
      Dir.chdir("..")
    end
  end

  def test_mtime
    assert_equal(@mTime1, @s1.mtime)
    assert_equal(@mTime2, @s2.mtime)
 end

  def test_nlink
    Dir.chdir("_test")
    ZFile.link("_file1", "_file3") # may fail
    try(:nlink, "_file1", 2)
    try(:nlink, "_file2", 1)
    try(:nlink, "_file3", 2)
  end

  def test_owned?
    try(:owned?, @file1,        true)
    Unix.or_variant do
      try(:owned?, "/etc/passwd", Process.euid == 0)
    end
  end

  def test_pipe?
    Unix.or_variant do
      try(:pipe?, "/dev/tty", false)
    end

    try(:pipe?, ".",        false)
    
    MsWin32.dont do
      IO.popen("-") do |p|
	assert_equal(true, (p ? p : $stdout).stat.pipe?)
      end
    end
  end

  def test_rdev
    # assert_fail("untested")
  end

  def test_readable?
    try(:readable?, @file1, true)
    Windows.known_problem do
      ZFile.chmod(0222, @file1)
      try(:readable?, @file1, false)
    end
  end

  def test_readable_real?
#    assert_fail("untested")
  end

  Unix.or_variant do
    
    def test_setgid?
      try(:setgid?, @file1, false)
      ZFile.chmod(02644, @file1)
      try(:setgid?, @file1, true)
    end
    
    def test_setuid?
      try(:setuid?, @file1, false)
      ZFile.chmod(04644, @file1)
      try(:setuid?, @file1, true)
    end
  end

  def test_size
    ZFile.open(@file1, "w") { |f| f.syswrite "wombat" }
    try(:size, @file1, 6 )
    try(:size, @file2, 0)
  end

  def test_size?
    ZFile.open(@file1, "w") { |f| f.syswrite "wombat" }
    try(:size?, @file1, 6 )
    try(:size?, @file2, nil)
  end

  def test_socket?
    try(:socket?, "/dev/tty", false)
    try(:socket?, ".",        false)
    try(:socket?, @file1,     false)
    try(:socket?, "/tmp/.X11-unix/X0", true)
  end

  Unix.or_variant do
    def test_sticky?
      Dir.chdir("_test")
      m = ZFile.stat(".").mode
      begin
	ZFile.chmod(m | 01000, ".")
	try(:sticky?, ".",      true)
      ensure
	ZFile.chmod(m, ".")
      end
      try(:sticky?, ".",        false)
      try(:sticky?, "/dev/tty", false)
      try(:sticky?, "_file2",   false)
    end
  end

  MsWin32.dont do
    def test_symlink?
      Dir.chdir("_test")
      ZFile.symlink("_file1", "_symlink")
      try(:symlink?, ".",        false)
      try(:symlink?, "/dev/tty", false)
      try(:symlink?, "_file1",   false)
      try(:symlink?, "_symlink", false)  # try uses stat
      assert(ZFile.lstat("_symlink").symlink?)
    end
  end

  def test_uid
    assert_equal(Process.uid, @s1.uid)
  end

  def test_writable?
    ZFile.chmod(0444, @file1)
    try(:writable?, @file1, false)
    try(:writable?, @file2, true)
  end

  def test_writable_real?
#    assert_fail("untested")
  end

  def test_zero?
    ZFile.open(@file1, "w") { |f| f.puts "wombat" }
    try(:zero?, @file1, false)
    try(:zero?, @file2, true)
  end

end

Rubicon::handleTests(TestZFile__Stat) if $0 == __FILE__
