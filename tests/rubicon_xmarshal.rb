=begin
= XMarshal
XMarshal means 'XML Marshal'.  Objects can be stored as and restored
from well-formed XML document.

Advantage over standard Marshal:
* Easily read and modified by text editor.
* Dumped data can be used from non-ruby application.

== Usage
 require 'xmarshal'

If the constant XMARSHAL_DUMP_ONLY is set before the require is
invoked, then only the dumping part of XMarshal will be defined. This
has the advantage of not requiring 'xmlparser', and hence will run
on a wider variety of platforms out of the box. 

==== For Japanese Users

XMarshal default encoding is UTF8 because of performance issue.  If
'Uconv' is defined, XMarshal automatically configures itself to handle
Japanese encoding.  Input can be EUC, SJIS or ISO-2022-JP and output
encoding is determined by $KCODE.  So if Japanese processing needed,
require as follows:

 require 'uconv'
 require 'xmarshal'

== class XMarshal
=== Class Methods

:dump(obj [,port])
  Dump obj to port.  Returns the resulting string if port is omitted.

:load(port)
  Load object from port.

== Limitation

* User defined classes must define initialize() without argument
  (or all arguments can be omitted.)
* Marshaling following classes is not implemented yet.
 * Hash with keys other than String
 * Module, Class
 * Range, Regexp, Struct
* Following classes cannot be dumped:
 * Dir, IO, File, Proc
* Time#isdst (daylight saving time) is lost during marshaling.
* Objects refereced from more than two places are dumped repeatedly.

== Author
Masaki Fukushima <fukusima@goto.info.waseda.ac.jp>

=end

class Xconv
  DUMP_ONLY = defined? XMARSHAL_DUMP_ONLY
end

require 'xmlparser' unless Xconv::DUMP_ONLY
require 'date'

# XMarshal needs access to instance variables
class Object
  def __iv_get(name)
    raise "invalid ivar name #{name}" if name !~ /^@\w+$/
    eval name
  end

  def __iv_set(name, val)
    raise "invalid ivar name #{name}" if name !~ /^@\w+$/
    eval "#{name} = val"
  end
end

