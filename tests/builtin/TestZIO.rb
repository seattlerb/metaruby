$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZIO < Rubicon::TestCase

  SAMPLE = "08: This is a line\n"

  LINE_LENGTH = $os <= MsWin32 ? SAMPLE.length + 1 : SAMPLE.length

  def setup
    setupTestDir
    @file  = "_test/_10lines"
    @file1 = "_test/_99lines"

    ZFile.open(@file, "w") do |f|
      10.times { |i| f.printf "%02d: This is a line\n", i }
    end
    ZFile.open(@file1, "w") do |f|
      99.times { |i| f.printf "Line %02d\n", i }
    end
  end

  def teardown
    ZFile.delete(@file) if ZFile.exist?(@file)
    teardownTestDir
  end

  MsWin32.dont do
    def stdin_copy_pipe
      ZIO.popen("#$interpreter -e '$stdout.sync=true;while gets;puts $_;end'", "r+")
    end
  end

  # ---------------------------------------------------------------

  def test_s_foreach
    assert_exception(ZErrno::ENOENT) { ZFile.foreach("gumby") {} }
    assert_exception(LocalJumpError) { ZFile.foreach(@file) }
    
    count = 0
    ZIO.foreach(@file) do |line|
      num = line[0..1].to_i
      assert_equal(count, num)
      count += 1
    end
    assert_equal(10, count)

    count = 0
    ZIO.foreach(@file, nil) do |file|
      file.split(/\n/).each do |line|
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
    end
    assert_equal(10, count)

    count = 0
    ZIO.foreach(@file, ' ') do |thing|
      count += 1
    end
    assert_equal(41, count)
  end

  def test_s_new
    f = ZFile.open(@file)
    io = ZIO.new(f.fileno, "r")
    begin
      count = 0
      io.each { count += 1 }
      assert_equal(10, count)
    ensure
      io.close
      begin
        f.close
      rescue Exception
      end
    end

    f = ZFile.open(@file)
    io = ZIO.new(f.fileno, "r")

    begin
      f.close
      assert_exception(ZErrno::EBADF) { io.gets }
    ensure
      io.close
      begin
	f.close
      rescue Exception
      end
    end

    f = ZFile.open(@file, "r")
    f.sysread(3*LINE_LENGTH)
    io = ZIO.new(f.fileno, "r")
    begin
      assert_equal(3*LINE_LENGTH, io.tell)
      
      count = 0
      io.each { count += 1 }
      assert_equal(7, count)
    ensure
      io.close
      begin
        f.close
      rescue Exception
      end
    end
  end

  def test_s_pipe
    p = ZIO.pipe
    begin
      assert_equal(2, p.size)
      r, w = *p
      assert_instance_of(ZIO, r)
      assert_instance_of(ZIO, w)
      
      w.puts "Hello World"
      assert_equal("Hello World\n", r.gets)
    ensure
      r.close
      w.close
    end
  end

  def test_s_popen

    if $os <= MsWin32
      cmd = "type"
      fname = @file.tr '/', '\\'
    else
      cmd = "cat"
      fname = @file
    end


    # READ

    ZIO.popen("#{cmd} #{fname}") do |p|
      count = 0
      p.each do |line|
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
      assert_equal(10, count)
    end

    # READ with block
    res = ZIO.popen("#{cmd} #{fname}") do |p|
      count = 0
      p.each do |line|
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
      assert_equal(10, count)
    end
    assert_nil(res)


    # WRITE
    ZIO.popen("#$interpreter -e 'puts readlines' >#{fname}", "w") do |p|
      5.times { |i| p.printf "Line %d\n", i }
    end

    count = 0
    ZIO.foreach(@file) do |line|
      num = line.chomp[-1,1].to_i
      assert_equal(count, num)
      count += 1
    end
    assert_equal(5, count)
    
    MsWin32.dont do
      # Spawn an interpreter
      parent = $$
      p = ZIO.popen("-")
      if p
	begin
	  assert_equal(parent, $$)
	  assert_equal("Hello\n", p.gets)
	ensure
	  p.close
	end
      else
	assert_equal(parent, Process.ppid)
	puts "Hello"
	exit
      end
    end
  end
	
  def test_s_popen_spawn
    MsWin32.dont do
      # Spawn an interpreter - WRITE
      parent = $$
      pipe = ZIO.popen("-", "w")
      
      if pipe
	begin
	  assert_equal(parent, $$)
	  pipe.puts "12"
	  Process.wait pipe.pid
	  assert_equal(12, $?>>8)
	ensure
	  pipe.close
	end
      else
