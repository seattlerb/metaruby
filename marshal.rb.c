#include "port.h"
require 'port'
    rb_mMarshal = rb_define_module("Marshal");
    rb_define_module_function(rb_mMarshal, "dump", marshal_dump, -1);
    rb_define_module_function(rb_mMarshal, "load", marshal_load, -1);
    rb_define_module_function(rb_mMarshal, "restore", marshal_load, -1);
