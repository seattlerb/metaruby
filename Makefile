RUBYBIN?=ruby
RUBY_DEBUG?=
FILTER?=
PWD=$(shell pwd)
RUBY2C?=$(PWD)/../../ruby_to_c/dev
PARSETREE?=$(PWD)/../../ParseTree/dev/lib
RUBYINLINE?=$(PWD)/../../RubyInline/dev
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
	$(NULL)

TESTFILES = $(patsubst %,%.pass,$(CLASSES))
AUDITFILES = $(patsubst %,%.audit.rb,$(CLASSES))
FILES = $(patsubst %,%.c,$(CLASSES))

%.pass: %.rb Makefile
	(cd rubicon/builtin; $(RUBY) -I../.. -r$* Test$<) && touch $@

%.audit.rb: %.rb rubicon/builtin/Test%.rb Makefile
	$(RUBY) ../../ZenTest/dev/ZenTest.rb $*.rb rubicon/builtin/Test$*.rb

%.c: %.rb %.pass Makefile
	$(RUBY) $(RUBY2C)/translate.rb -c=$* $< > $@

all: rubicon tools $(TESTFILES)

test: realclean
	$(MAKE) -k all

FORCE:
doc: FORCE
	rm -rf doc ; rdoc -x rubicon .

audit: $(AUDITFILES)

# so you can type `make Time` to just run Time tests
$(CLASSES):
	(cd rubicon/builtin; $(RUBY) -I../.. -r$@ Test$@.rb $(FILTER))

# shortcut to login, we can't find any way to default the input. argh.
cvslogin:
	cvs -d:pserver:anonymous@rubyforge.org:/var/cvs/rubytests login

# checks out rubicon fresh and patches
rubicon:
	cvs -z3 -d:pserver:anonymous@rubyforge.org:/var/cvs/rubytests co rubicon
	(cd rubicon; patch -p0 < ../rubicon.patch)

patch:
	(cd rubicon; patch -p0 < ../rubicon.patch)

tools: rubicon
	(cd rubicon; $(MAKE) tools)

diffs:
	(cd rubicon; cvs -q diff -N -du > ../rubicon.patch.new)

clean:
	rm -rf *~ *.c ~/.ruby_inline *.pass

realclean: clean
	rm -rf rubicon
