class String

  ##
  # call-seq:
  #   String.new(str="")   => new_str
  #
  # Returns a new string object containing a copy of <em>str</em>.

  #def initialize(str=""); end # CORE

  ##
  # call-seq:
  #   str % arg   => new_str
  #
  # Format---Uses <em>str</em> as a format specification, and returns the
  # result of applying it to <em>arg</em>. If the format specification
  # contains more than one substitution, then <em>arg</em> must be an
  # <tt>Array</tt> containing the values to be substituted. See
  # <tt>Kernel::sprintf</tt> for details of the format string.
  #
  #    "%05d" % 123                       #=> "00123"
  #    "%-5s: %08x" % [ "ID", self.id ]   #=> "ID   : 200e14d6"

  #def %(arg1); end # HACK

  ##
  # call-seq:
  #   str * integer   => new_str
  #
  # Copy---Returns a new <tt>String</tt> containing <em>integer</em> copies
  # of the receiver.
  #
  #    "Ho! " * 3   #=> "Ho! Ho! Ho! "

  def *(times)
    raise ArgumentError, "negative argument" if times < 0
    new = ''
    times.times { new << self }
    return new
  end

  ##
  # call-seq:
  #   str + other_str   => new_str
  #
  # Concatenation---Returns a new <tt>String</tt> containing
  # <em>other_str</em> concatenated to <em>str</em>.
  #
  #    "Hello from " + self.to_s   #=> "Hello from main"

  def +(str)
    new = dup
    new << str
    return new
  end

  ##
  # call-seq:
  #   str << fixnum        => str
  #   str.concat(fixnum)   => str
  #   str << obj           => str
  #   str.concat(obj)      => str
  #
  # Append---Concatenates the given object to <em>str</em>. If the object is
  # a <tt>Fixnum</tt> between 0 and 255, it is converted to a character
  # before concatenation.
  #
  #    a = "hello "
  #    a << "world"   #=> "hello world"
  #    a.concat(33)   #=> "hello world!"

  #def <<(arg1); end # CORE

  ##
  # call-seq:
  #   str <=> other_str   => -1, 0, +1
  #
  # Comparison---Returns -1 if <em>other_str</em> is less than, 0 if
  # <em>other_str</em> is equal to, and +1 if <em>other_str</em> is greater
  # than <em>str</em>. If the strings are of different lengths, and the
  # strings are equal when compared up to the shortest length, then the
  # longer string is considered greater than the shorter one. If the
  # variable <tt>$=</tt> is <tt>false</tt>, the comparison is based on
  # comparing the binary values of each character in the string. In older
  # versions of Ruby, setting <tt>$=</tt> allowed case-insensitive
  # comparisons; this is now deprecated in favor of using
  # <tt>String#casecmp</tt>.
  #
  # <tt><=></tt> is the basis for the methods <tt><</tt>, <tt><=</tt>,
  # <tt>></tt>, <tt>>=</tt>, and <tt>between?</tt>, included from module
  # <tt>Comparable</tt>. The method <tt>String#==</tt> does not use
  # <tt>Comparable#==</tt>.
  #
  #    "abcdef" <=> "abcde"     #=> 1
  #    "abcdef" <=> "abcdef"    #=> 0
  #    "abcdef" <=> "abcdefg"   #=> -1
  #    "abcdef" <=> "ABCDEF"    #=> 1

  #def <=>(arg1); end # HACK

  ##
  # call-seq:
  #   str == obj   => true or false
  #
  # Equality---If <em>obj</em> is not a <tt>String</tt>, returns
  # <tt>false</tt>. Otherwise, returns <tt>true</tt> if <em>str</em>
  # <tt><=></tt> <em>obj</em> returns zero.

  def ==(other)
    return true if other.object_id == self.object_id
    unless other.kind_of? String then
      return false unless other.respond_to? :to_str
      return other == self
    end
    return self.length == other.length && (self <=> other) == 0
  end

  ##
  # call-seq:
  #   str =~ obj   => fixnum or nil
  #
  # Match---If <em>obj</em> is a <tt>Regexp</tt>, use it as a pattern to
  # match against <em>str</em>. If <em>obj</em> is a <tt>String</tt>, look
  # for it in <em>str</em> (similar to <tt>String#index</tt>). Returns the
  # position the match starts, or <tt>nil</tt> if there is no match.
  # Otherwise, invokes <em>obj.=~</em>, passing <em>str</em> as an argument.
  # The default <tt>=~</tt> in <tt>Object</tt> returns <tt>false</tt>.
  #
  #    "cat o' 9 tails" =~ '\d'   #=> nil
  #    "cat o' 9 tails" =~ /\d/   #=> 7
  #    "cat o' 9 tails" =~ 9      #=> false

  #def =~(arg1); end # HACK

  ##
  # call-seq:
  #   str[fixnum]                 => fixnum or nil
  #   str[fixnum, fixnum]         => new_str or nil
  #   str[range]                  => new_str or nil
  #   str[regexp]                 => new_str or nil
  #   str[regexp, fixnum]         => new_str or nil
  #   str[other_str]              => new_str or nil
  #   str.slice(fixnum)           => fixnum or nil
  #   str.slice(fixnum, fixnum)   => new_str or nil
  #   str.slice(range)            => new_str or nil
  #   str.slice(regexp)           => new_str or nil
  #   str.slice(regexp, fixnum)   => new_str or nil
  #   str.slice(other_str)        => new_str or nil
  #
  # Element Reference---If passed a single <tt>Fixnum</tt>, returns the code
  # of the character at that position. If passed two <tt>Fixnum</tt>
  # objects, returns a substring starting at the offset given by the first,
  # and a length given by the second. If given a range, a substring
  # containing characters at offsets given by the range is returned. In all
  # three cases, if an offset is negative, it is counted from the end of
  # <em>str</em>. Returns <tt>nil</tt> if the initial offset falls outside
  # the string, the length is negative, or the beginning of the range is
  # greater than the end.
  #
  # If a <tt>Regexp</tt> is supplied, the matching portion of <em>str</em>
  # is returned. If a numeric parameter follows the regular expression, that
  # component of the <tt>MatchData</tt> is returned instead. If a
  # <tt>String</tt> is given, that string is returned if it occurs in
  # <em>str</em>. In both cases, <tt>nil</tt> is returned if there is no
  # match.
  #
  #    a = "hello there"
  #    a[1]                   #=> 101
  #    a[1,3]                 #=> "ell"
  #    a[1..3]                #=> "ell"
  #    a[-3,2]                #=> "er"
  #    a[-4..-2]              #=> "her"
  #    a[12..-1]              #=> nil
  #    a[-2..-4]              #=> ""
  #    a[/[aeiou](.)\1/]      #=> "ell"
  #    a[/[aeiou](.)\1/, 0]   #=> "ell"
  #    a[/[aeiou](.)\1/, 1]   #=> "l"
  #    a[/[aeiou](.)\1/, 2]   #=> nil
  #    a["lo"]                #=> "lo"
  #    a["bye"]               #=> nil

  #def [](*args); end # CORE

  ##
  # call-seq:
  #   str[fixnum] = fixnum
  #   str[fixnum] = new_str
  #   str[fixnum, fixnum] = new_str
  #   str[range] = aString
  #   str[regexp] = new_str
  #   str[regexp, fixnum] = new_str
  #   str[other_str] = new_str
  #
  # Element Assignment---Replaces some or all of the content of
  # <em>str</em>. The portion of the string affected is determined using the
  # same criteria as <tt>String#[]</tt>. If the replacement string is not
  # the same length as the text it is replacing, the string will be adjusted
  # accordingly. If the regular expression or string is used as the index
  # doesn't match a position in the string, <tt>IndexError</tt> is raised.
  # If the regular expression form is used, the optional second
  # <tt>Fixnum</tt> allows you to specify which portion of the match to
  # replace (effectively using the <tt>MatchData</tt> indexing rules. The
  # forms that take a <tt>Fixnum</tt> will raise an <tt>IndexError</tt> if
  # the value is out of range; the <tt>Range</tt> form will raise a
  # <tt>RangeError</tt>, and the <tt>Regexp</tt> and <tt>String</tt> forms
  # will silently ignore the assignment.

  #def []=(*args); end # CORE

  ##
  # call-seq:
  #   str.capitalize   => new_str
  #
  # Returns a copy of <em>str</em> with the first character converted to
  # uppercase and the remainder to lowercase.
  #
  #    "hello".capitalize    #=> "Hello"
  #    "HELLO".capitalize    #=> "Hello"
  #    "123ABC".capitalize   #=> "123abc"

  def capitalize
    str = self.dup
    str.capitalize!
    return str
  end

  ##
  # call-seq:
  #   str.capitalize!   => str or nil
  #
  # Modifies <em>str</em> by converting the first character to uppercase and
  # the remainder to lowercase. Returns <tt>nil</tt> if no changes are made.
  #
  #    a = "hello"
  #    a.capitalize!   #=> "Hello"
  #    a               #=> "Hello"
  #    a.capitalize!   #=> nil

  def capitalize!
    modify = nil
    first = self[0].chr
    if islower first then
      self[0] = toupper first
      modify = self
    end

    1.upto(self.length - 1) do |i|
      cur = self[i].chr
      if isupper cur then
        self[i] = tolower cur
        modify = self
      end
    end

    return modify
  end

  ##
  # call-seq:
  #   str.casecmp(other)   => -1, 0, +1
  #
  # Case-insensitive version of <tt>String#<=></tt>.
  #
  #    "abcdef".casecmp("abcde")     #=> 1
  #    "aBcDeF".casecmp("abcdef")    #=> 0
  #    "abcdef".casecmp("abcdefg")   #=> -1
  #    "abcdef".casecmp("ABCDEF")    #=> 0

  def casecmp(other)
    other = convert other
    self.downcase <=> other.downcase
  end

  ##
  # call-seq:
  #   str.center(integer, padstr)   => new_str
  #
  # If <em>integer</em> is greater than the length of <em>str</em>, returns
  # a new <tt>String</tt> of length <em>integer</em> with <em>str</em>
  # centered and padded with <em>padstr</em>; otherwise, returns
  # <em>str</em>.
  #
  #    "hello".center(4)         #=> "hello"
  #    "hello".center(20)        #=> "       hello        "
  #    "hello".center(20, '123') #=> "1231231hello12312312"

