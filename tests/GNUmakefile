# 
# Rubicon is a set of Ruby confidence tests.
#
#  make test   - run the tests
#  make clean  - tidy up
#
# Dave Thomas/Andy Hunt
# The Pragmatic Progrmmers llc
# www.pragmaticprogrammer.com
# $Id: GNUmakefile,v 1.1 2001/11/26 04:09:52 dave Exp $
# Archive save
#

VPATH = util

UTILSTUFF =	util/checkstat util/test_touch

RUBY	  ?=	ruby

.phony:		default test Builtin Language

default:	test


test:		$(UTILSTUFF)
		$(RUBY) AllTests.rb

Builtin:	$(UTILSTUFF)
		cd builtin && $(RUBY) AllBuiltinTests.rb

Language:
		cd language && $(RUBY) AllLanguageTests.rb

# Release must have VERSION variable set
#
#    make VERSION=0.1 release
#

release:	clean stamp tar

stamp:
		ruby -i -pe 'sub!(/V\d+(\.\d+)+/, "V$(VERSION)") if /_VERSION =/' rubicon.rb
		cvs commit
		cvs rtag `echo V$(VERSION) | sed s/\\\\./_/g` rubicon

tar:
		ln -fs rubicon ../rubicon-$(VERSION)
		tar 	--directory=..			\
			--create			\
			--dereference			\
			--file=rubicon-$(VERSION).tgz 	\
			--compress 			\
			--exclude='CVS' 		\
			--exclude='*/.*'		\
			--exclude=rubicon-$(VERSION).tgz	\
			rubicon-$(VERSION)
		rm ../rubicon-$(VERSION)

clean:
		rm -f $(UTILSTUFF)
		rm -f rubicon*.tgz
		find . -name \*~ -print | xargs rm -f
		find . -name core -print | xargs rm -f
