$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestZBinding < Rubicon::TestCase


end

Rubicon::handleTests(TestBinding) if $0 == __FILE__
