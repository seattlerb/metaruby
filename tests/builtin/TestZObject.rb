$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZObject < Rubicon::TestCase

end

Rubicon::handleTests(TestZObject) if $0 == __FILE__