#  def center(*args)
#  end

  ##
  # call-seq:
  #   str.chomp(separator=$/)   => new_str
  #
  # Returns a new <tt>String</tt> with the given record separator removed
  # from the end of <em>str</em> (if present). If <tt>$/</tt> has not been
  # changed from the default Ruby record separator, then <tt>chomp</tt> also
  # removes carriage return characters (that is it will remove <tt>\n</tt>,
  # <tt>\r</tt>, and <tt>\r\n</tt>).
  #
  #    "hello".chomp            #=> "hello"
  #    "hello\n".chomp          #=> "hello"
  #    "hello\r\n".chomp        #=> "hello"
  #    "hello\n\r".chomp        #=> "hello\n"
  #    "hello\r".chomp          #=> "hello"
  #    "hello \n there".chomp   #=> "hello \n there"
  #    "hello".chomp("llo")     #=> "he"

  def chomp(separator = $/)
    str = self.dup
    str.chomp! separator
    return str
  end

  ##
  # call-seq:
  #   str.chomp!(separator=$/)   => str or nil
  #
  # Modifies <em>str</em> in place as described for <tt>String#chomp</tt>,
  # returning <em>str</em>, or <tt>nil</tt> if no modifications were made.

  def chomp!(separator = $/)
    return gsub!(/#{Regexp.escape separator}\Z/, '')
  end

  ##
  # call-seq:
  #   str.chop   => new_str
  #
  # Returns a new <tt>String</tt> with the last character removed. If the
  # string ends with <tt>\r\n</tt>, both characters are removed. Applying
  # <tt>chop</tt> to an empty string returns an empty string.
  # <tt>String#chomp</tt> is often a safer alternative, as it leaves the
  # string unchanged if it doesn't end in a record separator.
  #
  #    "string\r\n".chop   #=> "string"
  #    "string\n\r".chop   #=> "string\n"
  #    "string\n".chop     #=> "string"
  #    "string".chop       #=> "strin"
  #    "x".chop.chop       #=> ""

  def chop
    return self.dup.chop!.to_s
  end

  ##
  # call-seq:
  #   str.chop!   => str or nil
  #
  # Processes <em>str</em> as for <tt>String#chop</tt>, returning
  # <em>str</em>, or <tt>nil</tt> if <em>str</em> is the empty string. See
  # also <tt>String#chomp!</tt>.

  def chop!
    return nil if self == ""
    return self.replace(self[0..-3]) if self[-1] == ?\n and self[-2] == ?\r
    return self.replace(self[0..-2])
  end

  ##
  # call-seq:
  #   str << fixnum        => str
  #   str.concat(fixnum)   => str
  #   str << obj           => str
  #   str.concat(obj)      => str
  #
  # Append---Concatenates the given object to <em>str</em>. If the object is
  # a <tt>Fixnum</tt> between 0 and 255, it is converted to a character
  # before concatenation.
  #
  #    a = "hello "
  #    a << "world"   #=> "hello world"
  #    a.concat(33)   #=> "hello world!"

  alias concat <<

  ##
  # call-seq:
  #   str.count([other_str]+)   => fixnum
  #
  # Each <em>other_str</em> parameter defines a set of characters to count.
  # The intersection of these sets defines the characters to count in
  # <em>str</em>. Any <em>other_str</em> that starts with a caret (^) is
  # negated. The sequence c1--c2 means all characters between c1 and c2.
  #
  #    a = "hello world"
  #    a.count "lo"            #=> 5
  #    a.count "lo", "o"       #=> 2
  #    a.count "hello", "^l"   #=> 4
  #    a.count "ej-m"          #=> 4

#  def count(*args)
#  end

  ##
  # call-seq:
  #   str.crypt(other_str)   => new_str
  #
  # Applies a one-way cryptographic hash to <em>str</em> by invoking the
  # standard library function <tt>crypt</tt>. The argument is the salt
  # string, which should be two characters long, each character drawn from
  # <tt>[a-zA-Z0-9./]</tt>.

#  def crypt(arg1)
#  end

  ##
  # call-seq:
  #   str.delete([other_str]+)   => new_str
  #
  # Returns a copy of <em>str</em> with all characters in the intersection
  # of its arguments deleted. Uses the same rules for building the set of
  # characters as <tt>String#count</tt>.
  #
  #    "hello".delete "l","lo"        #=> "heo"
  #    "hello".delete "lo"            #=> "he"
  #    "hello".delete "aeiou", "^e"   #=> "hell"
  #    "hello".delete "ej-m"          #=> "ho"

#  def delete(*args)
#  end

  ##
  # call-seq:
  #   str.delete!([other_str]+>)   => str or nil
  #
  # Performs a <tt>delete</tt> operation in place, returning <em>str</em>,
  # or <tt>nil</tt> if <em>str</em> was not modified.

#  def delete!(*args)
#    :junk
#  end

  ##
  # call-seq:
  #   str.downcase   => new_str
  #
  # Returns a copy of <em>str</em> with all uppercase letters replaced with
  # their lowercase counterparts. The operation is locale insensitive---only
  # characters ``A'' to ``Z'' are affected.
  #
  #    "hEllO".downcase   #=> "hello"

  def downcase
    str = self.dup
    str.downcase!
    return str
  end

  ##
  # call-seq:
  #   str.downcase!   => str or nil
  #
  # Downcases the contents of <em>str</em>, returning <tt>nil</tt> if no
  # changes were made.

  def downcase!
    modify = nil
    0.upto(self.length - 1) do |i|
      cur = self[i].chr
      if isupper cur then
        self[i] = tolower cur
        modify = self
      end
    end

    return modify
  end

  ##
  # call-seq:
  #   str.dump   => new_str
  #
  # Produces a version of <em>str</em> with all nonprinting characters
  # replaced by <tt>\nnn</tt> notation and all special characters escaped.

#  def dump
#  end

  ##
  # call-seq:
  #   str.each(separator=$/) {|substr| block }        => str
  #   str.each_line(separator=$/) {|substr| block }   => str
  #
  # Splits <em>str</em> using the supplied parameter as the record separator
  # (<tt>$/</tt> by default), passing each substring in turn to the supplied
  # block. If a zero-length record separator is supplied, the string is
  # split on <tt>\n</tt> characters, except that multiple successive
  # newlines are appended together.
  #
  #    print "Example one\n"
  #    "hello\nworld".each {|s| p s}
  #    print "Example two\n"
  #    "hello\nworld".each('l') {|s| p s}
  #    print "Example three\n"
  #    "hello\n\n\nworld".each('') {|s| p s}
  #
  # <em>produces:</em>
  #
  #    Example one
  #    "hello\n"
  #    "world"
  #    Example two
  #    "hel"
  #    "l"
  #    "o\nworl"
  #    "d"
  #    Example three
  #    "hello\n\n\n"
  #    "world"

#  def each(*args)
#  end

  ##
  # call-seq:
  #   str.each_byte {|fixnum| block }    => str
  #
  # Passes each byte in <em>str</em> to the given block.
  #
  #    "hello".each_byte {|c| print c, ' ' }
  #
  # <em>produces:</em>
  #
  #    104 101 108 108 111

  #def each_byte; end # HACK

  ##
  # call-seq:
  #   str.each(separator=$/) {|substr| block }        => str
  #   str.each_line(separator=$/) {|substr| block }   => str
  #
  # Splits <em>str</em> using the supplied parameter as the record separator
  # (<tt>$/</tt> by default), passing each substring in turn to the supplied
  # block. If a zero-length record separator is supplied, the string is
  # split on <tt>\n</tt> characters, except that multiple successive
  # newlines are appended together.
  #
  #    print "Example one\n"
  #    "hello\nworld".each {|s| p s}
  #    print "Example two\n"
  #    "hello\nworld".each('l') {|s| p s}
  #    print "Example three\n"
  #    "hello\n\n\nworld".each('') {|s| p s}
  #
  # <em>produces:</em>
  #
  #    Example one
  #    "hello\n"
  #    "world"
  #    Example two
  #    "hel"
  #    "l"
  #    "o\nworl"
  #    "d"
  #    Example three
  #    "hello\n\n\n"
  #    "world"

#  def each_line(*args)
#  end

  ##
  # call-seq:
  #   str.empty?   => true or false
  #
  # Returns <tt>true</tt> if <em>str</em> has a length of zero.
  #
  #    "hello".empty?   #=> false
  #    "".empty?        #=> true

  def empty?
    return self.length == 0
  end

  ##
  # call-seq:
  #   str.eql?(other)   => true or false
  #
  # Two strings are equal if the have the same length and content.

  def eql?(other)
    return false unless String === other
    return false unless other.length == self.length

    0.upto(self.length - 1) do |i|
      return false if self[i] != other[i]
    end

    return true
  end

  ##
  # call-seq:
  #   str.gsub(pattern, replacement)       => new_str
  #   str.gsub(pattern) {|match| block }   => new_str
  #
  # Returns a copy of <em>str</em> with <em>all</em> occurrences of
  # <em>pattern</em> replaced with either <em>replacement</em> or the value
  # of the block. The <em>pattern</em> will typically be a <tt>Regexp</tt>;
  # if it is a <tt>String</tt> then no regular expression metacharacters
  # will be interpreted (that is <tt>/\d/</tt> will match a digit, but
  # <tt>'\d'</tt> will match a backslash followed by a 'd').
  #
  # If a string is used as the replacement, special variables from the match
  # (such as <tt>$&</tt> and <tt>$1</tt>) cannot be substituted into it, as
  # substitution into the string occurs before the pattern match starts.
  # However, the sequences <tt>\1</tt>, <tt>\2</tt>, and so on may be used
  # to interpolate successive groups in the match.
  #
  # In the block form, the current match string is passed in as a parameter,
  # and variables such as <tt>$1</tt>, <tt>$2</tt>, <tt>$`</tt>,
  # <tt>$&</tt>, and <tt>$'</tt> will be set appropriately. The value
  # returned by the block will be substituted for the match on each call.
  #
  # The result inherits any tainting in the original string or any supplied
  # replacement string.
  #
  #    "hello".gsub(/[aeiou]/, '*')              #=> "h*ll*"
  #    "hello".gsub(/([aeiou])/, '<\1>')         #=> "h<e>ll<o>"
  #    "hello".gsub(/./) {|s| s[0].to_s + ' '}   #=> "104 101 108 108 111 "
  #--
  # HACK need interpreter help for making gsub work, gsub(pattern) { $1 }
  # fails

  #def gsub(*args); end # HACK

  ##
  # call-seq:
  #   str.gsub!(pattern, replacement)        => str or nil
  #   str.gsub!(pattern) {|match| block }    => str or nil
  #
  # Performs the substitutions of <tt>String#gsub</tt> in place, returning
  # <em>str</em>, or <tt>nil</tt> if no substitutions were performed.
  #--
  # HACK need interpreter help for making gsub! work, gsub!(pattern) { $1 }
  # fails

#  def gsub!(*args)
#  end

  ##
  # call-seq:
  #   str.hash   => fixnum
  #
  # Return a hash based on the string's length and content.
  #--
  # WARN Probably bad because of Bignum

  def hash
    key = 0
    0.upto(self.length - 1) do |i|
      key = key * 65599 + self[i]
    end
    key += key >> 5
    return key
  end

  ##
  # call-seq:
  #   str.hex   => integer
  #
  # Treats leading characters from <em>str</em> as a string of hexadecimal
  # digits (with an optional sign and an optional <tt>0x</tt>) and returns
  # the corresponding number. Zero is returned on error.
  #
  #    "0x0a".hex     #=> 10
  #    "-1234".hex    #=> -4660
  #    "0".hex        #=> 0
  #    "wombat".hex   #=> 0

  def hex
    negative = 1
    val = 0

    s = self

    if s[0] == ?- then
      negative = -1
      s = s.sub(/^-/, '')
    end

    s = s.sub(/^0x/i, '')

    s.each_byte do |char|
      val *= 0x10

      val += case char
             when ?0..?9 then
               char - ?0
             when ?a..?f then
               char - ?a + 10
             when ?A..?F then
               char - ?A + 10
             else
               val /= 0x10
               break
             end
    end

    return val * negative 
  end

  ##
  # call-seq:
  #   str.include? other_str   => true or false
  #   str.include? fixnum      => true or false
  #
  # Returns <tt>true</tt> if <em>str</em> contains the given string or
  # character.
  #
  #    "hello".include? "lo"   #=> true
  #    "hello".include? "ol"   #=> false
  #    "hello".include? ?h     #=> true

  def include?(str)
    return !self.index(str).nil?
  end

  ##
  # call-seq:
  #   str.index(substring [, offset])   => fixnum or nil
  #   str.index(fixnum [, offset])      => fixnum or nil
  #   str.index(regexp [, offset])      => fixnum or nil
  #
  # Returns the index of the first occurrence of the given
  # <em>substring</em>, character (<em>fixnum</em>), or pattern
  # (<em>regexp</em>) in <em>str</em>. Returns <tt>nil</tt> if not found. If
  # the second parameter is present, it specifies the position in the string
  # to begin the search.
  #
  #    "hello".index('e')             #=> 1
  #    "hello".index('lo')            #=> 3
  #    "hello".index('a')             #=> nil
  #    "hello".index(101)             #=> 1
  #    "hello".index(/[aeiou]/, -3)   #=> 4

  def index(search, offset = 0)
    if offset < 0 then
      offset += self.length
      return nil if offset < 0
    end

    case search
    when Regexp then # nop
    when Fixnum then
      search = /#{Regexp.escape search.chr}/
    else
      search = /#{Regexp.escape convert(search)}/
    end

    pos = self[offset..-1] =~ search
    return pos.nil? ? nil : pos + offset
  end

  ##
  # call-seq:
  #   str.insert(index, other_str)   => str
  #
  # Inserts <em>other_str</em> before the character at the given
  # <em>index</em>, modifying <em>str</em>. Negative indices count from the
  # end of the string, and insert <em>after</em> the given character. The
  # intent is insert <em>aString</em> so that it starts at the given
  # <em>index</em>.
  #
  #    "abcd".insert(0, 'X')    #=> "Xabcd"
  #    "abcd".insert(3, 'X')    #=> "abcXd"
  #    "abcd".insert(4, 'X')    #=> "abcdX"
  #    "abcd".insert(-3, 'X')   #=> "abXcd"
  #    "abcd".insert(-1, 'X')   #=> "abcdX"

#  def insert(arg1, arg2)
#  end

  ##
  # call-seq:
  #   str.inspect   => string
  #
  # Returns a printable version of <em>str</em>, with special characters
  # escaped.
  #
  #    str = "hello"
  #    str[3] = 8
  #    str.inspect       #=> "hel\010o"

  #def inspect; end # HACK

  ##
  # call-seq:
  #   str.intern   => symbol
  #   str.to_sym   => symbol
  #
  # Returns the <tt>Symbol</tt> corresponding to <em>str</em>, creating the
  # symbol if it did not previously exist. See <tt>Symbol#id2name</tt>.
  #
  #    "Koala".intern         #=> :Koala
  #    s = 'cat'.to_sym       #=> :cat
  #    s == :cat              #=> true
  #    s = '@cat'.to_sym      #=> :@cat
  #    s == :@cat             #=> true
  #
  # This can also be used to create symbols that cannot be represented using
  # the <tt>:xxx</tt> notation.
  #
  #    'cat and dog'.to_sym   #=> :"cat and dog"

  #def intern; end # CORE

  ##
  # call-seq:
  #   str.length   => integer
  #
  # Returns the length of <em>str</em>.

  #def length; end # CORE

  ##
  # call-seq:
  #   str.ljust(integer, padstr=' ')   => new_str
  #
  # If <em>integer</em> is greater than the length of <em>str</em>, returns
  # a new <tt>String</tt> of length <em>integer</em> with <em>str</em> left
  # justified and padded with <em>padstr</em>; otherwise, returns
  # <em>str</em>.
  #
  #    "hello".ljust(4)            #=> "hello"
  #    "hello".ljust(20)           #=> "hello               "
  #    "hello".ljust(20, '1234')   #=> "hello123412341234123"

#  def ljust(*args)
#  end

  ##
  # call-seq:
  #   str.lstrip   => new_str
  #
  # Returns a copy of <em>str</em> with leading whitespace removed. See also
  # <tt>String#rstrip</tt> and <tt>String#strip</tt>.
  #
  #    "  hello  ".lstrip   #=> "hello  "
  #    "hello".lstrip       #=> "hello"

  def lstrip
    str = self.dup
    str.lstrip!
    return str
  end

  ##
  # call-seq:
  #   str.lstrip!   => self or nil
  #
  # Removes leading whitespace from <em>str</em>, returning <tt>nil</tt> if
  # no change was made. See also <tt>String#rstrip!</tt> and
  # <tt>String#strip!</tt>.
  #
  #    "  hello  ".lstrip   #=> "hello  "
  #    "hello".lstrip!      #=> nil

  def lstrip!
    gsub!(/\A\s+/, '')
  end

  ##
  # call-seq:
  #   str.match(pattern)   => matchdata or nil
  #
  # Converts <em>pattern</em> to a <tt>Regexp</tt> (if it isn't already
  # one), then invokes its <tt>match</tt> method on <em>str</em>.
  #
  #    'hello'.match('(.)\1')      #=> #<MatchData:0x401b3d30>
  #    'hello'.match('(.)\1')[0]   #=> "ll"
  #    'hello'.match(/(.)\1/)[0]   #=> "ll"
  #    'hello'.match('xx')         #=> nil

#  def match(arg1)
#  end

  ##
  # call-seq:
  #   str.succ   => new_str
  #   str.next   => new_str
  #
  # Returns the successor to <em>str</em>. The successor is calculated by
  # incrementing characters starting from the rightmost alphanumeric (or the
  # rightmost character if there are no alphanumerics) in the string.
  # Incrementing a digit always results in another digit, and incrementing a
  # letter results in another letter of the same case. Incrementing
  # nonalphanumerics uses the underlying character set's collating sequence.
  #
  # If the increment generates a ``carry,'' the character to the left of it
  # is incremented. This process repeats until there is no carry, adding an
  # additional character if necessary.
  #
  #    "abcd".succ        #=> "abce"
  #    "THX1138".succ     #=> "THX1139"
  #    "<<koala>>".succ   #=> "<<koalb>>"
  #    "1999zzz".succ     #=> "2000aaa"
  #    "ZZZ9999".succ     #=> "AAAA0000"
  #    "***".succ         #=> "**+"

  alias next succ

  ##
  # call-seq:
  #   str.succ!   => str
  #   str.next!   => str
  #
  # Equivalent to <tt>String#succ</tt>, but modifies the receiver in place.

  alias next! succ!

  ##
  # call-seq:
  #   str.oct   => integer
  #
  # Treats leading characters of <em>str</em> as a string of octal digits
  # (with an optional sign) and returns the corresponding number. Returns 0
  # if the conversion fails.
  #
  #    "123".oct       #=> 83
  #    "-377".oct      #=> -255
  #    "bad".oct       #=> 0
  #    "0377bad".oct   #=> 255

  def oct
    negative = 1
    val = 0

    s = self

    if s[0] == ?- then
      negative = -1
      s = s.sub(/^-/, '')
    end

    s = s.sub(/^0/, '')

    s.each_byte do |char|
      val *= 010

      val += case char
             when ?0..?7 then
               char - ?0
             else
               val /= 010
               break
             end
    end

    return val * negative 
  end

  ##
  # call-seq:
  #   str.replace(other_str)   => str
  #
  # Replaces the contents and taintedness of <em>str</em> with the
  # corresponding values in <em>other_str</em>.
  #
  #    s = "hello"         #=> "hello"
  #    s.replace "world"   #=> "world"

  #def replace(arg1); end

  ##
  # call-seq:
  #   str.reverse   => new_str
  #
  # Returns a new string with the characters from <em>str</em> in reverse
  # order.
  #
  #    "stressed".reverse   #=> "desserts"

  def reverse
    self.dup.reverse!
  end

  ##
  # call-seq:
  #   str.reverse!   => str
  #
  # Reverses <em>str</em> in place.

  def reverse!
    return self if self.length == 1 or self.empty?

    front = 0
    back = self.length - 1
    while front < back do
      cur = self[front]
      self[front] = self[back]
      self[back] = cur
      front += 1
      back -= 1
    end

    return self
  end

  ##
  # call-seq:
  #   str.rindex(substring [, fixnum])   => fixnum or nil
  #   str.rindex(fixnum [, fixnum])   => fixnum or nil
  #   str.rindex(regexp [, fixnum])   => fixnum or nil
  #
  # Returns the index of the last occurrence of the given
  # <em>substring</em>, character (<em>fixnum</em>), or pattern
  # (<em>regexp</em>) in <em>str</em>. Returns <tt>nil</tt> if not found. If
  # the second parameter is present, it specifies the position in the string
  # to end the search---characters beyond this point will not be considered.
  #
  #    "hello".rindex('e')             #=> 1
  #    "hello".rindex('l')             #=> 3
  #    "hello".rindex('a')             #=> nil
  #    "hello".rindex(101)             #=> 1
  #    "hello".rindex(/[aeiou]/, -2)   #=> 1

#  def rindex(*args)
#  end

  ##
  # call-seq:
  #   str.rjust(integer, padstr=' ')   => new_str
  #
  # If <em>integer</em> is greater than the length of <em>str</em>, returns
  # a new <tt>String</tt> of length <em>integer</em> with <em>str</em> right
  # justified and padded with <em>padstr</em>; otherwise, returns
  # <em>str</em>.
  #
  #    "hello".rjust(4)            #=> "hello"
  #    "hello".rjust(20)           #=> "               hello"
  #    "hello".rjust(20, '1234')   #=> "123412341234123hello"

#  def rjust(*args)
#  end

  ##
  # call-seq:
  #   str.rstrip   => new_str
  #
  # Returns a copy of <em>str</em> with trailing whitespace removed. See
  # also <tt>String#lstrip</tt> and <tt>String#strip</tt>.
  #
  #    "  hello  ".rstrip   #=> "  hello"
  #    "hello".rstrip       #=> "hello"

  def rstrip
    str = self.dup
    str.rstrip!
    return str
  end

  ##
  # call-seq:
  #   str.rstrip!   => self or nil
  #
  # Removes trailing whitespace from <em>str</em>, returning <tt>nil</tt> if
  # no change was made. See also <tt>String#lstrip!</tt> and
  # <tt>String#strip!</tt>.
  #
  #    "  hello  ".rstrip   #=> "  hello"
  #    "hello".rstrip!      #=> nil

  def rstrip!
    gsub!(/\s+\Z/, '')
  end

  ##
  # call-seq:
  #   str.scan(pattern)                         => array
  #   str.scan(pattern) {|match, ...| block }   => str
  #
  # Both forms iterate through <em>str</em>, matching the pattern (which may
  # be a <tt>Regexp</tt> or a <tt>String</tt>). For each match, a result is
  # generated and either added to the result array or passed to the block.
  # If the pattern contains no groups, each individual result consists of
  # the matched string, <tt>$&</tt>. If the pattern contains groups, each
  # individual result is itself an array containing one entry per group.
  #
  #    a = "cruel world"
  #    a.scan(/\w+/)        #=> ["cruel", "world"]
  #    a.scan(/.../)        #=> ["cru", "el ", "wor"]
  #    a.scan(/(...)/)      #=> [["cru"], ["el "], ["wor"]]
  #    a.scan(/(..)(..)/)   #=> [["cr", "ue"], ["l ", "wo"]]
  #
  # And the block form:
  #
  #    a.scan(/\w+/) {|w| print "<<#{w}>> " }
  #    print "\n"
  #    a.scan(/(.)(.)/) {|a,b| print b, a }
  #    print "\n"
  #
  # <em>produces:</em>
  #
  #    <<cruel>> <<world>>
  #    rceu lowlr

  #def scan(arg1); end # HACK

  ##
  # call-seq:
  #   str.length   => integer
  #
  # Returns the length of <em>str</em>.

  alias size length

  ##
  # call-seq:
  #   str[fixnum]                 => fixnum or nil
  #   str[fixnum, fixnum]         => new_str or nil
  #   str[range]                  => new_str or nil
  #   str[regexp]                 => new_str or nil
  #   str[regexp, fixnum]         => new_str or nil
  #   str[other_str]              => new_str or nil
  #   str.slice(fixnum)           => fixnum or nil
  #   str.slice(fixnum, fixnum)   => new_str or nil
  #   str.slice(range)            => new_str or nil
  #   str.slice(regexp)           => new_str or nil
  #   str.slice(regexp, fixnum)   => new_str or nil
  #   str.slice(other_str)        => new_str or nil
  #
  # Element Reference---If passed a single <tt>Fixnum</tt>, returns the code
  # of the character at that position. If passed two <tt>Fixnum</tt>
  # objects, returns a substring starting at the offset given by the first,
  # and a length given by the second. If given a range, a substring
  # containing characters at offsets given by the range is returned. In all
  # three cases, if an offset is negative, it is counted from the end of
  # <em>str</em>. Returns <tt>nil</tt> if the initial offset falls outside
  # the string, the length is negative, or the beginning of the range is
  # greater than the end.
  #
  # If a <tt>Regexp</tt> is supplied, the matching portion of <em>str</em>
  # is returned. If a numeric parameter follows the regular expression, that
  # component of the <tt>MatchData</tt> is returned instead. If a
  # <tt>String</tt> is given, that string is returned if it occurs in
  # <em>str</em>. In both cases, <tt>nil</tt> is returned if there is no
  # match.
  #
  #    a = "hello there"
  #    a[1]                   #=> 101
  #    a[1,3]                 #=> "ell"
  #    a[1..3]                #=> "ell"
  #    a[-3,2]                #=> "er"
  #    a[-4..-2]              #=> "her"
  #    a[12..-1]              #=> nil
  #    a[-2..-4]              #=> ""
  #    a[/[aeiou](.)\1/]      #=> "ell"
  #    a[/[aeiou](.)\1/, 0]   #=> "ell"
  #    a[/[aeiou](.)\1/, 1]   #=> "l"
  #    a[/[aeiou](.)\1/, 2]   #=> nil
  #    a["lo"]                #=> "lo"
  #    a["bye"]               #=> nil

#  def slice(*args)
#  end

  ##
  # call-seq:
  #   str.slice!(fixnum)           => fixnum or nil
  #   str.slice!(fixnum, fixnum)   => new_str or nil
  #   str.slice!(range)            => new_str or nil
  #   str.slice!(regexp)           => new_str or nil
  #   str.slice!(other_str)        => new_str or nil
  #
  # Deletes the specified portion from <em>str</em>, and returns the portion
  # deleted. The forms that take a <tt>Fixnum</tt> will raise an
  # <tt>IndexError</tt> if the value is out of range; the <tt>Range</tt>
  # form will raise a <tt>RangeError</tt>, and the <tt>Regexp</tt> and
  # <tt>String</tt> forms will silently ignore the assignment.
  #
  #    string = "this is a string"
  #    string.slice!(2)        #=> 105
  #    string.slice!(3..6)     #=> " is "
  #    string.slice!(/s.*t/)   #=> "sa st"
  #    string.slice!("r")      #=> "r"
  #    string                  #=> "thing"

  # def slice!(*args); end

  ##
  # call-seq:
  #   str.split(pattern=$;, [limit])   => anArray
  #
  # Divides <em>str</em> into substrings based on a delimiter, returning an
  # array of these substrings.
  #
  # If <em>pattern</em> is a <tt>String</tt>, then its contents are used as
  # the delimiter when splitting <em>str</em>. If <em>pattern</em> is a
  # single space, <em>str</em> is split on whitespace, with leading
  # whitespace and runs of contiguous whitespace characters ignored.
  #
  # If <em>pattern</em> is a <tt>Regexp</tt>, <em>str</em> is divided where
  # the pattern matches. Whenever the pattern matches a zero-length string,
  # <em>str</em> is split into individual characters.
  #
  # If <em>pattern</em> is omitted, the value of <tt>$;</tt> is used. If
  # <tt>$;</tt> is <tt>nil</tt> (which is the default), <em>str</em> is
  # split on whitespace as if ` ' were specified.
  #
  # If the <em>limit</em> parameter is omitted, trailing null fields are
  # suppressed. If <em>limit</em> is a positive number, at most that number
  # of fields will be returned (if <em>limit</em> is <tt>1</tt>, the entire
  # string is returned as the only entry in an array). If negative, there is
  # no limit to the number of fields returned, and trailing null fields are
  # not suppressed.
  #
  #    " now's  the time".split        #=> ["now's", "the", "time"]
  #    " now's  the time".split(' ')   #=> ["now's", "the", "time"]
  #    " now's  the time".split(/ /)   #=> ["", "now's", "", "the", "time"]
  #    "1, 2.34,56, 7".split(%r{,\s*}) #=> ["1", "2.34", "56", "7"]
  #    "hello".split(//)               #=> ["h", "e", "l", "l", "o"]
  #    "hello".split(//, 3)            #=> ["h", "e", "llo"]
  #    "hi mom".split(%r{\s*})         #=> ["h", "i", "m", "o", "m"]
  #    "mellow yellow".split("ello")   #=> ["m", "w y", "w"]
  #    "1,2,,3,4,,".split(',')         #=> ["1", "2", "", "3", "4"]
  #    "1,2,,3,4,,".split(',', 4)      #=> ["1", "2", "", "3,4,,"]
  #    "1,2,,3,4,,".split(',', -4)     #=> ["1", "2", "", "3", "4", "", ""]

  #def split(*args); end # HACK

  ##
  # call-seq:
  #   str.squeeze([other_str]*)    => new_str
  #
  # Builds a set of characters from the <em>other_str</em> parameter(s)
  # using the procedure described for <tt>String#count</tt>. Returns a new
  # string where runs of the same character that occur in this set are
  # replaced by a single character. If no arguments are given, all runs of
  # identical characters are replaced by a single character.
  #
  #    "yellow moon".squeeze                  #=> "yelow mon"
  #    "  now   is  the".squeeze(" ")         #=> " now is the"
  #    "putters shoot balls".squeeze("m-z")   #=> "puters shot balls"

#  def squeeze(*args)
#  end

  ##
  # call-seq:
  #   str.squeeze!([other_str]*)   => str or nil
  #
  # Squeezes <em>str</em> in place, returning either <em>str</em>, or
  # <tt>nil</tt> if no changes were made.

  # def squeeze!(*args); end # HACK

  ##
  # call-seq:
  #   str.strip   => new_str
  #
  # Returns a copy of <em>str</em> with leading and trailing whitespace
  # removed.
  #
  #    "    hello    ".strip   #=> "hello"
  #    "\tgoodbye\r\n".strip   #=> "goodbye"

  def strip
    str = self.dup
    str.strip!
    return str
  end

  ##
  # call-seq:
  #   str.strip!   => str or nil
  #
  # Removes leading and trailing whitespace from <em>str</em>. Returns
  # <tt>nil</tt> if <em>str</em> was not altered.

  def strip!
    result = rstrip!
    return lstrip! || result
  end

  ##
  # call-seq:
  #   str.sub(pattern, replacement)         => new_str
  #   str.sub(pattern) {|match| block }     => new_str
  #
  # Returns a copy of <em>str</em> with the <em>first</em> occurrence of
  # <em>pattern</em> replaced with either <em>replacement</em> or the value
  # of the block. The <em>pattern</em> will typically be a <tt>Regexp</tt>;
  # if it is a <tt>String</tt> then no regular expression metacharacters
  # will be interpreted (that is <tt>/\d/</tt> will match a digit, but
  # <tt>'\d'</tt> will match a backslash followed by a 'd').
  #
  # If the method call specifies <em>replacement</em>, special variables
  # such as <tt>$&</tt> will not be useful, as substitution into the string
  # occurs before the pattern match starts. However, the sequences
  # <tt>\1</tt>, <tt>\2</tt>, etc., may be used.
  #
  # In the block form, the current match string is passed in as a parameter,
  # and variables such as <tt>$1</tt>, <tt>$2</tt>, <tt>$`</tt>,
  # <tt>$&</tt>, and <tt>$'</tt> will be set appropriately. The value
  # returned by the block will be substituted for the match on each call.
  #
  # The result inherits any tainting in the original string or any supplied
  # replacement string.
  #
  #    "hello".sub(/[aeiou]/, '*')               #=> "h*llo"
  #    "hello".sub(/([aeiou])/, '<\1>')          #=> "h<e>llo"
  #    "hello".sub(/./) {|s| s[0].to_s + ' ' }   #=> "104 ello"
  #--
  # HACK need interpreter help for making sub work, sub(pattern) { $1 }
  # fails

  #def sub(*args); end

  ##
  # call-seq:
  #   str.sub!(pattern, replacement)          => str or nil
  #   str.sub!(pattern) {|match| block }      => str or nil
  #
  # Performs the substitutions of <tt>String#sub</tt> in place, returning
  # <em>str</em>, or <tt>nil</tt> if no substitutions were performed.
  #--
  # HACK need interpreter help for making sub! work, sub!(pattern) { $1 }
  # fails

#  def sub!(pattern, replacement = nil)
#    if replacement.nil? and not block_given? then
#      raise TypeError, "can't convert nil into String"
#    end
#
#    case pattern
#    when Regexp then # nop
#    when String then
#      pattern = /#{Regexp.quote pattern}/
#    end
#
#    if block_given? then
#      pos = self =~ pattern
#      match = $&
#      pre_match = $`
#      post_match = $'
#
#      if pos.nil? then
#        yield nil
#        return nil
#      end
#
#      replacement = yield match
#      puts replacement
#      new = pre_match << replacement << post_match
#      puts new
#      self.replace new
#      return self
#    end
#
#    #puts "Looking for %p in %p" % [pattern, self]
#    match = pattern.match self
#
#    return nil if match.nil?
#
#    new = match.pre_match
#
#    if match.captures.length > 0 then # maybe split out \\N ...
#      replacement = replacement.dup
#      match.captures.each_with_index do |capture, i|
#        replacement.sub! "\\#{i+1}", capture
#      end
#    end
#
#    new << replacement << match.post_match
#
#    self.replace new
#    return self
#  end

  ##
  # call-seq:
  #   str.succ   => new_str
  #   str.next   => new_str
  #
  # Returns the successor to <em>str</em>. The successor is calculated by
  # incrementing characters starting from the rightmost alphanumeric (or the
  # rightmost character if there are no alphanumerics) in the string.
  # Incrementing a digit always results in another digit, and incrementing a
  # letter results in another letter of the same case. Incrementing
  # nonalphanumerics uses the underlying character set's collating sequence.
  #
  # If the increment generates a ``carry,'' the character to the left of it
  # is incremented. This process repeats until there is no carry, adding an
  # additional character if necessary.
  #
  #    "abcd".succ        #=> "abce"
  #    "THX1138".succ     #=> "THX1139"
  #    "<<koala>>".succ   #=> "<<koalb>>"
  #    "1999zzz".succ     #=> "2000aaa"
  #    "ZZZ9999".succ     #=> "AAAA0000"
  #    "***".succ         #=> "**+"

  def succ
    return self.dup.succ!
  end

  ##
  # call-seq:
  #   str.succ!   => str
  #   str.next!   => str
  #
  # Equivalent to <tt>String#succ</tt>, but modifies the receiver in place.

  def succ!
    prepend = false
    c = :junk

    has_alnum = false
    (self.length - 1).downto 0 do |i|
      if isalnum self[i].chr then
        c = succ_char self, i
        break if c.nil?
        prepend = i == 0
      end
    end

    if c == :junk then # no alnum
      c = "\001"
      (self.length - 1).downto 0 do |i|
        new = self[i] = (self[i] + 1) % 0x100
        break if new != 0
        prepend = i == 0
      end
    end

    if prepend then
      self << 255 # extend
      self[1..-1] = self[0..-2]
      self[0] = c
    end

    return self
  end

  ##
  # call-seq:
  #   str.sum(n=16)   => integer
  #
  # Returns a basic <em>n</em>-bit checksum of the characters in
  # <em>str</em>, where <em>n</em> is the optional <tt>Fixnum</tt>
  # parameter, defaulting to 16. The result is simply the sum of the binary
  # value of each character in <em>str</em> modulo <tt>2n - 1</tt>. This is
  # not a particularly good checksum.

#  def sum(bits = 16)
#  end

  ##
  # call-seq:
  #   str.swapcase   => new_str
  #
  # Returns a copy of <em>str</em> with uppercase alphabetic characters
  # converted to lowercase and lowercase characters converted to uppercase.
  #
  #    "Hello".swapcase          #=> "hELLO"
  #    "cYbEr_PuNk11".swapcase   #=> "CyBeR_pUnK11"

  def swapcase
    new = dup
    new.swapcase!
    return new
  end

  ##
  # call-seq:
  #   str.swapcase!   => str or nil
  #
  # Equivalent to <tt>String#swapcase</tt>, but modifies the receiver in
  # place, returning <em>str</em>, or <tt>nil</tt> if no changes were made.

  def swapcase!
    modified = false

    0.upto(self.length - 1) do |i|
      cur = self[i].chr
      if isupper cur then
        self[i] = tolower cur
        modified = true
      elsif islower cur then
        self[i] = toupper cur
        modified = true
      end
    end

    return modified ? self : nil
  end

  ##
  # call-seq:
  #   str.to_f   => float
  #
  # Returns the result of interpreting leading characters in <em>str</em> as
  # a floating point number. Extraneous characters past the end of a valid
  # number are ignored. If there is not a valid number at the start of
  # <em>str</em>, <tt>0.0</tt> is returned. This method never raises an
  # exception.
  #
  #    "123.45e1".to_f        #=> 1234.5
  #    "45.67 degrees".to_f   #=> 45.67
  #    "thx1138".to_f         #=> 0.0

#  def to_f
#  end

  ##
  # call-seq:
  #   str.to_i(base=10)   => integer
  #
  # Returns the result of interpreting leading characters in <em>str</em> as
  # an integer base <em>base</em> (2, 8, 10, or 16). Extraneous characters
  # past the end of a valid number are ignored. If there is not a valid
  # number at the start of <em>str</em>, <tt>0</tt> is returned. This method
  # never raises an exception.
  #
  #    "12345".to_i             #=> 12345
  #    "99 red balloons".to_i   #=> 99
  #    "0a".to_i                #=> 0
  #    "0a".to_i(16)            #=> 10
  #    "hello".to_i             #=> 0
  #    "1100101".to_i(2)        #=> 101
  #    "1100101".to_i(8)        #=> 294977
  #    "1100101".to_i(10)       #=> 1100101
  #    "1100101".to_i(16)       #=> 17826049

  #def to_i(*args); end # HACK

  ##
  # call-seq:
  #   str.to_s     => str
  #   str.to_str   => str
  #
  # Returns the receiver.

  def to_s
    return self if self.class == String
    return String.new(dup)
  end

  ##
  # call-seq:
  #   str.to_s     => str
  #   str.to_str   => str
  #
  # Returns the receiver.

  alias to_str to_s

  ##
  # call-seq:
  #   str.intern   => symbol
  #   str.to_sym   => symbol
  #
  # Returns the <tt>Symbol</tt> corresponding to <em>str</em>, creating the
  # symbol if it did not previously exist. See <tt>Symbol#id2name</tt>.
  #
  #    "Koala".intern         #=> :Koala
  #    s = 'cat'.to_sym       #=> :cat
  #    s == :cat              #=> true
  #    s = '@cat'.to_sym      #=> :@cat
  #    s == :@cat             #=> true
  #
  # This can also be used to create symbols that cannot be represented using
  # the <tt>:xxx</tt> notation.
  #
  #    'cat and dog'.to_sym   #=> :"cat and dog"

  alias to_sym intern

  ##
  # call-seq:
  #   str.tr(from_str, to_str)   => new_str
  #
  # Returns a copy of <em>str</em> with the characters in <em>from_str</em>
  # replaced by the corresponding characters in <em>to_str</em>. If
  # <em>to_str</em> is shorter than <em>from_str</em>, it is padded with its
  # last character. Both strings may use the c1--c2 notation to denote
  # ranges of characters, and <em>from_str</em> may start with a <tt>^</tt>,
  # which denotes all characters except those listed.
  #
  #    "hello".tr('aeiou', '*')    #=> "h*ll*"
  #    "hello".tr('^aeiou', '*')   #=> "<b>e</b>*o"
  #    "hello".tr('el', 'ip')      #=> "hippo"
  #    "hello".tr('a-y', 'b-z')    #=> "ifmmp"

#  def tr(arg1, arg2)
#  end

  ##
  # call-seq:
  #   str.tr!(from_str, to_str)   => str or nil
  #
  # Translates <em>str</em> in place, using the same rules as
  # <tt>String#tr</tt>. Returns <em>str</em>, or <tt>nil</tt> if no changes
  # were made.

#  def tr!(arg1, arg2)
#  end

  ##
  # call-seq:
  #   str.tr_s(from_str, to_str)   => new_str
  #
  # Processes a copy of <em>str</em> as described under <tt>String#tr</tt>,
  # then removes duplicate characters in regions that were affected by the
  # translation.
  #
  #    "hello".tr_s('l', 'r')     #=> "hero"
  #    "hello".tr_s('el', '*')    #=> "h*o"
  #    "hello".tr_s('el', 'hx')   #=> "hhxo"

#  def tr_s(arg1, arg2)
#  end

  ##
  # call-seq:
  #   str.tr_s!(from_str, to_str)   => str or nil
  #
  # Performs <tt>String#tr_s</tt> processing on <em>str</em> in place,
  # returning <em>str</em>, or <tt>nil</tt> if no changes were made.

#  def tr_s!(from_str, to_str)
#  end

  ##
  # call-seq:
  #   str.unpack(format)   => anArray
  #
  # Decodes <em>str</em> (which may contain binary data) according to the
  # format string, returning an array of each value extracted. The format
  # string consists of a sequence of single-character directives, summarized
  # in the table at the end of this entry. Each directive may be followed by
  # a number, indicating the number of times to repeat with this directive.
  # An asterisk (``<tt>*</tt>'') will use up all remaining elements. The
  # directives <tt>sSiIlL</tt> may each be followed by an underscore
  # (``<tt>_</tt>'') to use the underlying platform's native size for the
  # specified type; otherwise, it uses a platform-independent consistent
  # size. Spaces are ignored in the format string. See also
  # <tt>Array#pack</tt>.
  #
  #    "abc \0\0abc \0\0".unpack('A6Z6')   #=> ["abc", "abc "]
  #    "abc \0\0".unpack('a3a3')           #=> ["abc", " \000\000"]
  #    "abc \0abc \0".unpack('Z*Z*')       #=> ["abc ", "abc "]
  #    "aa".unpack('b8B8')                 #=> ["10000110", "01100001"]
  #    "aaa".unpack('h2H2c')               #=> ["16", "61", 97]
  #    "\xfe\xff\xfe\xff".unpack('sS')     #=> [-2, 65534]
  #    "now=20is".unpack('M*')             #=> ["now is"]
  #    "whole".unpack('xax2aX2aX1aX2a')    #=> ["h", "e", "l", "l", "o"]
  #
  # This table summarizes the various formats and the Ruby classes returned
  # by each.
  #
  #    Format | Returns | Function
  #    -------+---------+-----------------------------------------
  #      A    | String  | with trailing nulls and spaces removed
  #    -------+---------+-----------------------------------------
  #      a    | String  | string
  #    -------+---------+-----------------------------------------
  #      B    | String  | extract bits from each character (msb first)
  #    -------+---------+-----------------------------------------
  #      b    | String  | extract bits from each character (lsb first)
  #    -------+---------+-----------------------------------------
  #      C    | Fixnum  | extract a character as an unsigned integer
  #    -------+---------+-----------------------------------------
  #      c    | Fixnum  | extract a character as an integer
  #    -------+---------+-----------------------------------------
  #      d,D  | Float   | treat sizeof(double) characters as
  #           |         | a native double
  #    -------+---------+-----------------------------------------
  #      E    | Float   | treat sizeof(double) characters as
  #           |         | a double in little-endian byte order
  #    -------+---------+-----------------------------------------
  #      e    | Float   | treat sizeof(float) characters as
  #           |         | a float in little-endian byte order
  #    -------+---------+-----------------------------------------
  #      f,F  | Float   | treat sizeof(float) characters as
  #           |         | a native float
  #    -------+---------+-----------------------------------------
  #      G    | Float   | treat sizeof(double) characters as
  #           |         | a double in network byte order
  #    -------+---------+-----------------------------------------
  #      g    | Float   | treat sizeof(float) characters as a
  #           |         | float in network byte order
  #    -------+---------+-----------------------------------------
  #      H    | String  | extract hex nibbles from each character
  #           |         | (most significant first)
  #    -------+---------+-----------------------------------------
  #      h    | String  | extract hex nibbles from each character
  #           |         | (least significant first)
  #    -------+---------+-----------------------------------------
  #      I    | Integer | treat sizeof(int) (modified by _)
  #           |         | successive characters as an unsigned
  #           |         | native integer
  #    -------+---------+-----------------------------------------
  #      i    | Integer | treat sizeof(int) (modified by _)
  #           |         | successive characters as a signed
  #           |         | native integer
  #    -------+---------+-----------------------------------------
  #      L    | Integer | treat four (modified by _) successive
  #           |         | characters as an unsigned native
  #           |         | long integer
  #    -------+---------+-----------------------------------------
  #      l    | Integer | treat four (modified by _) successive
  #           |         | characters as a signed native
  #           |         | long integer
  #    -------+---------+-----------------------------------------
  #      M    | String  | quoted-printable
  #    -------+---------+-----------------------------------------
  #      m    | String  | base64-encoded
  #    -------+---------+-----------------------------------------
  #      N    | Integer | treat four characters as an unsigned
  #           |         | long in network byte order
  #    -------+---------+-----------------------------------------
  #      n    | Fixnum  | treat two characters as an unsigned
  #           |         | short in network byte order
  #    -------+---------+-----------------------------------------
  #      P    | String  | treat sizeof(char *) characters as a
  #           |         | pointer, and  return \emph{len} characters
  #           |         | from the referenced location
  #    -------+---------+-----------------------------------------
  #      p    | String  | treat sizeof(char *) characters as a
  #           |         | pointer to a  null-terminated string
  #    -------+---------+-----------------------------------------
  #      Q    | Integer | treat 8 characters as an unsigned
  #           |         | quad word (64 bits)
  #    -------+---------+-----------------------------------------
  #      q    | Integer | treat 8 characters as a signed
  #           |         | quad word (64 bits)
  #    -------+---------+-----------------------------------------
  #      S    | Fixnum  | treat two (different if _ used)
  #           |         | successive characters as an unsigned
  #           |         | short in native byte order
  #    -------+---------+-----------------------------------------
  #      s    | Fixnum  | Treat two (different if _ used)
  #           |         | successive characters as a signed short
  #           |         | in native byte order
  #    -------+---------+-----------------------------------------
  #      U    | Integer | UTF-8 characters as unsigned integers
  #    -------+---------+-----------------------------------------
  #      u    | String  | UU-encoded
  #    -------+---------+-----------------------------------------
  #      V    | Fixnum  | treat four characters as an unsigned
  #           |         | long in little-endian byte order
  #    -------+---------+-----------------------------------------
  #      v    | Fixnum  | treat two characters as an unsigned
  #           |         | short in little-endian byte order
  #    -------+---------+-----------------------------------------
  #      w    | Integer | BER-compressed integer (see Array.pack)
  #    -------+---------+-----------------------------------------
  #      X    | ---     | skip backward one character
  #    -------+---------+-----------------------------------------
  #      x    | ---     | skip forward one character
  #    -------+---------+-----------------------------------------
  #      Z    | String  | with trailing nulls removed
  #           |         | upto first null with *
  #    -------+---------+-----------------------------------------
  #      @    | ---     | skip to the offset given by the
  #           |         | length argument
  #    -------+---------+-----------------------------------------

#  def unpack(arg1)
#  end

  ##
  # call-seq:
  #   str.upcase   => new_str
  #
  # Returns a copy of <em>str</em> with all lowercase letters replaced with
  # their uppercase counterparts. The operation is locale insensitive---only
  # characters ``a'' to ``z'' are affected.
  #
  #    "hEllO".upcase   #=> "HELLO"

  def upcase
    new = dup
    new.upcase!
    return new
  end

  ##
  # call-seq:
  #   str.upcase!   => str or nil
  #
  # Upcases the contents of <em>str</em>, returning <tt>nil</tt> if no
  # changes were made.

  def upcase!
    modified = false

    0.upto(self.length - 1) do |i|
      cur = self[i].chr
      if islower cur then
        self[i] = toupper cur
        modified = true
      end
    end

    return modified ? self : nil
  end

  ##
  # call-seq:
  #   str.upto(other_str) {|s| block }   => str
  #
  # Iterates through successive values, starting at <em>str</em> and ending
  # at <em>other_str</em> inclusive, passing each value in turn to the
  # block. The <tt>String#succ</tt> method is used to generate each value.
  #
  #    "a8".upto("b6") {|s| print s, ' ' }
  #    for s in "a8".."b6"
  #      print s, ' '
  #    end
  #
  # <em>produces:</em>
  #
  #    a8 a9 b0 b1 b2 b3 b4 b5 b6
  #    a8 a9 b0 b1 b2 b3 b4 b5 b6

  def upto(last)
    cur = self.dup
    after_last = last.succ
    until cur == after_last do
      yield cur
      cur.succ!
    end
    return self
  end

  private

  def _index(substr, pos, substr_pos = 0)
    return -1 if self.length - pos < substr.length
    return offset if substr.length == 0
    pos.upto(self.length - 1) do |i|
      if self[i] == substr[substr_pos] then
        return _index(substr, pos + 1, substr_pos + 1)
      end
    end
  end

  def convert(object)
    unless object.respond_to? :to_str then
      raise TypeError, "cannot convert " + object.class.name + " into String"
    end
    return object.to_str
  end

  def isdigit(chr)
    chr = chr[0]
    return 48 <= chr && chr <= 57
  end

  def isalnum(chr)
    return isalpha(chr) || isdigit(chr)
  end

  def isalpha(chr)
    return isupper(chr) || islower(chr)
  end

  def islower(chr)
    chr = chr[0]
    return 97 <= chr && chr <= 122
  end

  def isupper(chr)
    chr = chr[0]
    return 65 <= chr && chr <= 90
  end

  def succ_char(new, i)
    c = new[i]
    if ?0 <= c and c < ?9 then
      new[i] = c + 1
    elsif c == ?9 then
      new[i] = ?0
      return '1'
    elsif ?a <= c && c < ?z then
      new[i] = c + 1
    elsif c == ?z then
      new[i] = ?a
      return ?a
    elsif ?A <= c && c < ?Z then
      new[i] = c + 1
    elsif c == ?Z then
      new[i] = ?A
      return ?A
    end
    return nil
  end

  def tolower(chr)
    if isupper chr then
      return (chr[0] + 32).chr
    else
      return chr
    end
  end

  def toupper(chr)
    if islower chr then
      return (chr[0] - 32).chr
    else
      return chr
    end
  end

end

puts 'DONE!'
