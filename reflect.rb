#!/usr/local/bin/ruby -ws

klasses = []

ObjectSpace.each_object(Class) do |klass|
  next if klass.name =~ /Errno|NameError::message/
  next if klass.ancestors.include? Exception
  klasses << klass
end

klasses = klasses.sort_by { |k| k.name }

$c = defined?($c) ? eval($c) : nil

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
    next if meth == 'allocate'
    next if meth == 'superclass'

    arity = klass.method(meth.intern).arity

    if meth == 'new' then
      meth = 'initialize'
    else
      meth = "self.#{meth}"
    end
    
    print "  "
    print "# "
    print "def #{meth}"
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

  methods = unless klass == Object then
              klass.instance_methods(false)
            else
              klass.instance_methods(true)
            end

  methods.sort.each do |meth|
    arity = klass.instance_method(meth.intern).arity

    print "  "
    # print "# "
    print "def #{meth}"

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

puts "puts 'DONE!'"
