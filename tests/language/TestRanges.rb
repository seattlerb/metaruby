$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestRanges < Rubicon::TestCase

end

# Run these tests if invoked directly

Rubicon::handleTests(TestRanges) if $0 == __FILE__
