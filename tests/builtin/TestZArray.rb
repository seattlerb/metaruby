$: << File.dirname($0) << File.join(File.dirname($0), "..")

require 'rubicon'
require 'ArrayBase.rb'


class TestZArray < ArrayBase
  def initialize(*args)
    @cls = ZArray
    super
  end
end



Rubicon::handleTests(TestZArray) if $0 == __FILE__