class XconvError < Exception; end
class Xconv

  INDENT = 2

  attr_accessor :parser

  private

  def initialize(parser_class = nil)
    @parser = (parser_class ? parser_class : $XMLParser)
  end

  PREDEFINED = /[<>&'"]/  # ' avoid confusing ruby-mode.el
  def xml_escape(str)
    str = str.dup
    str.gsub!("&", "&amp;")
    str.gsub!("<", "&lt;")
    str.gsub!(">", "&gt;")
    str.gsub!("'", "&apos;")
    str.gsub!('"', "&quot;")
    str
  end

  def encoding
    $KCODE_TO_XMLENC[$KCODE]
  end

  def xml_decl(enc = encoding)
    %(<?xml version="1.0" encoding="#{enc}"?>\n)
  end
  public

  def dump(obj, port = '')
    port << xml_decl
    obj2elem(obj, port, 0)
  end

  def obj2elem(obj, port = '', indent = 0, name = nil, ahash = nil)
    if $DEBUG and $VERBOSE
      puts "dump #{obj.inspect}" if indent == 0
      puts '  '*indent + [obj, name, ahash].inspect
    end

    # start element
    ahash = {} unless ahash
    name, ahash, empty = start_object(obj, name, ahash)
    raise XconvError, 'no element name' unless name
    attrs = ''
    if ahash
      ahash.each {|k, v|
        v = xml_escape(v) if v =~ PREDEFINED
        attrs << " #{k}=\"#{v}\""
      }
    end
    port << ' ' * indent
    port << "<#{name}#{attrs}"
    if empty
      port << "/>\n"
      return port
    else
      port << '>'
    end

    # encode contents of this object
    dump_contents(obj, port, indent)

    # end element
    port << "</#{name}>\n"
    return port
  end

  def start_object(obj, name, ahash)
    unless name
      case obj
      when Integer
        name = 'Integer'
      else
        name = obj.type.name
      end
    end
    [name, ahash, false]
  end

  def dump_contents(obj, port, indent)
    case obj
    when true, false, nil
      port << obj.inspect
    when String
      str = obj
      str = xml_escape(str) if str =~ PREDEFINED
      port << str
    when Integer
      port << obj.to_s
    when Float
      port << format('%-.15g', obj)
    when Time
      s = obj.strftime('%Y-%m-%d %H:%M:%S')
      if obj.tv_usec != 0
        s << format('.%.6d', obj.tv_usec)
      end
      s << ' GMT' if obj.zone == 'GMT'
      port << s
    when Date
      port << format('%.4d-%.2d-%.2d', obj.year, obj.month, obj.day)
    when Array
      port << "\n"
      obj.each {|child|
        obj2elem(child, port, indent+INDENT, nil, nil)
      }
      port << ' ' * indent
    when Hash
      port << "\n"
      if obj.default != nil
        obj2elem(obj.default, port, indent+INDENT, 'default', nil)
      end
      keys = obj.keys
      begin
        keys.sort!
      rescue TypeError
        raise XconvError, 'hash key must be string'
      end
      keys.each {|key|
        raise XconvError, 'hash key must be string' unless key.is_a? String
        child = obj[key]
        obj2elem(child, port, indent+INDENT, nil, {'key'=>key})
      }
      port << ' ' * indent
    when Module
      raise XconvError, 'cannot dump Module/Class'
    else
      port << "\n"
      ivs = obj.instance_variables
      raise XconvError, "cannot dump #{obj.inspect}" unless ivs
      ivs.sort.each {|ivname|
        child = obj.__iv_get ivname
        ivname.sub!(/^@/, '')
        ivar2elem(obj, ivname, child, port, indent+INDENT)
      }
      port << ' ' * indent
    end
  end

  def ivar2elem(parent, name, obj, port, indent)
    obj2elem(obj, port, indent, name, nil)
  end
end

#
# This part of the class is only created if XMARSHAL_DUMP_ONLY is not set
#

class Xconv
  def load(port)
    xml2obj(port)
  end

  def xml2obj(port, parser = @parser.new)
    begin
      puts "load from #{port.inspect}" if $DEBUG and $VERBOSE
      stack = nil
      target = nil
      parser.parse(port) do |type, name, data|
        puts "#{type} #{name.inspect} #{data.inspect}" if $DEBUG and $VERBOSE
        case type
        when XMLParser::START_ELEM
          if stack == nil
            # root element start
            stack = []
          elsif stack.frozen?
            raise XconvError, 'multiple root element?'
          end
          # push name, klass, object and attributes
          aname, klass, obj = start_elem(name, data, stack)
          stack.push [aname, klass, obj, data, '']

        when XMLParser::END_ELEM
          # pop object and set it to parent object
          aname, klass, obj, attrs, str = stack.pop
          obj = str2obj(klass, obj, str)

          if stack.empty?
            stack.freeze
            target = end_elem(aname, klass, obj, attrs, nil, stack)
            next
          else
            parent = stack[-1][2]
            end_elem(aname, klass, obj, attrs, parent, stack)
          end

        when XMLParser::CDATA
          next if stack.empty?
          aname, klass, obj, attrs, str = stack[-1]
          str << data
        else
          #raise XconvError, 'unsupported type'
        end
        p stack if $DEBUG and $VERBOSE
      end
      raise XconvError, 'no object' unless stack.frozen?
      return target
    rescue XconvError, XMLParserError
      # add current parser position
      raise $!.type,
        "#{parser.line}:#{parser.column} #{$!.message}",
        $!.backtrace
    end
  end

  CONST_PATT = /^[A-Z]\w*(::[A-Z]\w*)?$/
  def class_by_name(name)
    raise XconvError, "invalid class name #{name}" if name !~ CONST_PATT
    eval name
  end

  SIMPLES = [String, Integer, Float, Time, Date]
  def start_elem(name, data, stack)
    klass = class_by_name(name)

    if SIMPLES.include? klass
      obj = ''
    else
      begin
        obj = klass.new()
      rescue ArgumentError
        raise XconvError, "#{klass.name}.new() cause error.  " +
          "User defined class must define initialize() without argument." +
          " <#{$!.message}>"
      end
    end
    [name, klass, obj]
  end

  def end_elem(name, klass, obj, data, parent, stack)
    return obj if parent == nil

    case parent
    when Array
      parent << obj
    when Hash
      case name
      when 'default'
        parent.default = obj
      else
        raise XconvError, 'no hash key' unless data.has_key?('key')
        parent[data['key']] = obj
      end
    when String
      raise XconvError, 'String cannot have child element'
    else
      parent.__iv_set("@#{name}", obj)
    end
  end

  def str2obj(klass, obj, data)
    return obj unless SIMPLES.include? klass

    if klass == String
      obj = String(data)
    elsif klass == Integer
      obj = Integer(data)
    elsif klass == Float
      obj = Float(data)
    elsif klass == Time
      require 'parsedate'
      tz_local = true
      usec = nil
      if data =~ /(\.\d\d\d\d\d\d)?( GMT)?$/o
        tz_local = false if $2
        usec = $1[1..-1].to_i if $1
        data = $`
      end
      if tz_local
        obj = Time.local *(ParseDate.parsedate(data)[0,6])
      else
        obj = Time.gm *(ParseDate.parsedate(data)[0,6])
      end
      if usec
        obj = Time.at(obj.tv_sec + usec * 1e-6)
        d = obj.tv_usec - usec
        if d != 0  # correct float round error
          if d < 0
            low = 0.0; hi = d * -2.0
          else
            low = d * -2.0; hi = 0.0
          end
          while d != 0
            mid = (low + hi) / 2.0
            obj = Time.at(obj.tv_sec + ((usec + mid) * 1e-6))
            d = obj.tv_usec - usec
            if d > 0
              hi = mid
            else
              low = mid
            end
          end
        end
      end
    elsif klass == Date
      require 'parsedate'
      obj = Date.new *(ParseDate.parsedate(data)[0,3])
    else
      raise XconvError, "unknown type #{klass}"
    end
    return obj
  end
end unless Xconv::DUMP_ONLY


class XMarshal < Xconv
  class << self
    private
    def inst
      @inst = self.new unless defined? @inst
      @inst
    end

    public
    def dump(*a);      inst.dump(*a);      end
    def load(*a);      inst.load(*a);      end
    def dump_root(*a); inst.dump_root(*a); end
    def load_root(*a); inst.load_root(*a); end
  end

  # dummy root node
  class Root
    attr_reader :object
    def object=(obj)
      raise XconvError, 'multiple toplevel object' if defined? @object
      @object = obj
    end
    def inspect
      if defined? @object
        "ROOT(#{@object.inspect})"
      else
        'ROOT'
      end
    end
    alias to_s inspect
  end

  def dump(obj, port = '', direct = false)
    if direct
      super(obj, port)
    else
      root = Root.new
      root.object = obj
      super(root, port)
    end
  end

  def dump_root(obj, port = '')
    dump(obj, port, true)
  end

  def start_object(obj, name, ahash)
    case obj
    when true, false, nil
      if name
        return [name, {'value' => obj.inspect}, true]
      else
        return [obj.inspect, nil, true]
      end
    when Root
      ahash['version'] = 1.0
      klass = 'RubyObject'
    when Integer # don't distinguish Fixnum and Bignum
      klass = 'Integer'
    else
      klass = obj.type.name
    end

    if name
      ahash['type'] = klass unless obj.is_a? String
    else
      name = klass
    end

    [name, ahash, false]
  end

  def dump_contents(obj, port, indent)
    case obj
    when Root
      port << "\n"
      obj2elem(obj.object, port, indent+INDENT, nil, nil)
      port << ' ' * indent
    else
      super
    end
  end
end

# Again, this part of the class will only be created 
# in XMARSHAL_DUMP_ONLY is not set

class XMarshal
  def load(port, direct = false)
    if direct
      super(port)
    else
      root = super(port)
      raise XconvError, 'no RubyObject' unless root.is_a? Root
      return root.object
    end
  end

  def load_root(port)
    load(port, true)
  end

  def start_elem(name, data, stack)
    if stack.empty? and name == 'RubyObject'
      version = data['version']
      raise XconvError, "unknown version #{version}" if version != '1.0'
      root = Root.new
      return [name, nil, root]
    end

    case name
    when 'true', 'false', 'nil'
      return [nil, nil, eval(name)]
    end

    value = data['value']
    case value
    when 'true', 'false', 'nil'
      return [name, nil, eval(value)]
    end

    type = data['type']
    unless type
      case name
      when /^[A-Z]/
        type = name
        name = nil
      else
        type = 'String'
      end
    end
    result = super(type, data, stack)
    result[0] = name
    result
  end

  def end_elem(name, klass, obj, data, parent, stack)
    case parent
    when Root
      parent.object = obj
    else
      super
    end
  end

end unless Xconv::DUMP_ONLY


# The loader does not get created in DUMP_ONLY environments

class XMLoader < Xconv
  require 'ostruct'
  class Element < OpenStruct
    def initialize
      super()
      @name = self.type.name
      @attr = {}
    end

    def [](k)
      @attr[k]
    end

    def []=(k,v)
      @attr[k] = v
    end

    def inspect
      str = "<#{@name}"
      for k,v in @attr
        str << " #{k}=#{v.inspect}"
      end
      for k,v in @table
        case v
        when Element
          str << ' ' << v.inspect
        else
          str << " <#{k} #{v.inspect}>"
        end
      end
      str << ">"
      str
    end

    def __name=(n); @name = n; end
    def __table; @table; end
    def __attr;  @attr; end
  end

  def class_by_name(name)
    Element
  end

  def start_elem(name, data, stack)
    result = super
    obj = result[2]
    obj.__name = name
    if data
      data.each {|k,v| obj[k] = v}
    end
    result
  end

  def end_elem(name, klass, obj, data, parent, stack)
    if parent
      if parent.__table.has_key? name
        a = parent.__table[name]
        case a
        when Array
          a << obj
        else
          parent.send "#{name}=", [a, obj]
        end
      else
        parent.send "#{name}=", obj
      end
    end
    obj
  end

  def str2obj(klass, obj, str)
    if obj.__table.size == 0
      obj = str
    end
    obj
  end
end unless Xconv::DUMP_ONLY

# utility class for Japanese encoding
class XMLParser_ja < XMLParser
  def parse(xml)
    require 'nkf'
    require 'uconv'

    case xml
    when String
      xml = xml.dup
    else
      xml = xml.read
    end

    # input encoding to UTF-8
    if xml =~ /^<\?xml\s+version=.+\s+encoding=['"]([\w\-]+)["']/i
      enc = $1
      case enc
      when /EUC-JP/i     ; opt = '-Ee'
      when /Shift_JIS/i  ; opt = '-Se'
      when /ISO-2022-JP/i; opt = '-Je'
      else               ; opt = nil
      end

      if opt
        xml = Uconv.euctou8(NKF::nkf(opt, xml))
        xml.sub!(enc, 'UTF-8')
      end
    end

    # UTF-8 to internal encoding
    case $KCODE
    when 'EUC';  opt = '-Ee'
    when 'SJIS'; opt = '-Es'
    else;        opt = nil
    end

    if iterator?
      super(xml) do |type, name, data|
        if opt and data
          case data
          when String
            data = NKF::nkf(opt, Uconv.u8toeuc(data))
          when Hash
            hash = {}
            data.each {|k,v|
              k = NKF::nkf(opt, Uconv.u8toeuc(k)) if k
              v = NKF::nkf(opt, Uconv.u8toeuc(v)) if v
              hash[k] = v
            }
            data = hash
          when Array
            data = data.collect {|v|
              v = NKF::nkf(opt, Uconv.u8toeuc(v)) if v
              v
            }
          else
            raise 'unknown data'
          end
        end
        yield type, name, data
      end
    else
      # FIXME
      super(xml)
    end
  end
end unless Xconv::DUMP_ONLY

if defined? Uconv
  $XMLParser = XMLParser_ja unless Xconv::DUMP_ONLY
  $KCODE_TO_XMLENC = {
    'EUC'  => 'EUC-JP',
    'SJIS' => 'Shift_JIS',
    'UTF8' => 'UTF-8',
    'NONE' => 'US-ASCII',
  }
else
  $XMLParser = XMLParser unless Xconv::DUMP_ONLY
  $KCODE_TO_XMLENC = Hash.new('UTF-8')
end

# Test
if __FILE__ == $0
  def ok?(xml1, xml2, obj1, obj2)
    puts xml1 if $VERBOSE
    if xml1 != xml2
      puts xml2 if $VERBOSE
      p obj1, obj2
      raise 'mismatch XML'
    end
    if Marshal.dump(obj1) != Marshal.dump(obj2)
      puts xml2 if $VERBOSE
      p obj1, obj2
      raise 'mismatch Marshal'
    end
  end
  
  def test(obj, direct = false)
    puts "## #{direct ? 'DIRECT' : 'RubyObject'} ROOT" if $VERBOSE
    xml1 = XMarshal.dump(obj, '',  direct)
    obj1 = XMarshal.load(xml1, direct)
    xml2 = XMarshal.dump(obj1, '', direct)
    obj2 = XMarshal.load(xml2, direct)
    ok?(xml1, xml2, obj1, obj2)
    [obj2, xml2]
  end

  def test_loader(obj)
    puts "## Loader" if $VERBOSE
    xml1 = XMLoader.new.dump(obj)
    puts xml1 if $VERBOSE
    obj1 = XMLoader.new.load(xml1)
    p obj1 if $VERBOSE
    [obj1, xml1]
  end

  ## test data

  class Foo
    attr_accessor :attr0, :attr1, :attr2, :attr3
    def initialize()
    end
    def self.new_obj(*a)
      inst = Foo.new()
      inst.attr0 = a[0]
      inst.attr1 = a[1]
      inst.attr2 = a[2]
      inst.attr3 = a[3]
      inst
    end
  end
  module Bar
    class Foo2; end
  end

  aObject = Object.new
  aObject.instance_eval { @foo = 'FOO' }

  objects = [true, false, nil, 1, 10**30, 0.1, 'FOO', 'ENTITY<>%&',
    [1, 2, 3], {'<foo>'=>1, '&bar%'=>2},
    Time.now, Date.at(Time.now),
    aObject, Foo.new_obj(true, nil, 'FOO', 3.14), Bar::Foo2.new,
  ]
  h = Hash.new('DEFAULT')
  h['foo'] = 1
  objects << h

  class Object
    def equal_contents?(other)
      return true if self == other
      return false if self.type != other.type
      ivars = instance_variables
      if ivars
        ivars.each {|iv|
          v = (eval iv)
          o = other.__iv_get(iv)
          next if v == 0
          return false unless v.equal_contents? o
        }
      end
      true
    end
  end

  objects.each {|obj|
    puts "\n### TESTING #{obj.type} #{obj.inspect}" if $VERBOSE
    o,x = test(obj)
    raise 'test fail' unless obj.equal_contents? o
    o,x = test(obj, true)
    raise 'test fail' unless obj.equal_contents? o
    o,x = test_loader(obj)
  }


  encoding = $KCODE_TO_XMLENC[$KCODE]

  xml = <<EOS
<?xml version="1.0" encoding="#{encoding}"?>
<RubyObject version="1.0">
  <Foo>
    <foo>foo</foo>
  </Foo>
</RubyObject>
EOS
  puts "\n### TESTING #{xml.inspect}" if $VERBOSE
  o,x = test(XMarshal.load(xml))
  raise 'test failed' if x != xml

  xml = <<EOS
<?xml version="1.0" encoding="#{encoding}"?>
<Hash>
  <String key="&lt;">FOO</String>
</Hash>
EOS
  puts "\n### TESTING #{xml.inspect}" if $VERBOSE
  o,x = test(XMarshal.load_root(xml), true)
  raise 'test failed' if x != xml

  xml = <<EOS
<?xml version="1.0" encoding="#{encoding}"?>
<top>
  <foo>FOO</foo>
  <bar attr="ATTR">
    <str>STRING</str>
  </bar>
</top>
EOS
  puts "\n### TESTING #{xml.inspect}" if $VERBOSE
  o = XMLoader.new.load(xml)
  p o if $VERBOSE
  raise if o.bar.str != 'STRING'


  if ARGV[0]
    xml = open(ARGV[0]).read
    o = XMLoader.new.load(xml)
    p o
  end

  if false
    class Time
      def inspect
        format('%d.%.6d ', tv_sec, tv_usec) << to_s
      end
    end
    while true
      test Time.now
    end
  end

  puts "test succeed"
end
