#
# simple routine that uses the external 'checkstat' program
# to return stat values
#

module RubiconStat

  
  def stat(file)
    tmp = `#{CHECKSTAT} #{file}`.chomp
    raise "unable to stat(#{file}:)" if $? != 0
    tmp.split
  end

  def blksize(file) self.stat(file)[8].to_i end
  def atime(file)   self.stat(file)[10].to_i end
  def mtime(file)   self.stat(file)[11].to_i end
  def ctime(file)   self.stat(file)[12].to_i end

  module_function :stat, :atime, :mtime, :ctime, :blksize
end
