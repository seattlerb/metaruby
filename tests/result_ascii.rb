# Accumulate a running set of results, and report them at the end
  
class ResultDisplay

  LINE_LENGTH = 72
  LINE = '=' * LINE_LENGTH
  Line = ' ' * 12 + '-' * (LINE_LENGTH - 12)
    

  def initialize(gatherer)
    @results = gatherer.results
    @name    = gatherer.name
  end

  def reportOn(op)
    op.puts
    op.puts LINE
    title = "Test Results".center(LINE_LENGTH)
    title[0, @name.length] = @name
    title[-RUBICON_VERSION.length, RUBICON_VERSION.length] = RUBICON_VERSION
    op.puts title
    op.puts LINE
    op.puts "                 Name   OK?   Tests  Asserts      Failures   Errors"
    op.puts Line
    
    total_classes = 0
    total_tests   = 0
    total_asserts = 0
    total_fails   = 0
    total_errors  = 0
    total_bad     = 0
    
    format = "%21s   %4s   %4d  %7d  %9s  %7s\n"
    
    names = @results.keys.sort
    for name in names
      res    = @results[name]
      fails  = res.failure_size.nonzero? || ''
      errors = res.error_size.nonzero? || ''
      
      total_classes += 1
      total_tests   += res.run_tests
      total_asserts += res.run_asserts
      total_fails   += res.failure_size
      total_errors  += res.error_size
      total_bad     += 1 unless res.succeed?
      
      op.printf format,
        name.sub(/^Test/, ''),
        res.succeed? ? "    " : "FAIL",
        res.run_tests, res.run_asserts, 
        fails.to_s, errors
    end
    
    op.puts LINE
    if total_classes > 1
      op.printf format, 
        sprintf("All %d files", total_classes),
        total_bad > 0 ? "FAIL" : "    ",
        total_tests, total_asserts,
        total_fails, total_errors
      op.puts LINE
    end
    
    if total_fails > 0
      op.puts
      op.puts "Failure Report".center(LINE_LENGTH)
      op.puts LINE
      left = total_fails
      
      for name in names
        res = @results[name]
        if res.failure_size > 0
          op.puts
          op.puts name + ":"
          op.puts "-" * name.length.succ
          
          res.failures.each do |f|
            f.at.each do |at|
              break if at =~ /rubicon/
              op.print "    ", at, "\n"
            end
            err = f.err.to_s
            
            if err =~ /expected:(.*)but was:(.*)/m
              exp = $1.dump
              was = $2.dump
              op.print "    ....Expected: #{exp}\n"
              op.print "    ....But was:  #{was}\n"
            else
              op.print "    ....#{err}\n"
            end
          end
          
          left -= res.failure_size
          op.puts
          op.puts Line if left > 0
        end
      end
      op.puts LINE
    end
    
    if total_errors > 0
      op.puts
      op.puts "Error Report".center(LINE_LENGTH)
      op.puts LINE
      left = total_errors
      
      for name in names
        res = @results[name]
        if res.error_size > 0
          op.puts
          op.puts name + ":"
          op.puts "-" * name.length.succ
          
          res.errors.each do |f|
            f.at.each do |at|
              break if at =~ /rubicon/
              op.print "    ", at, "\n"
            end
            err = f.err.to_s
            op.print "    ....#{err}\n"
          end
          
          left -= res.error_size
          op.puts
          op.puts Line if left > 0
        end
      end
      op.puts LINE
    end
    
  end
end