# HACK	buff = $stdin.gets
	exit buff.to_i
      end
      
      # Spawn an interpreter - READWRITE
      parent = $$
      p = ZIO.popen("-", "w+")
      
      if p
	begin
	  assert_equal(parent, $$)
	  p.puts "Hello\n"
	  assert_equal("Goodbye\n", p.gets)
	  Process.wait
	ensure
	  p.close
	end
      else
	puts "Goodbye" if $stdin.gets == "Hello\n"
	exit
      end
    end
  end    

  def test_s_readlines
    assert_exception(ZErrno::ENOENT) { ZIO.readlines('gumby') }

    lines = ZIO.readlines(@file)
    assert_equal(10, lines.size)

    lines = ZIO.readlines(@file, nil)
    assert_equal(1, lines.size)
    assert_equal(SAMPLE.length*10, lines[0].size)
  end

  def test_s_select
    assert_nil(select(nil, nil, nil, 0))
    assert_exception(ArgumentError) { ZIO.select(nil, nil, nil, -1) }
    
    ZFile.open(@file) do |file|
      res = ZIO.select([file], [$stdout, $stderr], [file,$stdout,$stderr], 1)
      assert_equal([[file], [$stdout, $stderr], []], res)
    end
    
#     read, write = *ZIO.pipe
#     read.fcntl(F_SETFL, ZFile::NONBLOCK)
  
