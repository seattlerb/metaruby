
def toposort(x,hash,sofar=[])
  hash[x].sort.reverse.each { |y| toposort(y,hash,sofar) } if hash.has_key?(x)
  sofar.unshift x
  sofar
end

def zz_cleanup(val)
  val = :nil if val.nil?
  if val.is_a? Symbol then
    val = val.to_s
  elsif val.is_a? String then
    val = "'#{val}'"
  end
  val
end

$zz_global_functions = []
$zz_global_const = {}

class ZZAbstractKlass

  def self.addToAll(klass)
    raise "Subclass responsibility"
  end

  def self.removeFromAll(klass)
    raise "Subclass responsibility"
  end

  def initialize(name)

    @name = name

    @consts = {}
    @methods = []
    @privatemethods = []
    @aliases = {}
    @klassmethods = []
    @innerclasses = []

    self.class.addToAll(self)
  end

  def addMethod(method)
    @methods << method
  end

  def addClassMethod(method)
    @klassmethods << method
  end

  def addPrivateMethod(method)
    @privatemethods << method
  end

  def addAlias(old, new)
    @aliases[new] = old
  end

  def addInnerClass(inner)
    self.class.removeFromAll(inner)
    @innerclasses << inner
  end

  def addConst(key, val)
    @consts[key] = val.to_s
  end

  def name
    @name
  end

  def to_s
    return self.name
  end

end

class ZZKlass < ZZAbstractKlass
  @@allKlasses = {}

  def self.addToAll(klass)
    raise "Class #{name} already defined" if @@allKlasses.has_key? name
    @@allKlasses[klass.name] = klass
  end

  def self.removeFromAll(klass)
    @@allKlasses.delete(klass.name)
  end

  def self.allKlasses
    @@allKlasses
  end

  def initialize(name, superklass)
    super(name)
    @superklass = superklass
  end

  def superklass
    @superklass
  end

  def inspect
    sk = @superklass ? "< #{@superklass.name}" : ""
    x = []
    x << "class #{@name} #{sk}"

    x += (@consts.keys.map do |key| "  #{key} = #{@consts[key]}"; end).sort

    x += (@klassmethods.map do |x| x.inspect; end).sort
    x += (@privatemethods.map do |x| x.inspect; end).sort
    x += (@methods.map do |x| x.inspect; end).sort

    x += (@aliases.keys.map do |key| "  alias #{@aliases[key]} #{key}"; end).sort

    x += @innerclasses.map do |x| x.inspect; end

    x << "end"
    x.join("\n")
  end

end

class ZZModule < ZZAbstractKlass
  @@allModules = {}

  def self.addToAll(klass)
    @@allModules[klass.name] = klass
    raise "Module #{name} already defined" if @@allModules.has_key? name
  end

  def self.removeFromAll(klass)
    @@allModules.delete(klass.name)
  end

  def self.allModules
    @@allModules
  end

  def initialize(name)
    super(name)
  end

  def inspect
    x = []
    x << "module #{@name}"

    x += (@consts.keys.map do |key| "  #{key} = #{@consts[key]}"; end).sort

    x += @klassmethods.map do |x| x.inspect; end
    x += @privatemethods.map do |x| x.inspect; end
    x += @methods.map do |x| x.inspect; end

    x += (@aliases.keys.map do |key| "  alias #{@aliases[key]} #{key}"; end).sort

    x += @innerclasses.map do |x| x.inspect; end
    x << "end"
    x.join("\n")
  end

end

