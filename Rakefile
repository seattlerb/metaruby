# -*- ruby -*-

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

def run(name)
  Task[name].execute
end

def task(args, &block)
  case args
  when Hash
    args.each_pair do |k,v|
      Rake::Task.define_task(k => v, &block)
    end
  when Array
    args.each do |subtask|
      Rake::Task.define_task(subtask, &block)
    end
  end
end

# class => file
CLASSES = {
  "TrueClass" => "true_class",
  "FalseClass" => "false_class",
  "NilClass" => "nil_class",
  "Time" => "time",
  "Array" => "array",
  "Range" => "range",
  "Hash" => "hash",
  "String" => "string",
  "Comparable" => "comparable",
  "Exception" => "exception",
  "FileTest" => "file_test",
  "Struct" => "struct",
}

C_FILES = CLASSES.values.map { |c| "#{c}.c" }

task :default => C_FILES

task :clean do |t|
  rm %w(*~ *.c *.o *.$(SHLIB_EXT) ~/.ruby_inline *.a *.pass *.cache).map { |pat| Dir[pat] }.flatten
end

RUBY2C = File.expand_path "../../ruby_to_c/dev"
BFTS = File.expand_path "../../bfts/dev"

inc = %w(ruby_to_c/dev/lib ParseTree/dev/lib RubyInline/dev bfts/dev).map { |p| File.expand_path "../../#{p}" }

RUBY_FLAGS = %(-w -Ilib:bin:#{inc.join(':')})
task :test => [ :clean, :default ]

rule '.pass' => ['.rb'] do |t|
  Dir.chdir BFTS do
    ruby %(-I../../metaruby/dev -r#{t.source} test_#{t.source} #{ENV['FILTER']})
  end
  touch t.name
end

rule '.c' => ['.pass'] do |t|
  rb_file = File.basename(t.source, '.pass') + '.rb'
  ruby %(#{RUBY_FLAGS} #{RUBY2C}/bin/ruby_to_c_translate -c=#{File.basename t.name, '.c'} ./#{rb_file} > #{t.name})
end

# so you can type `make Time` to just run Time tests

# makefile version -- so clean:
# $(CLASSES):
# 	(cd $(BFTS); $(RUBY) -I../../../metaruby/dev:.. -r$@ Test$@.rb $(FILTER))

# initial cut, and I think the "right way" to do it in rake:
# CLASSES.each do |file,klass|
#   task klass do |t|
#     Dir.chdir BFTS do
#       ruby %(-I../../metaruby/dev -r#{file} test_#{file}.rb)
#     end
#   end
# end

# with new task method above
# task CLASSES.keys do |t|
#   Dir.chdir BFTS do
#     ruby %(-I../../metaruby/dev -r#{CLASSES[t.name]} test_#{CLASSES[t.name]}.rb #{ENV['FILTER']})
#   end
# end

# instead of:
# CLASSES.each do |k,n|
#   task k => n
# end

# do this:
task CLASSES # maps TrueClass -> true_class

task CLASSES.values do |t|
  Dir.chdir BFTS do
    ruby %(-I../../metaruby/dev -r#{t.name} test_#{t.name}.rb #{ENV['FILTER']})
  end
end

task :sort do
  Dir["**/*.rb"].each do |f|
    sh %(grep "^ *def " #{f} | grep -v "def self" > x; sort x > y; echo; echo #{f}; echo; diff x y; true)
  end
  rm %w(x y)
end

# AUDITFILES = $(patsubst %,%.audit.rb,$(CLASSES))
# OFILES = $(patsubst %,%.o,$(CLASSES))

# SHLIB_EXT = $(shell ruby -rrbconfig -e 'puts Config::CONFIG["DLEXT"]')
# LINKER = $(shell ruby -rrbconfig -e 'puts Config::CONFIG["LDSHARED"]')

# %.audit.rb: %.rb bfts/Test%.rb Makefile
# 	$(RUBY) ../../ZenTest/dev/ZenTest.rb $*.rb bfts/Test$*.rb

# metaruby: metaruby.$(SHLIB_EXT)
# metaruby.$(SHLIB_EXT): $(OFILES)
# 	$(LINKER) $^ -o $@

# libmetaruby.a: $(OFILES)
# 	rm $@; ar r $@ $^ && ranlib $@

# FORCE:
# doc: FORCE
# 	rm -rf doc ; rdoc -x bfts .

# audit: $(AUDITFILES)
