$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestNames < Rubicon::TestCase

end

# Run these tests if invoked directly

Rubicon::handleTests(TestNames) if $0 == __FILE__