class ZZMethod
  def initialize(name, arity)
    @name = name
    @arity = arity
  end

  def inspect
    if @arity == 0 then
      args = ""
    elsif @arity == 1 then
      args = "obj"
    elsif @arity == -1 then
      args = "*args"
    else
      arglist = (1..@arity.to_i).to_a.map do |n| "obj" + n.to_s; end
      args = arglist.join(", ")
    end
    args = "(" + args + ")" if args.size > 0

    s = "  def #{@name}#{args}; end"
    s += ' # `' if @name =~ /`/

    s
  end
end

def zz_define_class(name, supr)
  ZZKlass.new("Z" + name, supr)
end

# this is for outer::name subclassing supr
def zz_define_class_under(outer, name, supr)
  cls = zz_define_class name, supr
  ZZKlass.removeFromAll(cls)
  outer.addInnerClass cls
  cls
end

def zz_define_module_under(outer, name)
  mod = zz_define_module name
  ZZModule.removeFromAll(mod)
  outer.addInnerClass mod
  mod
end

def zz_define_module(name)
  ZZModule.new("Z" + name)
end

def zz_define_singleton_method(obj, name, arity)
  if obj.kind_of? ZZAbstractKlass then
    obj.addClassMethod ZZMethod.new("self." + name, arity)
  else
    $stderr.puts "Can't add singleton method #{name}:#{arity} to #{obj}"
  end
end

def zz_define_method(klass, name, arity)
  klass.addMethod ZZMethod.new(name, arity)
end

def zz_define_module_function(mod, name, arity)
  mod.addMethod ZZMethod.new(name, arity)
end

def zz_define_private_method(klass, name, arity)
  klass.addPrivateMethod ZZMethod.new(name, arity)
end

def zz_define_alias(klass, old, new)
  klass.addAlias(old, new)
end

def zz_define_const(klass, name, val)
  klass.addConst(name, zz_cleanup(val))
end

def zz_define_global_function(name, arity)
  name = 'zz_' + name unless name =~ /\`/

  $zz_global_functions << ZZMethod.new(name, arity)
end

def zz_define_global_const(name, val)
  val = zz_cleanup(val)

  $zz_global_const["Z" + name] = val
end

def zz_define_variable(name, val)
  val = zz_cleanup(val)

  $zz_global_const[name] = val
end

############################################################
# UNIMPLEMENTED FUNCTIONS:

def not_implemented_yet
  raise "Um... no, not yet"
end

def zz_define_attr(klass, name, read, write)
  not_implemented_yet
end

def zz_define_class_id(id, supr)
  not_implemented_yet
end

def zz_define_class_variable(klass, name, val)
  not_implemented_yet
end

def zz_define_hooked_variable(name)
  not_implemented_yet
end

def zz_define_method_id(klass, name, arity)
  not_implemented_yet
end

def zz_define_module_id(id)
  not_implemented_yet
end

def zz_define_protected_method(klass, name, arity)
  not_implemented_yet
end

def zz_define_readonly_variable(name, var)
  not_implemented_yet
end

def zz_define_virtual_variable(name, getter, setter)
  not_implemented_yet
end

$rb_cObject = ZZKlass.new("ZObject", nil)
$rb_cClass  = ZZKlass.new("ZClass", $rb_cObject)
$rb_cModule = ZZKlass.new("ZModule", $rb_cObject)

$zz_qnil   = :NIL
$zz_qtrue  = :TRUE
$zz_qfalse = :FALSE

at_exit do

  $zz_global_const.each_pair do |k,v|
    next if v =~ /^Z/
    puts k + " = " + v.to_s
  end

  puts
  $zz_global_functions.each do |f|
    puts f.inspect
    puts
  end

  puts
  ZZModule.allModules.each_pair do |name, m|
    puts m.inspect
    puts
  end

  allKlasses = ZZKlass.allKlasses
  subclasses = {}
  allKlasses.each_pair do |name, klass|
    supr = klass.superklass
    supr = supr ? supr.name : "nil"
    
    subclasses[supr] ||= []
    subclasses[supr] << klass.name
  end

  klasses = toposort("nil", subclasses)
  klasses.shift # remove "nil"

  puts
  klasses.each do |name|
    klass = allKlasses[name]
    puts klass.inspect
    puts
  end

  $zz_global_const.each_pair do |k,v|
    next unless v =~ /^Z/
    puts k + " = " + v.to_s
  end

  puts
  puts "__END__"
  puts

end

