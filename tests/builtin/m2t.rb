#!/usr/bin/env ruby
class C2T
  SPECIAL_METHODS = {
    '+'   => 'PLUS',
    '-'   => 'MINUS',
    '*'   => 'MUL',
    '/'   => 'DIV',
    '%'   => 'MOD',
    '**'  => 'POW',
    '&'   => 'AND',
    '|'   => 'OR',
    '^'   => 'XOR',
    '~'   => 'REV',
    '<<'  => 'LSHIFT',
    '>>'  => 'RSHIFT',
    '<'   => 'LT',
    '<='  => 'LE',
    '>'   => 'GT',
    '>='  => 'GE',
    '<=>' => 'CMP',
    '=='  => 'EQUAL',
    '===' => 'VERY_EQUAL',
    '=~'  => 'MATCH',
    '[]'  =>  'AREF',
    '[]=' => 'ASET',
  }

  def test_method_name(method)
    if SPECIAL_METHODS.include?(method)
      "test_#{SPECIAL_METHODS[method]}" + " # '#{method}'"
    else
      "test_#{method}"
    end
  end

  def test_singleton_method_name(m)
    "test_s_#{m}"
  end

  def def_test_method(m)
    <<STR

  def #{m}
    assert_fail("untested")
  end
STR
  end

  def test_class_name(klass)
    "Test#{klass.gsub(':', '_')}"
  end

  def def_test_class(klass)
    "class #{test_class_name(klass)} < Rubicon::TestCase"
  end

  def def_test_singleton_methods(klass)
    str = ''
    klass.singleton_methods.collect{|m|
      test_singleton_method_name(m)
    }.sort.each do |m|
      str.concat def_test_method(m)
    end
    str
  end

  def def_test_instance_methods(klass)
    str = ''
    klass.instance_methods.collect{|f|
      test_method_name(f)
    }.sort.each do |f|
      str.concat def_test_method(f)
    end
    str
  end

  def c2t(klass)
    if klass.instance_of?(String)
      str = def_test_class(klass)
    else
      str = def_test_class(klass.name)
    end
    str += "\n"
    if klass.instance_of?(Module)
      str += def_test_instance_methods(klass)
      str += def_test_singleton_methods(klass)
    end
    str += "\nend\n"
  end
end

class TestFrame
  def initialize
    @c2t = C2T.new
  end

  def require_frame
    <<STR
require '../rubicon'
STR
  end

  def require_target(file)
    "require '#{file}'"
  end

  def testrunner(klass)
    if klass.instance_of?(Module)
      target = klass.name
    else
      target = klass
    end  
    testclass = @c2t.test_class_name(target)
    "Rubicon::handleTests(#{testclass}) if $0 == __FILE__\n"
  end

  def create_frame(klass, file=nil)
    str = require_frame
    str += "\n"
    if file
      require file
      str += require_target(file)
      str += "\n"
    end
    begin
      k = eval(klass)
    rescue NameError
      k = klass
    end
    str += "\n"
    str += @c2t.c2t(k)  
    str += "\n"
    str += testrunner(k)
  end
end

def print_usage
  puts "USAGE : #{File.basename($0)} class [file]"
end

ObjectSpace.each_object(Module) {|klass|
  next unless klass.type == Module
  name = klass.name
  if name !~ /^Errno/ and 
      name !~ /Error$/ and 
      name != "C2T" and
      name != "TestFrame"

    open("m_Test#{name}.rb", "w") { |file|
      tf = TestFrame.new
      file.print tf.create_frame(name, nil)
    }
  end
}


