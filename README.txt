metaruby
    http://www.zenspider.com/
    support@zenspider.com

DESCRIPTION:
  
metaruby is a reimplementation of ruby in ruby. The intent is to make
it easier to understand, maintain, and extend ruby.

Eventually it will have a complete parser, interpreter, core library,
and a ruby-subset-to-c translator (maybe parrot instead... not
sure). We'll be modifying rubicon as our test suite.

MILESTONES:

1) Basic Porting

  1) [DONE] everything.rb generats and runs without warnings.
  1.1) [DONE] preprocess.rb and port.rb have the absolute minimum of HACK tags.

2) Parser/Interpreter/Translator

  1) parser does a sucessful first pass at everything.rb
  2) parser actually generates ASTs
  3) interpreter can run ASTs
  4) Library milestones can pass under interpreter
  5) parser can generate C and/or parrot code.
  6) Library milestones can pass under generated & compiled interproter.

3) Library

  1) ZArray passes all of it's rubicon tests using ruby interpreter
  2) ZHash, ZFile, ZIO, ZDictionary pass all their tests

FEATURES/PROBLEMS:
  
+ Soooo far from done...

SYNOPSYS:

  n/a

REQUIREMENTS:

+ A ruby interpreter - this thing doesn't bootstrap itself yet.

INSTALL:

+ none, yet.

LICENSE:

(The MIT License)

Copyright (c) 2001-2002 Ryan Davis, Zen Spider Software

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
