#!/usr/bin/ruby -p

gsub!(/rb_define/, 'zz_define')
gsub!(/rb_c/, '$rb_c')
gsub!(/rb_e/, '$rb_e')
gsub!(/rb_m/, '$rb_m')
gsub!(/\bsuper\b/, 'supr')
gsub!(/\bmodule\b/, 'modl')
gsub!(/\bQnil\b/, 'NIL')
gsub!(/\bQtrue\b/, 'TRUE')
gsub!(/\bQfalse\b/, 'FALSE')

if /zz_define_((module|class|method)_id|(readonly|hooked|virtual)_variable)/ then
  $_ = "# IGNORE " + $_
end

# finally, strip all c function pointers out
gsub!(/(zz_define_(?:private_method|method|global_function|singleton_method|module_function)\s*\(.*?,\s*)\S+,\s*([\d-]+\))/) do
  $1 + $2
end
