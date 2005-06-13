class Hash

  ##
  # call-seq:
  #   Hash[ [key =>|, value]* ]   => hash
  #
  # Creates a new hash populated with the given objects. Equivalent to the
  # literal <tt>{ <em>key</em>, <em>value</em>, ... }</tt>. Keys and values
  # occur in pairs, so there must be an even number of arguments.
  #
  #    Hash["a", 100, "b", 200]       #=> {"a"=>100, "b"=>200}
  #    Hash["a" => 100, "b" => 200]   #=> {"a"=>100, "b"=>200}
  #    { "a" => 100, "b" => 200 }     #=> {"a"=>100, "b"=>200}

  def self.[](*args)

#    p :self_brackets, args.size, args.first.size, args if caller.join(', ') =~ /fuck/

    return args if Hash === args
    if Array === args && args.size == 1 && Hash === args.first then
      return args.first # HACK? I have no idea
    end
    raise "horrid args #{args.inspect}" if args.size % 2 != 0
    h=Hash.new
    (0...args.size).step(2) do |i|
      h[args[i]] = args[i+1]
    end
    return h
  end

  ##
  # call-seq:
  #   Hash.new                          => hash
  #   Hash.new(obj)                     => aHash
  #   Hash.new {|hash, key| block }     => aHash
  #
  # Returns a new, empty hash. If this hash is subsequently accessed by a
  # key that doesn't correspond to a hash entry, the value returned depends
  # on the style of <tt>new</tt> used to create the hash. In the first form,
  # the access returns <tt>nil</tt>. If <em>obj</em> is specified, this
  # single object will be used for all <em>default values</em>. If a block
  # is specified, it will be called with the hash object and the key, and
  # should return the default value. It is the block's responsibility to
  # store the value in the hash if required.
  #
  #    h = Hash.new("Go Fish")
  #    h["a"] = 100
  #    h["b"] = 200
  #    h["a"]           #=> 100
  #    h["c"]           #=> "Go Fish"
  #    # The following alters the single default object
  #    h["c"].upcase!   #=> "GO FISH"
  #    h["d"]           #=> "GO FISH"
  #    h.keys           #=> ["a", "b"]
  #    # While this creates a new default object each time
  #    h = Hash.new { |hash, key| hash[key] = "Go Fish: #{key}" }
  #    h["c"]           #=> "Go Fish: c"
  #    h["c"].upcase!   #=> "GO FISH: C"
  #    h["d"]           #=> "Go Fish: d"
  #    h.keys           #=> ["c", "d"]

  def initialize(default=nil, &block)
    raise ArgumentError, "Can't specify both a default value & block" unless
      default.nil? or block.nil?
    @def = block unless block.nil?
    @def = default unless defined? @def
  end

  def _key
    @key = [] unless defined? @key
    @key
  end

  def _val
    @val = [] unless defined? @val
    @val
  end

  def _def
    @def = nil unless defined? @def
    @def
  end

  private :_key, :_val, :_def

  ##
  # call-seq:
  #   hsh == other_hash    => true or false
  #
  # Equality---Two hashes are equal if they each contain the same number of
  # keys and if each key-value pair is equal to (according to
  # <tt>Object#==</tt>) the corresponding elements in the other hash.
  #
  #    h1 = { "a" => 1, "c" => 2 }
  #    h2 = { 7 => 35, "c" => 2, "a" => 1 }
  #    h3 = { "a" => 1, "c" => 2, 7 => 35 }
  #    h4 = { "a" => 1, "d" => 2, "f" => 35 }
  #    h1 == h2   #=> false
  #    h2 == h3   #=> true
  #    h3 == h4   #=> false

  def ==(other)
    return false unless Hash === other && self.size == other.size
    self.each do |k,v|
      return false unless other.has_key? k
      return false unless other[k] == self[k]
    end
    return true
  end

  ##
  # call-seq:
  #   hsh[key]    =>  value
  #
  # Element Reference---Retrieves the <em>value</em> object corresponding to
  # the <em>key</em> object. If not found, returns the a default value (see
  # <tt>Hash::new</tt> for details).
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h["a"]   #=> 100
  #    h["c"]   #=> nil

  def [](k)
    index = _key.index(k)
    if index.nil?
      d = _def
      return d.call(self,k) if Proc === d
      return d
    end
    return _val[index]
  end

  ##
  # call-seq:
  #   hsh[key] = value        => value
  #   hsh.store(key, value)   => value
  #
  # Element Assignment---Associates the value given by <em>value</em> with
  # the key given by <em>key</em>. <em>key</em> should not have its value
  # changed while it is in use as a key (a <tt>String</tt> passed as a key
  # will be duplicated and frozen).
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h["a"] = 9
  #    h["c"] = 4
  #    h   #=> {"a"=>9, "b"=>200, "c"=>4}

  def []=(k, v)
    index = _key.index(k)
    if index.nil?
      _key << k
      _val << v
    else
      _val[index] = v
    end
    return v
  end
  alias_method :store, :[]=

  ##
  # call-seq:
  #   hsh.clear -> hsh
  #
  # Removes all key-value pairs from <em>hsh</em>.
  #
  #    h = { "a" => 100, "b" => 200 }   #=> {"a"=>100, "b"=>200}
  #    h.clear                          #=> {}

  def clear
    _key
    _val
    @key = []
    @val = []
  end

  def clone
    h = self.dup
    h.freeze if self.frozen?
    return h
  end

  ##
  # call-seq:
  #   hsh.default(key=nil)   => obj
  #
  # Returns the default value, the value that would be returned by
  # <em>hsh</em>[<em>key</em>] if <em>key</em> did not exist in
  # <em>hsh</em>. See also <tt>Hash::new</tt> and <tt>Hash#default=</tt>.
  #
  #    h = Hash.new                            #=> {}
  #    h.default                               #=> nil
  #    h.default(2)                            #=> nil
  #    h = Hash.new("cat")                     #=> {}
  #    h.default                               #=> "cat"
  #    h.default(2)                            #=> "cat"
  #    h = Hash.new {|h,k| h[k] = k.to_i*10}   #=> {}
  #    h.default                               #=> 0
  #    h.default(2)                            #=> 20

  def default(key=nil) # HACK this should fail tests
    d = _def
    d = d.call(key) if Proc === d
    return d
  end

  ##
  # call-seq:
  #   hsh.default = obj     => hsh
  #
  # Sets the default value, the value returned for a key that does not exist
  # in the hash. It is not possible to set the a default to a <tt>Proc</tt>
  # that will be executed on each key lookup.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.default = "Go fish"
  #    h["a"]     #=> 100
  #    h["z"]     #=> "Go fish"
  #    # This doesn't do what you might hope...
  #    h.default = proc do |hash, key|
  #      hash[key] = key + key
  #    end
  #    h[2]       #=> #<Proc:0x401b3948@-:6>
  #    h["cat"]   #=> #<Proc:0x401b3948@-:6>

  def default=(d)
    @def = d
    return self
  end

  ##
  # call-seq:
  #   hsh.default_proc -> anObject
  #
  # If <tt>Hash::new</tt> was invoked with a block, return that block,
  # otherwise return <tt>nil</tt>.
  #
  #    h = Hash.new {|h,k| h[k] = k*k }   #=> {}
  #    p = h.default_proc                 #=> #<Proc:0x401b3d08@-:1>
  #    a = []                             #=> []
  #    p.call(a, 2)
  #    a                                  #=> [nil, nil, 4]

  def default_proc
    d = _def
    return Proc === d ? d : nil
  end

  ##
  # call-seq:
  #   hsh.delete(key)                   => value
  #   hsh.delete(key) {| key | block }  => value
  #
  # Deletes and returns a key-value pair from <em>hsh</em> whose key is
  # equal to <em>key</em>. If the key is not found, returns the <em>default
  # value</em>. If the optional code block is given and the key is not
  # found, pass in the key and return the result of <em>block</em>.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.delete("a")                              #=> 100
  #    h.delete("z")                              #=> nil
  #    h.delete("z") { |el| "#{el} not found" }   #=> "z not found"

  def delete(k, &b)
    index = _key.index(k)
    unless index.nil?
      _key.delete_at(index)
      return _val.delete_at(index)
    else
      if b.nil?
        return default(k)
      else
        return b.call(k)
      end
    end
  end

  ##
  # call-seq:
  #   hsh.delete_if {| key, value | block }  -> hsh
  #
  # Deletes every key-value pair from <em>hsh</em> for which <em>block</em>
  # evaluates to <tt>true</tt>.
  #
  #    h = { "a" => 100, "b" => 200, "c" => 300 }
  #    h.delete_if {|key, value| key >= "b" }   #=> {"a"=>100}

  def delete_if(&b)
    keys = _key.dup
    keys.each do |k|
      v = self[k]
      delete(k) if b.call(k,v)
    end
    return self
  end

  ##
  # DOC

  def dup
    h = self.class.new
    self.each do |k,v|
      h[k] = v
    end
    h.taint if self.tainted?
    return h
  end

  ##
  # call-seq:
  #   hsh.each {| key, value | block } -> hsh
  #
  # Calls <em>block</em> once for each key in <em>hsh</em>, passing the key
  # and value to the block as a two-element array. Because of the assignment
  # semantics of block parameters, these elements will be split out if the
  # block has two formal parameters. Also see <tt>Hash.each_pair</tt>, which
  # will be marginally more efficient for blocks with two parameters.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.each {|key, value| puts "#{key} is #{value}" }
  #
  # <em>produces:</em>
  #
  #    a is 100
  #    b is 200

  def each
    keys = _key.dup
    keys.each do |k|
      v = self[k]
      yield(k,v)
    end
    return self
  end

  ##
  # call-seq:
  #   hsh.each_key {| key | block } -> hsh
  #
  # Calls <em>block</em> once for each key in <em>hsh</em>, passing the key
  # as a parameter.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.each_key {|key| puts key }
  #
  # <em>produces:</em>
  #
  #    a
  #    b

  def each_key
    _key.dup.each { |k| yield(k) }
    return self
  end

  ##
  # call-seq:
  #   hsh.each_pair {| key_value_array | block } -> hsh
  #
  # Calls <em>block</em> once for each key in <em>hsh</em>, passing the key
  # and value as parameters.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.each_pair {|key, value| puts "#{key} is #{value}" }
  #
  # <em>produces:</em>
  #
  #    a is 100
  #    b is 200

  def each_pair
    keys = _key.dup
    keys.each do |k|
      v = self[k]
      yield(k,v)
    end
    return self
  end

  ##
  # call-seq:
  #   hsh.each_value {| value | block } -> hsh
  #
  # Calls <em>block</em> once for each key in <em>hsh</em>, passing the
  # value as a parameter.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.each_value {|value| puts value }
  #
  # <em>produces:</em>
  #
  #    100
  #    200

  def each_value
    _val.each { |v| yield(v) }
  end

  ##
  # call-seq:
  #   hsh.empty?    => true or false
  #
  # Returns <tt>true</tt> if <em>hsh</em> contains no key-value pairs.
  #
  #    {}.empty?   #=> true

  def empty?
    _key.empty?
  end

  ##
  # call-seq:
  #   hsh.fetch(key [, default] )       => obj
  #   hsh.fetch(key) {| key | block }   => obj
  #
  # Returns a value from the hash for the given key. If the key can't be
  # found, there are several options: With no other arguments, it will raise
  # an <tt>IndexError</tt> exception; if <em>default</em> is given, then
  # that will be returned; if the optional code block is specified, then
  # that will be run and its result returned.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.fetch("a")                            #=> 100
  #    h.fetch("z", "go fish")                 #=> "go fish"
  #    h.fetch("z") { |el| "go fish, #{el}"}   #=> "go fish, z"
  #
  # The following example shows that an exception is raised if the key is
  # not found and a default value is not supplied.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.fetch("z")
  #
  # <em>produces:</em>
  #
  #    prog.rb:2:in `fetch': key not found (IndexError)
  #     from prog.rb:2

  def fetch(key, default=nil, &block)
    raise ArgumentError, "Can't specify both a default value & block" unless
      default.nil? or block.nil?
    if include? key then
      return self[key]
    else
      if default.nil? and block.nil? then
        raise IndexError, "key not found"
      elsif block then
        return block.call(key)
      else
        return default
      end
    end
  end

  ##
  # call-seq:
  #   hsh.has_key?(key)    => true or false
  #   hsh.include?(key)    => true or false
  #   hsh.key?(key)        => true or false
  #   hsh.member?(key)     => true or false
  #
  # Returns <tt>true</tt> if the given key is present in <em>hsh</em>.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.has_key?("a")   #=> true
  #    h.has_key?("z")   #=> false

  def has_key?(k)
    return ! _key.index(k).nil?
  end
  alias_method :include?, :has_key?
  alias_method :key?, :has_key?
  alias_method :member?, :has_key?

  ##
  # call-seq:
  #   hsh.has_value?(value)    => true or false
  #   hsh.value?(value)        => true or false
  #
  # Returns <tt>true</tt> if the given value is present for some key in
  # <em>hsh</em>.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.has_value?(100)   #=> true
  #    h.has_value?(999)   #=> false

  def has_value?(v)
    return ! _val.index(v).nil?
  end
  alias_method :value?, :has_value?

  ##
  # call-seq:
  #   hsh.index(value)    => key
  #
  # Returns the key for a given value. If not found, returns <tt>nil</tt>.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.index(200)   #=> "b"
  #    h.index(999)   #=> nil

  def index(v)
    i = _val.index(v)
    return nil if i.nil?
    return _key[i]
  end

  ##
  # call-seq:
  #   hsh.indexes(key, ...)    => array
  #   hsh.indices(key, ...)    => array
  #
  # Deprecated in favor of <tt>Hash#select</tt>.

  def indexes(*keys)
    r = []
    keys.each do |key|
      if has_key? key then
        r << self[key]
      else
        r << self.default
      end
    end
    return r
  end
  alias_method :indices, :indexes

  ##
  # call-seq:
  #   hsh.inspect  => string
  #
  # Return the contents of this hash as a string.

  def inspect
    result = []
    self.each do |k,v|
      r = []
      r << k.inspect
      r << '=>'
      r << v.inspect
      result << r.join()
    end
    return "{" + result.join(', ') + "}"
  end

  ##
  # call-seq:
  #   hsh.invert -> aHash
  #
  # Returns a new hash created by using <em>hsh</em>'s values as keys, and
  # the keys as values.
  #
  #    h = { "n" => 100, "m" => 100, "y" => 300, "d" => 200, "a" => 0 }
  #    h.invert   #=> {0=>"a", 100=>"n", 200=>"d", 300=>"y"}

  def invert
    r = self.class.new
    self.each do |k,v|
      r[v] = k
    end
    return r
  end

  ##
  # call-seq:
  #   hsh.keys    => array
  #
  # Returns a new array populated with the keys from this hash. See also
  # <tt>Hash#values</tt>.
  #
  #    h = { "a" => 100, "b" => 200, "c" => 300, "d" => 400 }
  #    h.keys   #=> ["a", "b", "c", "d"]

  def keys
    _key
  end

  ##
  # call-seq:
  #   hsh.merge(other_hash)                              -> a_hash
  #   hsh.merge(other_hash){|key, oldval, newval| block} -> a_hash
  #
  # Returns a new hash containing the contents of <em>other_hash</em> and
  # the contents of <em>hsh</em>, overwriting entries in <em>hsh</em> with
  # duplicate keys with those from <em>other_hash</em>.
  #
  #    h1 = { "a" => 100, "b" => 200 }
  #    h2 = { "b" => 254, "c" => 300 }
  #    h1.merge(h2)   #=> {"a"=>100, "b"=>254, "c"=>300}
  #    h1             #=> {"a"=>100, "b"=>200}

  def merge(other)
    self.dup.update(other)
  end

  ##
  # call-seq:
  #   hsh.rehash -> hsh
  #
  # Rebuilds the hash based on the current hash values for each key. If
  # values of key objects have changed since they were inserted, this method
  # will reindex <em>hsh</em>. If <tt>Hash#rehash</tt> is called while an
  # iterator is traversing the hash, an <tt>IndexError</tt> will be raised
  # in the iterator.
  #
  #    a = [ "a", "b" ]
  #    c = [ "c", "d" ]
  #    h = { a => 100, c => 300 }
  #    h[a]       #=> 100
  #    a[0] = "z"
  #    h[a]       #=> nil
  #    h.rehash   #=> {["z", "b"]=>100, ["c", "d"]=>300}
  #    h[a]       #=> 100

  def rehash
    # nothing to do ?
  end

  ##
  # call-seq:
  #   hsh.reject! {| key, value | block }  -> hsh or nil
  #
  # Equivalent to <tt>Hash#delete_if</tt>, but returns <tt>nil</tt> if no
  # changes were made.

  def reject!(&block)
    size = _key.size
    delete_if(&block)
    if _key.size == size then
      return nil
    else
      return self
    end
  end

  ##
  # call-seq:
  #   hsh.reject {| key, value | block }  -> a_hash
  #
  # Same as <tt>Hash#delete_if</tt>, but works on (and returns) a copy of
  # the <em>hsh</em>. Equivalent to <tt><em>hsh</em>.dup.delete_if</tt>.

  def reject(&b)
    self.dup.delete_if(&b)
  end

  ##
  # call-seq:
  #   hsh.replace(other_hash) -> hsh
  #
  # Replaces the contents of <em>hsh</em> with the contents of
  # <em>other_hash</em>.
  #
  #    h = { "a" => 100, "b" => 200 }
  #    h.replace({ "c" => 300, "d" => 400 })   #=> {"c"=>300, "d"=>400}

  def replace(other)
    self.clear
    self.merge!(other)
    return self
  end

  ##
  # call-seq:
  #   hsh.select {|key, value| block}   => array
  #
  # Returns a new array consisting of <tt>[key,value]</tt> pairs for which
  # the block returns true. Also see <tt>Hash.values_at</tt>.
  #
  #    h = { "a" => 100, "b" => 200, "c" => 300 }
  #    h.select {|k,v| k > "a"}  #=> [["b", 200], ["c", 300]]
  #    h.select {|k,v| v < 200}  #=> [["a", 100]]

  def select(*args, &b)
    raise ArgumentError, "whaa? #{args.inspect}" if args.size > 0
    r = []
    each do |k,v|
      r << [k,v] if b.call(k,v)
    end
    return r
  end

  ##
  # call-seq:
  #   hsh.shift -> anArray or obj
  #
  # Removes a key-value pair from <em>hsh</em> and returns it as the
  # two-item array <tt>[</tt> <em>key, value</em> <tt>]</tt>, or the hash's
  # default value if the hash is empty.
  #
  #    h = { 1 => "a", 2 => "b", 3 => "c" }
  #    h.shift   #=> [1, "a"]
  #    h         #=> {2=>"b", 3=>"c"}

  def shift
    return [_key.shift, _val.shift]
  end

  ##
  # call-seq:
  #   hsh.length    =>  fixnum
  #   hsh.size      =>  fixnum
  #
  # Returns the number of key-value pairs in the hash.
  #
  #    h = { "d" => 100, "a" => 200, "v" => 300, "e" => 400 }
  #    h.length        #=> 4
  #    h.delete("a")   #=> 200
  #    h.length        #=> 3

  def size
    return _key.size
  end
  alias_method :length, :size

  ##
  # call-seq:
  #   hsh.sort                    => array 
  #   hsh.sort {| a, b | block }  => array 
  #
  # Converts <em>hsh</em> to a nested array of <tt>[</tt> <em>key,
  # value</em> <tt>]</tt> arrays and sorts it, using <tt>Array#sort</tt>.
  #
  #    h = { "a" => 20, "b" => 30, "c" => 10  }
  #    h.sort                       #=> [["a", 20], ["b", 30], ["c", 10]]
  #    h.sort {|a,b| a[1]<=>b[1]}   #=> [["c", 10], ["a", 20], ["b", 30]]

  def sort(&sort_block)
    unless sort_block.nil? then
      keys = _key.sort(&sort_block)
    else
      keys = _key.sort
    end
    keys.map { |k| [k, self[k]] }
  end

  ##
  # call-seq:
  #   hsh.to_a -> array
  #
  # Converts <em>hsh</em> to a nested array of <tt>[</tt> <em>key,
  # value</em> <tt>]</tt> arrays.
  #
  #    h = { "c" => 300, "a" => 100, "d" => 400, "c" => 300  }
  #    h.to_a   #=> [["a", 100], ["c", 300], ["d", 400]]

  def to_a
    a = []
    self.each do |k,v|
      a << [k,v]
    end
    return a
  end

  ##
  # call-seq:
  #   hsh.to_hash   => hsh
  #
  # Returns <em>self</em>.

  def to_hash
    return self
  end

  ##
  # call-seq:
  #   hsh.to_s   => string
  #
  # Converts <em>hsh</em> to a string by converting the hash to an array of
  # <tt>[</tt> <em>key, value</em> <tt>]</tt> pairs and then converting that
  # array to a string using <tt>Array#join</tt> with the default separator.
  #
  #    h = { "c" => 300, "a" => 100, "d" => 400, "c" => 300  }
  #    h.to_s   #=> "a100c300d400"

  def to_s
    _key.zip(_val).join
  end

  ##
  # call-seq:
  #   hsh.merge!(other_hash)                                 => hsh
  #   hsh.update(other_hash)                                 => hsh
  #   hsh.merge!(other_hash){|key, oldval, newval| block}    => hsh
  #   hsh.update(other_hash){|key, oldval, newval| block}    => hsh
  #
  # Adds the contents of <em>other_hash</em> to <em>hsh</em>, overwriting
  # entries with duplicate keys with those from <em>other_hash</em>.
  #
  #    h1 = { "a" => 100, "b" => 200 }
  #    h2 = { "b" => 254, "c" => 300 }
  #    h1.merge!(h2)   #=> {"a"=>100, "b"=>254, "c"=>300}

  def update(other)
    other.each do |k,v|
      self[k] = v
    end
    return self
  end
  alias_method :merge!, :update

  ##
  # call-seq:
  #   hsh.values    => array
  #
  # Returns a new array populated with the values from <em>hsh</em>. See
  # also <tt>Hash#keys</tt>.
  #
  #    h = { "a" => 100, "b" => 200, "c" => 300 }
  #    h.values   #=> [100, 200, 300]

  def values
    _val
  end

  ##
  # call-seq:
  #   hsh.values_at(key, ...)   => array
  #
  # Return an array containing the values associated with the given keys.
  # Also see <tt>Hash.select</tt>.
  #
  #   h = { "cat" => "feline", "dog" => "canine", "cow" => "bovine" }
  #   h.values_at("cow", "cat")  #=> ["bovine", "feline"]

  def values_at(*keys)
    keys.map { |key| self[key] }
  end
end
