#!/usr/local/bin/ruby -ws

require "yaml"
require "rdoc/ri/ri_descriptions"
require "rdoc/ri/ri_paths"
require "rdoc/markup/simple_markup/to_flow"

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

  rdoc_path = "#{RI::Paths::PATH}/#{klass}/#{safe_meth_name}-#{suffix}.yaml"
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
    puts
    puts "  ##"
    puts "  # File #{rdoc_path} doesn't exist"
    puts "  #   try: cd RUBY; rdoc -f ri -o rdoc"
  end
end

def generate_method(mod, meth, instance_method)
    #puts "ACK: #{mod}.#{meth} instance_method: #{instance_method}"
    generate_rdoc mod, meth, instance_method

    arity = if instance_method then
              mod.instance_method(meth.intern).arity
            else
              mod.method(meth.intern).arity
            end

    meth = if not instance_method and meth == 'new' then
             'initialize'
           elsif instance_method then
             meth
           else
             "self.#{meth}"
           end

    puts
    print "  "
    print "def #{meth}"
    case arity
    when 0 then
    when 1..8 then
      arglist = (1..arity).to_a.map { |n| "arg#{n}" }.join(", ")
      print "(#{arglist})"
    when -1 then
      print "(*args)"
    else
      # print "ACK: #{mod}.#{meth} arity = #{arity}"
    end
    puts
    puts "    raise NotImplementedError, '#{meth} is not implemented'"
    puts "  end"
end

def generate_class(klass)
  superklass = klass.respond_to?(:superclass) ? klass.superclass : nil
  print "class #{klass}"
  unless superklass.nil? or superklass == Object then
    puts " < #{superklass}"
  else
    puts
  end

  klass.public_methods(false).sort.each do |meth|
    next if meth =~ /yaml/ and klass.name !~ /YAML/
    next if meth == 'allocate'
    next if meth == 'superclass'

    generate_method klass, meth, false
  end

  methods = unless klass == Object then
              klass.instance_methods(false)
            else
              klass.instance_methods(true)
            end

  methods.sort.each do |meth|
    next if meth =~ /yaml/ and klass.name !~ /YAML/

    generate_method klass, meth, true
  end

  puts "end"
  puts
end

def generate_module(mod)
  print "module #{mod}"
  puts

  mod.methods(false).sort.each do |meth|
    generate_method mod, meth, false
  end

  mod.instance_methods(false).sort.each do |meth|
    generate_method mod, meth, true
  end

  puts
  puts "end"
  puts
end

$c = nil unless defined? $c
$m = nil unless defined? $m
raise ArgumentError, "Use -m or -c" unless $c or $m

generate_class  eval($c) if $c
generate_module eval($m) if $m

