$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

tests = Rubicon::BulkTestRunner.new(ARGV, "Language")

if ARGV.size.zero?
  Dir["Test*.rb"].each { |file| tests.addFile(file) }
else
  ARGV.each { |file| tests.addFile(file) }
end

tests.run
