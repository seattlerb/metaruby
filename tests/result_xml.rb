# Accumulate a running set of results, and report them at the end

#
# This is a temporary hack - we have made changes to xmarshal
# to allow rubicon to run without having to have xmlparser 
# installed
#

XMARSHAL_DUMP_ONLY = true
require "rubicon_xmarshal"
  
class ResultDisplay

  def initialize(gatherer)
    @gatherer = gatherer
  end

  def reportOn(op)
    # map errors to the corresponding string - for some reason
    # dump doesn't handle them

    @gatherer.results.each_value do |res|
      res.failures.each {|f| f.err = f.err.class.name + ": " + f.err.to_s }
      res.errors.each   {|f| f.err = f.err.class.name + ": " + f.err.to_s }
    end

    XMarshal.dump(@gatherer, op)
  end
end


