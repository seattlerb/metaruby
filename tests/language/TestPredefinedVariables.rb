$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestPredefinedVariables < Rubicon::TestCase

  # this is the test from test.rb, but we really need to be
  # more compregensive here
  def testVariables
    assert_instance_of(Fixnum, $$)
    assert_exception(NameError) { $$ = 1 }

    foobar = "foobar"
    $_ = foobar
    assert_equal(foobar, $_)
  end

end

# Run these tests if invoked directly

Rubicon::handleTests(TestPredefinedVariables) if $0 == __FILE__
