RUBYBIN?=ruby
RUBY_DEBUG?=
FILTER?=
RUBY2C?=$(shell cd ../../ruby_to_c/dev; pwd)
PARSETREE?=$(shell cd ../../ParseTree/dev/lib; pwd)
RUBYINLINE?=$(shell cd ../../RubyInline/dev; pwd)
BFTS?=$(shell cd ../../bfts/dev; pwd)
RUBY_FLAGS?=-w -Ilib:bin:$(RUBY2C):$(RUBYINLINE):$(PARSETREE):$(BFTS)
RUBY?=$(RUBYBIN) $(RUBY_DEBUG) $(RUBY_FLAGS) 
CFLAGS ?= -I$(shell $(RUBYBIN) -rrbconfig -e 'puts Config::CONFIG["archdir"]')

CLASSES = \
	true_class \
	false_class \
	nil_class \
	time \
	array \
	range \
	hash \
	string \
	comparable \
	exception \
	file_test \
	struct \
	$(NULL)

TESTFILES = $(patsubst %,%.pass,$(CLASSES))
AUDITFILES = $(patsubst %,%.audit.rb,$(CLASSES))
CFILES = $(patsubst %,%.c,$(CLASSES))
OFILES = $(patsubst %,%.o,$(CLASSES))

SHLIB_EXT = $(shell ruby -rrbconfig -e 'puts Config::CONFIG["DLEXT"]')
LINKER = $(shell ruby -rrbconfig -e 'puts Config::CONFIG["LDSHARED"]')

%.pass: %.rb Makefile
	(cd $(BFTS); $(RUBY) -I../../metaruby/dev -r$* test_$<) && touch $@

%.audit.rb: %.rb bfts/Test%.rb Makefile
	$(RUBY) ../../ZenTest/dev/ZenTest.rb $*.rb bfts/Test$*.rb

%.c: %.rb %.pass Makefile
	$(RUBY) $(RUBY2C)/translate.rb -c=$* ./$< > $@

all: bfts $(TESTFILES)

allc: all $(CFILES)

metaruby: metaruby.$(SHLIB_EXT)
metaruby.$(SHLIB_EXT): $(OFILES)
	$(LINKER) $^ -o $@

libmetaruby.a: $(OFILES)
	rm $@; ar r $@ $^ && ranlib $@

test: realclean
	$(MAKE) all

FORCE:
doc: FORCE
	rm -rf doc ; rdoc -x bfts .

audit: $(AUDITFILES)

# so you can type `make Time` to just run Time tests
$(CLASSES):
	(cd $(BFTS); $(RUBY) -I../../../metaruby/dev:.. -r$@ Test$@.rb $(FILTER))

# shortcut to login, we can't find any way to default the input. argh.
cvslogin:
	cvs -d:pserver:anonymous@rubyforge.org:/var/cvs/rubytests login

sort:
	for f in *.rb; do egrep "^ *def [a-z]" $$f > x; sort x > y; echo $$f; echo; diff x y; done

clean:
	rm -rf *~ *.c *.o *.$(SHLIB_EXT) ~/.ruby_inline *.a *.pass *.cache

realclean: clean
	rm -rf bfts
