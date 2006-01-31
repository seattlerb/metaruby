require 'libcwrap'

module FileTest

  ##
  # call-seq:
  #   File.blockdev?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a block device.

  def self.blockdev?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 0170000 == 060000
  end

  ##
  # call-seq:
  #   File.chardev?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a character device.

  def self.chardev?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 0170000 == 020000
  end

  ##
  # call-seq:
  #   File.directory?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a directory, <tt>false</tt>
  # otherwise.
  #
  #    File.directory?(".")

  def self.directory?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 0170000 == 040000
  end

  ##
  # call-seq:
  #   File.executable?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file is executable by the effective
  # user id of this process.

  def self.executable?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return true if stat[2] &   01 ==   01
    return true if stat[2] &  010 ==  010 && stat[5] == Process.egid
    return true if stat[2] & 0100 == 0100 && stat[4] == Process.euid
    return false
  end

  ##
  # call-seq:
  #   File.executable_real?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file is executable by the real user
  # id of this process.

  def self.executable_real?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return true if stat[2] &   01 ==   01
    return true if stat[2] &  010 ==  010 && stat[5] == Process.gid
    return true if stat[2] & 0100 == 0100 && stat[4] == Process.uid
    return false
  end

  ##
  # call-seq:
  #   File.exist?(file_name)    =>  true or false
  #   File.exists?(file_name)   =>  true or false    (obsolete)
  #
  # Return <tt>true</tt> if the named file exists.

  def self.exist?(file_name)
    return exists? file_name
  end

  ##
  # call-seq:
  #   File.exist?(file_name)    =>  true or false
  #   File.exists?(file_name)   =>  true or false    (obsolete)
  #
  # Return <tt>true</tt> if the named file exists.

  def self.exists?(file_name)
    err, = LIBC.new.c_stat(file_name)
    return err == 0
  end

  ##
  # call-seq:
  #   File.file?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file exists and is a regular file.

  def self.file?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 0170000 == 0100000
  end

  ##
  # call-seq:
  #   File.grpowned?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file exists and the effective group
  # id of the calling process is the owner of the file. Returns
  # <tt>false</tt> on Windows.

  def self.grpowned?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[5] == Process.egid
  end

  ##
  # call-seq:
  #   File.owned?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file exists and the effective used id
  # of the calling process is the owner of the file.

  def self.owned?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[4] == Process.egid
  end

  ##
  # call-seq:
  #   File.pipe?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a pipe.

  def self.pipe?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 0170000 == 010000
  end

  ##
  # call-seq:
  #   File.readable?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file is readable by the effective
  # user id of this process.

  def self.readable?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return true if stat[2] &   04 ==   04
    return true if stat[2] &  040 ==  040 && stat[5] == Process.egid
    return true if stat[2] & 0400 == 0400 && stat[4] == Process.euid
    return false
  end

  ##
  # call-seq:
  #   File.readable_real?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file is readable by the real user id
  # of this process.

  def self.readable_real?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return true if stat[2] &   04 ==   04
    return true if stat[2] &  040 ==  040 && stat[5] == Process.gid
    return true if stat[2] & 0400 == 0400 && stat[4] == Process.uid
    return false
  end

  ##
  # call-seq:
  #   File.setgid?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a has the setgid bit set.

  def self.setgid?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 02000 == 02000
  end

  ##
  # call-seq:
  #   File.setuid?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a has the setuid bit set.

  def self.setuid?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 04000 == 04000
  end

  ##
  # call-seq:
  #   File.size(file_name)   => integer
  #
  # Returns the size of <tt>file_name</tt>.

  def self.size(file_name)
    raise Errno::ENOENT unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[10]
  end

  ##
  # call-seq:
  #   File.size?(file_name)   => integer  or  nil
  #
  # Returns <tt>nil</tt> if <tt>file_name</tt> doesn't exist or has zero
  # size, the size of the file otherwise.

  def self.size?(file_name)
    return nil unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return nil if stat[10] == 0
    return stat[10]
  end

  ##
  # call-seq:
  #   File.socket?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a socket.

  def self.socket?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 0170000 == 0140000
  end

  ##
  # call-seq:
  #   File.sticky?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a has the sticky bit set.

  def self.sticky?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 01000 == 01000
  end

  ##
  # call-seq:
  #   File.symlink?(file_name)   =>  true or false
  #
  # Returns <tt>true</tt> if the named file is a symbolic link.

  def self.symlink?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[2] & 0170000 == 0120000
  end

  ##
  # call-seq:
  #   File.writable?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file is writable by the effective
  # user id of this process.

  def self.writable?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return true if stat[2] &   02 ==   02
    return true if stat[2] &  020 ==  020 && stat[5] == Process.egid
    return true if stat[2] & 0200 == 0200 && stat[4] == Process.euid
    return false
  end

  ##
  # call-seq:
  #   File.writable_real?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file is writable by the real user id
  # of this process.

  def self.writable_real?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return true if stat[2] &   02 ==   02
    return true if stat[2] &  020 ==  020 && stat[5] == Process.gid
    return true if stat[2] & 0200 == 0200 && stat[4] == Process.uid
    return false
  end

  ##
  # call-seq:
  #   File.zero?(file_name)   => true or false
  #
  # Returns <tt>true</tt> if the named file exists and has a zero size.

  def self.zero?(file_name)
    return false unless exists? file_name
    err, stat = LIBC.new.c_stat(file_name)
    return stat[10] == 0
  end

end

