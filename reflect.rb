#!/usr/local/bin/ruby -ws

require "YAML"
require "rdoc/ri/ri_descriptions"
require "rdoc/markup/simple_markup/to_flow"

# require "rdoc/ri/ri_formatter"

klasses = []

class String
  def wrap(width=72, with="")
    width -= with.length
    result = self.scan(/(.{1,#{width}})([ \n]|\Z|$)/).map { |a| a.first }
    return with + result.join("\n" + with)
  end
  def htmlify
    self.
      gsub(/&/, '&amp;').
      gsub(/"/, '&quot;').
      gsub(/>/, '&gt;').
      gsub(/</, '&lt;')
  end
  def unhtmlify
    self.
      gsub(/&gt;/, '>').
      gsub(/&lt;/, '<').
      gsub(/&quot;/, '"').
      gsub(/&amp;/, '&')
  end
end

def generate_rdoc(klass, meth, instance_method)
  safe_meth_name = meth.gsub(/\W/) { sprintf("%%%02x", $&[0]) }

  suffix = instance_method ? "i" : "c"

  rdoc_path = "rdoc/#{klass}/#{safe_meth_name}-#{suffix}.yaml"
  if test ?f, rdoc_path then
    rdoc = YAML.load_file(rdoc_path) rescue nil

    puts
    puts "  ##"
    puts "  # call-seq:"
    rdoc.params.each_line do |l|
      puts "  #   #{l.unhtmlify}"
    end
    rdoc.comment.each do |c|
      puts "  #"
      puts c.body.unhtmlify.wrap(76, "  # ")
    end
  else
    puts "# File #{rdoc_path} doesn't exist"
  end
end

ObjectSpace.each_object(Class) do |klass|
  next if klass.name =~ /Errno|NameError::message/
  next if klass.ancestors.include? Exception
  klasses << klass
end

klasses = klasses.sort_by { |k| k.name }

$c = nil unless defined? $c
$c = eval $c if $c

klasses.each do |klass|

  if $c then
    next unless klass == $c
  end

  superklass = klass.respond_to?(:superclass) ? klass.superclass : nil
  print "class #{klass}"
  unless superklass.nil? or superklass == Object then
    puts " < #{superklass}"
  else
    puts
  end

  klassmethods = klass.public_methods(false)
  klassmethods.sort.each do |meth|
    next if meth =~ /yaml/ and klass.name !~ /YAML/
    next if meth == 'allocate'
    next if meth == 'superclass'

    arity = klass.method(meth.intern).arity

    generate_rdoc(klass, meth, false)

    if meth == 'new' then
      meth = 'initialize'
    else
      meth = "self.#{meth}"
    end

    puts
    print "  "
    print "# " unless meth == "initialize"
    print "def #{meth}"
    case arity
    when 0 then
    when 1..8 then
      arglist = (1..arity).to_a.map { |n| "arg#{n}" }.join(", ")
      print "(#{arglist})"
    when -1 then
      print "(*args)"
    else
      # print "ACK: #{klass}.#{meth} arity = #{arity}"
    end
    
    puts "; end"
  end

  methods = unless klass == Object then
              klass.instance_methods(false)
            else
              klass.instance_methods(true)
            end

  methods.sort.each do |meth|
    next if meth =~ /yaml/ and klass.name !~ /YAML/
    arity = klass.instance_method(meth.intern).arity

    generate_rdoc(klass, meth, true)

    puts
    print "  def #{meth}"

    case arity
    when 0 then
    when 1..8 then
      arglist = (1..arity).to_a.map { |n| "arg#{n}" }.join(", ")
      print "(#{arglist})"
    when -1 then
      print "(*args)"
    else
      print "ACK: #{klass}.#{meth} arity = #{arity}"
    end
    puts "; end"
  end

  puts "end"
  puts
end
