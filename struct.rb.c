#include "port.h"
require 'port'
#	nstr = rb_define_class_under(klass, cname, klass);
# HACK    rb_define_singleton_method(nstr, "new", struct_alloc, -1);
# HACK    rb_define_singleton_method(nstr, "[]", struct_alloc, -1);
# HACK    rb_define_singleton_method(nstr, "members", rb_struct_s_members, 0);
# HACK	    rb_define_method_id(nstr, id, ref_func[i], 0);
# HACK	    rb_define_method_id(nstr, id, rb_struct_ref, 0);
# HACK	rb_define_method_id(nstr, rb_id_attrset(id), rb_struct_set, 1);
    rb_cStruct = rb_define_class("Struct", rb_cObject);
    rb_define_singleton_method(rb_cStruct, "new", rb_struct_s_def, -1);
    rb_define_method(rb_cStruct, "initialize", rb_struct_initialize, -2);
    rb_define_method(rb_cStruct, "clone", rb_struct_clone, 0);
    rb_define_method(rb_cStruct, "==", rb_struct_equal, 1);
    rb_define_method(rb_cStruct, "to_s", rb_struct_to_s, 0);
    rb_define_method(rb_cStruct, "inspect", rb_struct_inspect, 0);
    rb_define_method(rb_cStruct, "to_a", rb_struct_to_a, 0);
    rb_define_method(rb_cStruct, "values", rb_struct_to_a, 0);
    rb_define_method(rb_cStruct, "size", rb_struct_size, 0);
    rb_define_method(rb_cStruct, "length", rb_struct_size, 0);
    rb_define_method(rb_cStruct, "each", rb_struct_each, 0);
    rb_define_method(rb_cStruct, "[]", rb_struct_aref, 1);
    rb_define_method(rb_cStruct, "[]=", rb_struct_aset, 2);
    rb_define_method(rb_cStruct, "members", rb_struct_members, 0);
