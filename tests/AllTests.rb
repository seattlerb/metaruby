# Run all the tests in one big suite

# These are the directories containing the tests
SUB_DIRS = %w{ builtin language }

# Set up the include path so we can run this from anywhere
base = File.dirname($0)
$: << base
for dir in SUB_DIRS
  $: << File.join(base, dir)
end

# Load up the test driver
require 'rubicon'

# Create a test runner
tests = Rubicon::BulkTestRunner.new(ARGV, "All Tests")

# and tell it what files to test
if ARGV.size.zero?
  for dir in SUB_DIRS
    Dir[File.join(base, dir, "Test*.rb")].each { |file| tests.addFile(file) }
  end
else
  ARGV.each { |file| tests.addFile(file) }
end

failure_count = tests.run

exit(failure_count)
