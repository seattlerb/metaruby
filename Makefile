
FILES = array.rb bignum.rb class.rb compar.rb dir.rb enum.rb error.rb eval.rb file.rb gc.rb hash.rb io.rb marshal.rb math.rb numeric.rb object.rb pack.rb prec.rb process.rb random.rb range.rb re.rb ruby.rb signal.rb string.rb struct.rb time.rb variable.rb version.rb


%.rb : %.rb.c preprocess.rb Makefile
	ruby -w preprocess.rb $< > $@

all: everything.rb
	ruby -w everything.rb

everything.rb: $(FILES) Makefile port.rb
	ruby -w tie-it-all-together.rb > everything.rb

clean:
	rm -f $(FILES) everything.rb *~
