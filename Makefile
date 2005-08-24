RUBYBIN?=ruby
RUBY_DEBUG?=
FILTER?=
PWD=$(shell pwd)
RUBY2C?=$(PWD)/../../ruby_to_c/dev
PARSETREE?=$(PWD)/../../ParseTree/dev/lib
RUBYINLINE?=$(PWD)/../../RubyInline/dev
RUBICON?=$(PWD)/../../rubicon/dev
RUBY_FLAGS?=-w -Ilib:bin:$(RUBY2C):$(RUBYINLINE):$(PARSETREE):rubicon
RUBY=GEM_SKIP=ParseTree:RubyInline $(RUBYBIN) $(RUBY_DEBUG) $(RUBY_FLAGS) 

CLASSES = \
	TrueClass \
	FalseClass \
	NilClass \
	Time \
	Array \
	Range \
	Hash \
	String \
	$(NULL)

TESTFILES = $(patsubst %,%.pass,$(CLASSES))
AUDITFILES = $(patsubst %,%.audit.rb,$(CLASSES))
CFILES = $(patsubst %,%.c,$(CLASSES))

%.pass: %.rb Makefile
	(cd $(RUBICON)/builtin; $(RUBY) -I../../../metaruby/dev -r$* Test$<) && touch $@

%.audit.rb: %.rb rubicon/builtin/Test%.rb Makefile
	$(RUBY) ../../ZenTest/dev/ZenTest.rb $*.rb rubicon/builtin/Test$*.rb

%.c: %.rb %.pass Makefile
	$(RUBY) $(RUBY2C)/translate.rb -c=$* $< > $@

all: rubicon tools $(TESTFILES)

allc: all $(CFILES)

test: realclean
	$(MAKE) all

FORCE:
doc: FORCE
	rm -rf doc ; rdoc -x rubicon .

audit: $(AUDITFILES)

# so you can type `make Time` to just run Time tests
$(CLASSES):
	(cd $(RUBICON)/builtin; $(RUBY) -I../../../metaruby/dev:.. -r$@ Test$@.rb $(FILTER))

# shortcut to login, we can't find any way to default the input. argh.
cvslogin:
	cvs -d:pserver:anonymous@rubyforge.org:/var/cvs/rubytests login

# checks out rubicon fresh and patches
rubicon:
	ln -s ../../rubicon/dev rubicon

tools: rubicon
	(cd rubicon; $(MAKE) tools)

clean:
	rm -rf *~ *.c ~/.ruby_inline *.pass

realclean: clean
	rm -rf rubicon
