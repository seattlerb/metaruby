$: << File.dirname($0) << File.join(File.dirname($0), "..")
require "HashBase"


class TestZHash < HashBase

  def initialize(*args)
    @cls = ZHash
    super
  end

end

Rubicon::handleTests(TestHash) if $0 == __FILE__
