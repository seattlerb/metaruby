$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestModules < Rubicon::TestCase

end

# Run these tests if invoked directly

Rubicon::handleTests(TestModules) if $0 == __FILE__
