#include "port.h"
require 'port'
rb_define_global_const("RUBY_VERSION", :RUBY_VERSION);
rb_define_global_const("RUBY_RELEASE_DATE", :RUBY_RELEASE_DATE);
rb_define_global_const("RUBY_PLATFORM", :RUBY_PLATFORM);
rb_define_global_const("VERSION", :RUBY_VERSION);
rb_define_global_const("RELEASE_DATE", :RUBY_RELEASE_DATE);
rb_define_global_const("PLATFORM", :RUBY_PLATFORM);