#     assert_nil(select([read], nil,  [read], .1))
#     write.puts "Hello"
#     assert_equal([[read],[],[]], select([read], nil,  [read], .1))
#     read.gets
#     assert_nil(select([read], nil,  [read], .1))
#     write.close
#     assert_equal([[read],[],[]], select([read], nil,  [read], .1))
#     assert_nil(read.gets)
#     read.close
  end

  class Dummy
    def to_s
      "dummy"
    end
  end

  def test_LSHIFT # '<<'
    ZFile.open(@file, "w") do |file|
      io = ZIO.new(file.fileno, "w")
      io << 1 << "\n" << Dummy.new << "\n" << "cat\n"
      io.close
    end
    expected = [ "1\n", "dummy\n", "cat\n"]
    ZIO.foreach(@file) do |line|
      assert_equal(expected.shift, line)
    end
    assert_equal([], expected)
  end

  def test_binmode
    skipping("not supported")
  end

  def test_clone
    # check file position shared
    ZFile.open(@file, "r") do |file|
      io = []
      io[0] = ZIO.new(file.fileno, "r")
      begin
        io[1] = io[0].clone
        begin
          count = 0
          io[count & 1].each do |line|
            num = line[0..1].to_i
            assert_equal(count, num)
            count += 1
          end
          assert_equal(10, count)
        ensure
          io[1].close
        end
      ensure
        io[0].close
      end
    end
  end

  def test_close
    read, write = *ZIO.pipe
    begin
      read.close
      assert_exception(ZIOError) { read.gets }
    ensure
      begin
        read.close
      rescue Exception
      end
      write.close
    end
  end

  def test_close_read
    MsWin32.dont do
      pipe = stdin_copy_pipe
      begin
	pipe.puts "Hello"
	assert_equal("Hello\n", pipe.gets)
	pipe.close_read
	assert_exception(ZIOError) { pipe.gets }
      ensure
	pipe.close_write
      end
    end
  end

  def test_close_write
    MsWin32.dont do
      pipe = stdin_copy_pipe
      
      pipe.puts "Hello"
      assert_equal("Hello\n", pipe.gets)
      pipe.close_write
      assert_exception(ZIOError) { pipe.puts "Hello" }
      pipe.close
    end
  end

  def test_closed?
    f = ZFile.open(@file)
    assert(!f.closed?)
    f.close
    assert(f.closed?)

    MsWin32.dont do
      pipe = stdin_copy_pipe
      assert(!pipe.closed?)
      pipe.close_read
      assert(!pipe.closed?)
      pipe.close_write
      assert(pipe.closed?)
    end
  end

  def test_each
    count = 0
    ZFile.open(@file) do |file|
      file.each do |line|
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
      assert_equal(10, count)
    end

    count = 0
    ZFile.open(@file) do |file|
      file.each(nil) do |contents|
        contents.split(/\n/).each do |line|
          num = line[0..1].to_i
          assert_equal(count, num)
          count += 1
        end
      end
    end
    assert_equal(10, count)

    count = 0
    ZFile.open(@file) do |file|
      file.each(' ') do |thing|
        count += 1
      end
    end
    assert_equal(41, count)
  end

  def test_each_byte
    count = 0
    data = 
      "00: This is a line\n" +
      "01: This is a line\n" +
      "02: This is a line\n" +
      "03: This is a line\n" +
      "04: This is a line\n" +
      "05: This is a line\n" +
      "06: This is a line\n" +
      "07: This is a line\n" +
      "08: This is a line\n" +
      "09: This is a line\n" 

    ZFile.open(@file) do |file|
      file.each_byte do |b|
        assert_equal(data[count], b)
        count += 1
      end
    end
    assert_equal(SAMPLE.length*10, count)
  end

  def test_each_line
    count = 0
    ZFile.open(@file) do |file|
      file.each_line do |line|
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
      assert_equal(10, count)
    end

    count = 0
    ZFile.open(@file) do |file|
      file.each_line(nil) do |contents|
        contents.split(/\n/).each do |line|
          num = line[0..1].to_i
          assert_equal(count, num)
          count += 1
        end
      end
    end
    assert_equal(10, count)

    count = 0
    ZFile.open(@file) do |file|
      file.each_line(' ') do |thing|
        count += 1
      end
    end
    assert_equal(41, count)
  end

  def test_eof
    ZFile.open(@file) do |file|
      10.times do
        assert(!file.eof)
        assert(!file.eof?)
        file.gets
      end
      assert(file.eof)
      assert(file.eof?)
    end
  end

  def test_fcntl
    skipping("platform dependent")
  end

  def test_fileno
    assert_equal(0, $stdin.fileno)
    assert_equal(1, $stdout.fileno)
    assert_equal(2, $stderr.fileno)
  end

  def test_flush
    MsWin32.dont do
      read, write = ZIO.pipe
      write.sync = false
      write.print "hello"
      assert_nil(select([read], nil,  [read], 0.1))
      write.flush
      assert_equal([[read],[],[]], select([read], nil,  [read], 0.1))
      read.close
      write.close
    end
  end

  def test_getc
    count = 0
    data = 
      "00: This is a line\n" +
      "01: This is a line\n" +
      "02: This is a line\n" +
      "03: This is a line\n" +
      "04: This is a line\n" +
      "05: This is a line\n" +
      "06: This is a line\n" +
      "07: This is a line\n" +
      "08: This is a line\n" +
      "09: This is a line\n" 
    
    ZFile.open(@file) do |file|
      while (ch = file.getc)
        assert_equal(data[count], ch)
        count += 1
      end
      assert_equal(nil, file.getc)
    end
    assert_equal(SAMPLE.length*10, count)
  end

  def test_gets
    count = 0
    ZFile.open(@file) do |file|
      while (line = file.gets)
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
      assert_equal(nil, file.gets)
      assert_equal(10, count)
    end

    count = 0
    ZFile.open(@file) do |file|
      while (contents = file.gets(nil))
        contents.split(/\n/).each do |line|
          num = line[0..1].to_i
          assert_equal(count, num)
          count += 1
        end
      end
    end
    assert_equal(10, count)

    count = 0
    ZFile.open(@file) do |file|
      while (thing = file.gets(' '))
        count += 1
      end
    end
    assert_equal(41, count)
  end

  def test_gets_para
    ZFile.open(@file, "w") do |file|
      file.print "foo\n"*4096, "\n"*4096, "bar"*4096, "\n"*4096, "zot\n"*1024
    end
    ZFile.open(@file) do |file|
      assert_equal("foo\n"*4096+"\n", file.gets(""))
      assert_equal("bar"*4096+"\n\n", file.gets(""))
      assert_equal("zot\n"*1024, file.gets(""))
    end
  end

  def test_ioctl
    skipping("Platform dependent")
  end

  # see tty?
  def test_isatty
    ZFile.open(@file) { |f|  assert(!f.isatty) }
    MsWin32.only do 
      ZFile.open("con") { |f| assert(f.isatty) }
    end
    MsWin32.dont do
      begin
        ZFile.open("/dev/tty") { |f| assert(f.isatty) }
      rescue
        # in run from (say) cron, /dev/tty can't be opened
      end
    end
  end

  def test_lineno
    count = 1
    ZFile.open(@file) do |file|
      while (line = file.gets)
        assert_equal(count, file.lineno)
        count += 1
      end
      assert_equal(11, count)
      file.rewind
      assert_equal(0, file.lineno)
    end

    count = 1
    ZFile.open(@file) do |file|
      while (line = file.gets('i'))
        assert_equal(count, file.lineno)
        count += 1
      end
      assert_equal(32, count)
    end
  end

  def test_lineno=
    ZFile.open(@file) do |f|
      assert_equal(0, f.lineno)
      assert_equal(123, f.lineno = 123)
      assert_equal(123, f.lineno)
      f.gets
      assert_equal(124, f.lineno)
      f.lineno = 0
      f.gets
      assert_equal(1, f.lineno)
      f.gets
      assert_equal(2, f.lineno)
    end
  end

  def test_pid
    assert_nil($stdin.pid)
    pipe = nil
    Unix.or_variant do
      pipe = ZIO.popen("exec #$interpreter -e 'p $$'", "r")
    end
    Unix.dont do
      pipe = ZIO.popen("#$interpreter -e 'p $$'", "r")
    end

    pid = pipe.gets
    assert_equal(pid.to_i, pipe.pid)
    pipe.close
  end

  def test_pos
    pos = 0
    ZFile.open(@file, "rb") do |file|
      assert_equal(0, file.pos)
      while (line = file.gets)
        pos += line.length
        assert_equal(pos, file.pos)
      end
    end
  end

  def test_pos=
    nums = [ 5, 8, 0, 1, 0 ]

    ZFile.open(@file) do |file|
      file.pos = 999
      assert_nil(file.gets)
      assert_kindof_exception(SystemCallError) { file.pos = -1 }
      for pos in nums
        assert_equal(LINE_LENGTH*pos, file.pos = LINE_LENGTH*pos)
        line = file.gets
        assert_equal(pos, line[0..1].to_i)
      end
    end
  end

  def test_print
    ZFile.open(@file, "w") do |file|
      file.print "hello"
      file.print 1,2
      $_ = "wombat\n"
      file.print
      $\ = ":"
      $, = ","
      file.print 3, 4
      file.print 5, 6
      $\ = nil
      file.print "\n"
      $, = nil
    end

    ZFile.open(@file) do |file|
      content = file.gets(nil)
      assert_equal("hello12wombat\n3,4:5,6:\n", content)
    end
  end

  def test_printf
    # tested under Kernel.sprintf
  end

  def test_putc
    ZFile.open(@file, "wb") do |file|
      file.putc "A"
      0.upto(255) { |ch| file.putc ch }
    end

    ZFile.open(@file, "rb") do |file|
      assert_equal(?A, file.getc)
      0.upto(255) { |ch| assert_equal(ch, file.getc) }
    end
  end

  def test_puts
    ZFile.open(@file, "w") do |file|
      file.puts "line 1", "line 2"
      file.puts [ Dummy.new, 4 ]
    end

    ZFile.open(@file) do |file|
      assert_equal("line 1\n",  file.gets)
      assert_equal("line 2\n",  file.gets)
      assert_equal("dummy\n",   file.gets)
      assert_equal("4\n",       file.gets)
    end
  end

  def test_read
    ZFile.open(@file) do |file|
      content = file.read
      assert_equal(SAMPLE.length*10, content.length)
      count = 0
      content.split(/\n/).each do |line|
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
    end

    ZFile.open(@file) do |file|
      assert_equal("00: This is ", file.read(12))
      assert_equal("a line\n01: T", file.read(12))
    end
  end

  def test_readchar
    count = 0
    data = 
      "00: This is a line\n" +
      "01: This is a line\n" +
      "02: This is a line\n" +
      "03: This is a line\n" +
      "04: This is a line\n" +
      "05: This is a line\n" +
      "06: This is a line\n" +
      "07: This is a line\n" +
      "08: This is a line\n" +
      "09: This is a line\n" 
    
    ZFile.open(@file) do |file|
      190.times do |count|
        ch = file.readchar
        assert_equal(data[count], ch)
        count += 1
      end
      assert_exception(EOFError) { file.readchar }
    end
  end

  def test_readline
    count = 0
    ZFile.open(@file) do |file|
      10.times do |count|
        line = file.readline
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
      assert_exception(EOFError) { file.readline }
    end

    count = 0
    ZFile.open(@file) do |file|
      contents = file.readline(nil)
      contents.split(/\n/).each do |line|
        num = line[0..1].to_i
        assert_equal(count, num)
        count += 1
      end
      assert_exception(EOFError) { file.readline }
    end
    assert_equal(10, count)

    count = 0
    ZFile.open(@file) do |file|
      41.times do |count|
        thing = file.readline(' ')
        count += 1
      end
      assert_exception(EOFError) { file.readline }
    end
  end

  def test_readlines
    ZFile.open(@file) do |file|
      lines = file.readlines
      assert_equal(10, lines.size)
    end

    ZFile.open(@file) do |file|
      lines = file.readlines(nil)
      assert_equal(1, lines.size)
      assert_equal(SAMPLE.length*10, lines[0].size)
    end
  end

  def test_reopen1
    f1 = ZFile.new(@file)
    assert_equal("00: This is a line\n", f1.gets)
    assert_equal("01: This is a line\n", f1.gets)

    f2 = ZFile.new(@file1)
    assert_equal("Line 00\n", f2.gets)
    assert_equal("Line 01\n", f2.gets)

    f2.reopen(@file)
    assert_equal("00: This is a line\n", f2.gets)
    assert_equal("01: This is a line\n", f2.gets)

    f1.close
    f2.close
  end

  def test_reopen2 
    f1 = ZFile.new(@file)
    assert_equal("00: This is a line\n", f1.read(SAMPLE.length))
    assert_equal("01: This is a line\n", f1.read(SAMPLE.length))

    f2 = ZFile.new(@file1)
    assert_equal("Line 00\n", f2.read(8))
    assert_equal("Line 01\n", f2.read(8))

    f2.reopen(f1)
    assert_equal("02: This is a line\n", f2.read(SAMPLE.length))
    assert_equal("03: This is a line\n", f2.read(SAMPLE.length))

    f1.close
    f2.close
  end

  def test_rewind
    f1 = ZFile.new(@file)
    assert_equal("00: This is a line\n", f1.gets)
    assert_equal("01: This is a line\n", f1.gets)
    f1.rewind
    assert_equal("00: This is a line\n", f1.gets)

    f1.readlines
    assert_nil(f1.gets)
    f1.rewind
    assert_equal("00: This is a line\n", f1.gets)

    f1.close
  end

  def test_seek
    nums = [ 5, 8, 0, 1, 0 ]

    ZFile.open(@file, "rb") do |file|
      file.seek(999, ZIO::SEEK_SET)
      assert_nil(file.gets)
      assert_kindof_exception(SystemCallError) { file.seek(-1) }
      for pos in nums
        assert_equal(0, file.seek(LINE_LENGTH*pos))
        line = file.gets
        assert_equal(pos, line[0..1].to_i)
      end
    end

    nums = [5, -2, 4, -7, 0 ]
    ZFile.open(@file) do |file|
      count = -1
      file.seek(0)
      for pos in nums
        assert_equal(0, file.seek(LINE_LENGTH*pos, ZIO::SEEK_CUR))
        line = file.gets
        count = count + pos + 1
        assert_equal(count, line[0..1].to_i)
      end
    end

    nums = [ 5, 8, 1, 10, 1 ]

    ZFile.open(@file) do |file|
      file.seek(0)
      for pos in nums
        assert_equal(0, file.seek(-LINE_LENGTH*pos, ZIO::SEEK_END))
        line = file.gets
        assert_equal(10-pos, line[0..1].to_i)
      end
    end
  end

  # Stat is pretty much tested elsewhere, so we're minimal here
  def test_stat
    io = ZIO.new($stdin.fileno)
    assert_instance_of(ZFile::Stat, io.stat)
    io.close
  end

  def test_sync
    $stderr.sync = false
    assert(!$stderr.sync)
    $stderr.sync = true
    assert($stderr.sync)
  end

  
  def test_sync=()
    MsWin32.dont do
      read, write = ZIO.pipe
      write.sync = false
      write.print "hello"
      assert_nil(select([read], nil,  [read], 0.1))
      write.sync = true
      write.print "there"
      assert_equal([[read],[],[]], select([read], nil,  [read], 0.1))
      read.close
      write.close
    end
  end

  def test_sysread
    ZFile.open(@file) do |file|
      assert_equal("", file.sysread(0))
      assert_equal("0", file.sysread(1))
      assert_equal("0:", file.sysread(2))
      assert_equal(" Thi", file.sysread(4))
      rest = file.sysread(100000)
      assert_equal(SAMPLE.length*10 - (1+2+4), rest.length)
      assert_exception(EOFError) { file.sysread(1) }
    end
  end

  def test_syswrite
    ZFile.open(@file, "w") do |file|
      file.syswrite ""
      file.syswrite "hello"
      file.syswrite 1
      file.syswrite "\n"
    end

    ZFile.open(@file) do |file|
      assert_equal("hello1\n", file.gets)
    end
  end

  # see also pos
  def test_tell
    pos = 0
    ZFile.open(@file, "rb") do |file|
      assert_equal(0, file.tell)
      while (line = file.gets)
        pos += line.length
        assert_equal(pos, file.tell)
      end
    end
  end

  def test_to_i
    assert_equal(0, $stdin.to_i)
    assert_equal(1, $stdout.to_i)
    assert_equal(2, $stderr.to_i)
  end

  # see isatty
  def test_tty?
    ZFile.open(@file) { |f|  assert(!f.tty?) }
    MsWin32.only do 
      ZFile.open("con") { |f| assert(f.tty?) }
    end
    MsWin32.dont do
      begin
        ZFile.open("/dev/tty") { |f| assert(f.isatty) }
      rescue
        # Can't open from crontab jobs
      end
    end
  end

  def test_ungetc
    ZFile.open(@file) do |file|
      assert_equal(?0, file.getc)
      assert_equal(?0, file.getc)
      assert_equal(?:, file.getc)
      assert_equal(?\s, file.getc)
      assert_nil(file.ungetc(?:))
      assert_equal(?:, file.getc)
      1 while file.getc
      assert_nil(file.ungetc(?A))
      assert_equal(?A, file.getc)
    end
  end

  def test_write
    ZFile.open(@file, "w") do |file|
      assert_equal(10, file.write('*' * 10))
      assert_equal(5,  file.write('!' * 5))
      assert_equal(0,  file.write(''))
      assert_equal(1,  file.write(1))
      assert_equal(3,  file.write(2.30000))
      assert_equal(1,  file.write("\n"))
    end
    
    ZFile.open(@file) do |file|
      assert_equal("**********!!!!!12.3\n", file.gets)
    end
  end
end

Rubicon::handleTests(TestZIO) if $0 == __FILE__
