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

if /zz_define_(module_id|class_id)/ then
  $_ = "# IGNORE " + $_
end

if /zz_define_(hooked_variable|virtual_variable|readonly_variable)/ then
  $_ = "# HACK " + $_
end

gsub!(/(zz_define_hooked_variable\(\"[^\"]+\").*/) do
  $1 + ")"
end

# finally, strip all c function pointers out
gsub!(/(zz_define_(?:private_method|method|global_function|singleton_method|module_function)\s*\(.*?,\s*)\S+,\s*([\d-]+\))/) do
  $1 + $2
end
