# 
# The MSVC makefile for rubicon. The Unix and Cygwin makefile
# is over in GNUmakefile.
#
#
#  nmake test   - run the tests
#  nmake clean  - tidy up
#
# On a box with multiple Rubys installed, use
#
#  nmake RUBY=C:\<path to ruby>  test
#

VPATH	  = 	util

UTILSTUFF =	util\checkstat.exe util\test_touch.exe

RUBY	  =	ruby

.phony:		default test Builtin Language

default:	test


test:		$(UTILSTUFF)
		$(RUBY) -v
		$(RUBY) AllTests.rb

Builtin:	$(UTILSTUFF)
		cd builtin && $(RUBY) AllBuiltinTests.rb

Language:
		cd language && $(RUBY) AllLanguageTests.rb


clean:
		@-del $(UTILSTUFF) 2>nul

util\checkstat.exe:	util\checkstat.c
		cd util
		cl checkstat.c
		cd ..

util\test_touch.exe:	util\test_touch.c
		cd util
		cl test_touch.c
		cd ..