#include "port.h"
require 'port'

rb_define_global_const("DATA", :DATA);

rb_define_variable("$VERBOSE", :$VERBOSE);
rb_define_variable("$-v", :$VERBOSE);
rb_define_variable("$-w", :$VERBOSE);
rb_define_variable("$DEBUG", :$DEBUG);
rb_define_variable("$-d", :$DEBUG);
rb_define_readonly_variable("$-p", :$-p);
rb_define_readonly_variable("$-l", :$-l);
    rb_define_hooked_variable("$0", &rb_progname, 0, set_arg0);
    rb_define_readonly_variable("$*", $*);
rb_define_global_const("ARGV", :ARGV);
    rb_define_readonly_variable("$-a", $-a);
