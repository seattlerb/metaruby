#include "port.h"
require 'port'
    rb_mGC = rb_define_module("GC");
    rb_define_singleton_method(rb_mGC, "start", gc_start, 0);
    rb_define_singleton_method(rb_mGC, "enable", gc_enable, 0);
    rb_define_singleton_method(rb_mGC, "disable", gc_disable, 0);
    rb_define_method(rb_mGC, "garbage_collect", gc_start, 0);
    rb_mObSpace = rb_define_module("ObjectSpace");
    rb_define_module_function(rb_mObSpace, "each_object", os_each_obj, -1);
    rb_define_module_function(rb_mObSpace, "garbage_collect", gc_start, 0);
    rb_define_module_function(rb_mObSpace, "add_finalizer", add_final, 1);
    rb_define_module_function(rb_mObSpace, "remove_finalizer", rm_final, 1);
    rb_define_module_function(rb_mObSpace, "finalizers", finals, 0);
    rb_define_module_function(rb_mObSpace, "call_finalizer", call_final, 1);
    rb_define_module_function(rb_mObSpace, "define_finalizer", define_final, -1);
    rb_define_module_function(rb_mObSpace, "undefine_finalizer", undefine_final, 1);
    rb_define_module_function(rb_mObSpace, "_id2ref", id2ref, 1);
