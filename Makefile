
FILES = array.rb bignum.rb class.rb compar.rb dir.rb enum.rb error.rb eval.rb file.rb gc.rb hash.rb io.rb marshal.rb math.rb numeric.rb object.rb pack.rb prec.rb process.rb random.rb range.rb re.rb ruby.rb signal.rb string.rb struct.rb time.rb variable.rb version.rb


%.rb : %.rb.c preprocess.rb port.rb Makefile
	ruby -w preprocess.rb $< > $@

all: everything.rb
	ruby -w everything.rb
	ruby -w metaruby.rb

everything.rb: $(FILES) Makefile tie-it-all-together.rb
	ruby -w tie-it-all-together.rb > everything.rb

test: all
	cd tests/builtin; $(MAKE)

parser:
	ruby -wI ../../cocor/dev/build2 ../../cocor/dev/build2/Comp.rb ruby.ATG 

clean:
	rm -f $(FILES) everything.rb *~
