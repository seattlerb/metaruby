
CLASSES = \
	TrueClass \
	FalseClass \
	NilClass \
	Time \
	Array \
	$(NULL)

FILES = $(patsubst %,%.c,$(CLASSES))

RUBY2C=../../ruby_to_c/dev

%.c: %.rb Makefile
	(cd rubicon/builtin; ruby -w -I../.. -r$* Test$<)
	ruby -w -I$(RUBY2C) $(RUBY2C)/translate.rb -c=$* $< > $@

all: rubicon tools $(FILES)

test: realclean
	$(MAKE) -k all

audit: rubicon
	ruby -I rubicon /usr/local/bin/ZenTest TrueClass.rb rubicon/builtin/TestTrueClass.rb
	ruby -I rubicon /usr/local/bin/ZenTest FalseClass.rb rubicon/builtin/TestFalseClass.rb
	ruby -I rubicon /usr/local/bin/ZenTest NilClass.rb rubicon/builtin/TestNilClass.rb
	ruby -I rubicon /usr/local/bin/ZenTest Time.rb rubicon/builtin/TestTime.rb
	ruby -I rubicon /usr/local/bin/ZenTest Array.rb rubicon/builtin/TestArray.rb

# so you can type `make Time` to just run Time tests
$(CLASSES):
	(cd rubicon/builtin; ruby -w -I../.. -r$@ Test$@.rb)

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
	(cd rubicon; cvs -q diff -du > ../rubicon.patch.new)

clean:
	rm -rf *~ *.c ~/.ruby_inline

realclean: clean
	rm -rf rubicon
