$: << File.dirname($0) << File.join(File.dirname($0), "..")

require 'rubicon'
require 'StringBase'


class TestZString < StringBase

  def initialize(*args)
    @cls = ZString
    super
  end

end

Rubicon::handleTests(TestZString) if $0 == __FILE__
