# 1 ""
require 'port'
    rb_mKernel = rb_define_module("Kernel");
    rb_define_private_method(rb_cObject, "initialize", rb_obj_dummy, 0);
    rb_define_private_method(rb_cClass, "inherited", rb_obj_dummy, 1);
    rb_define_method(rb_mKernel, "nil?", rb_false, 0);
    rb_define_method(rb_mKernel, "==", rb_obj_equal, 1);
    rb_define_alias(rb_mKernel, "equal?", "==");
    rb_define_alias(rb_mKernel, "===", "==");
    rb_define_method(rb_mKernel, "=~", rb_false, 1);
    rb_define_method(rb_mKernel, "eql?", rb_obj_equal, 1);
    rb_define_method(rb_mKernel, "hash", rb_obj_id, 0);
    rb_define_method(rb_mKernel, "id", rb_obj_id, 0);
# IGNORE rb_define_method(rb_mKernel, "__id__", rb_obj_id, 0);
    rb_define_method(rb_mKernel, "type", rb_obj_class, 0);
    rb_define_method(rb_mKernel, "class", rb_obj_class, 0);
    rb_define_method(rb_mKernel, "clone", rb_obj_clone, 0);
    rb_define_method(rb_mKernel, "dup", rb_obj_dup, 0);
    rb_define_method(rb_mKernel, "taint", rb_obj_taint, 0);
    rb_define_method(rb_mKernel, "tainted?", rb_obj_tainted, 0);
    rb_define_method(rb_mKernel, "untaint", rb_obj_untaint, 0);
    rb_define_method(rb_mKernel, "freeze", rb_obj_freeze, 0);
    rb_define_method(rb_mKernel, "frozen?", rb_obj_frozen_p, 0);
    rb_define_method(rb_mKernel, "to_a", rb_any_to_a, 0);
    rb_define_method(rb_mKernel, "to_s", rb_any_to_s, 0);
    rb_define_method(rb_mKernel, "inspect", rb_obj_inspect, 0);
    rb_define_method(rb_mKernel, "methods", rb_obj_methods, 0);
    rb_define_method(rb_mKernel, "public_methods", rb_obj_methods, 0);
    rb_define_method(rb_mKernel, "singleton_methods", rb_obj_singleton_methods, 0);
    rb_define_method(rb_mKernel, "protected_methods", rb_obj_protected_methods, 0);
    rb_define_method(rb_mKernel, "private_methods", rb_obj_private_methods, 0);
    rb_define_method(rb_mKernel, "instance_variables", rb_obj_instance_variables, 0);
    rb_define_private_method(rb_mKernel, "remove_instance_variable", rb_obj_remove_instance_variable, 1);

    rb_define_method(rb_mKernel, "instance_of?", rb_obj_is_instance_of, 1);
    rb_define_method(rb_mKernel, "kind_of?", rb_obj_is_kind_of, 1);
    rb_define_method(rb_mKernel, "is_a?", rb_obj_is_kind_of, 1);
    rb_define_global_function("singleton_method_added", rb_obj_dummy, 1);
    rb_define_global_function("sprintf", rb_f_sprintf, -1);
    rb_define_global_function("format", rb_f_sprintf, -1);
    rb_define_global_function("Integer", rb_f_integer, 1);
    rb_define_global_function("Float", rb_f_float, 1);
    rb_define_global_function("String", rb_f_string, 1);
    rb_define_global_function("Array", rb_f_array, 1);
    rb_cNilClass = rb_define_class("NilClass", rb_cObject);
    rb_define_method(rb_cNilClass, "to_i", nil_to_i, 0);
    rb_define_method(rb_cNilClass, "to_s", nil_to_s, 0);
    rb_define_method(rb_cNilClass, "to_a", nil_to_a, 0);
    rb_define_method(rb_cNilClass, "inspect", nil_inspect, 0);
    rb_define_method(rb_cNilClass, "&", false_and, 1);
    rb_define_method(rb_cNilClass, "|", false_or, 1);
    rb_define_method(rb_cNilClass, "^", false_xor, 1);
    rb_define_method(rb_cNilClass, "nil?", rb_true, 0);
rb_define_global_const("NIL", :NIL);
    rb_cSymbol = rb_define_class("Symbol", rb_cObject);
    rb_define_method(rb_cSymbol, "to_i", sym_to_i, 0);
    rb_define_method(rb_cSymbol, "to_int", sym_to_i, 0);
    rb_define_method(rb_cSymbol, "inspect", sym_inspect, 0);
    rb_define_method(rb_cSymbol, "to_s", sym_to_s, 0);
    rb_define_method(rb_cSymbol, "id2name", sym_to_s, 0);
    rb_define_method(rb_cModule, "===", rb_mod_eqq, 1);
    rb_define_method(rb_cModule, "<=>",  rb_mod_cmp, 1);
    rb_define_method(rb_cModule, "<",  rb_mod_lt, 1);
    rb_define_method(rb_cModule, "<=", rb_mod_le, 1);
    rb_define_method(rb_cModule, ">",  rb_mod_gt, 1);
    rb_define_method(rb_cModule, ">=", rb_mod_ge, 1);
    rb_define_method(rb_cModule, "clone", rb_mod_clone, 0);
    rb_define_method(rb_cModule, "dup", rb_mod_dup, 0);
    rb_define_method(rb_cModule, "to_s", rb_mod_to_s, 0);
    rb_define_method(rb_cModule, "included_modules", rb_mod_included_modules, 0);
    rb_define_method(rb_cModule, "name", rb_mod_name, 0);
    rb_define_method(rb_cModule, "ancestors", rb_mod_ancestors, 0);
    rb_define_private_method(rb_cModule, "attr", rb_mod_attr, -1);
    rb_define_private_method(rb_cModule, "attr_reader", rb_mod_attr_reader, -1);
    rb_define_private_method(rb_cModule, "attr_writer", rb_mod_attr_writer, -1);
    rb_define_private_method(rb_cModule, "attr_accessor", rb_mod_attr_accessor, -1);
    rb_define_singleton_method(rb_cModule, "new", rb_module_s_new, 0);
    rb_define_method(rb_cModule, "initialize", rb_mod_initialize, -1);
    rb_define_method(rb_cModule, "instance_methods", rb_class_instance_methods, -1);
    rb_define_method(rb_cModule, "public_instance_methods", rb_class_instance_methods, -1);
    rb_define_method(rb_cModule, "protected_instance_methods", rb_class_protected_instance_methods, -1);
    rb_define_method(rb_cModule, "private_instance_methods", rb_class_private_instance_methods, -1);
    rb_define_method(rb_cModule, "constants", rb_mod_constants, 0);
    rb_define_method(rb_cModule, "const_get", rb_mod_const_get, 1);
    rb_define_method(rb_cModule, "const_set", rb_mod_const_set, 2);
    rb_define_method(rb_cModule, "const_defined?", rb_mod_const_defined, 1);
    rb_define_private_method(rb_cModule, "remove_const", rb_mod_remove_const, 1);
    rb_define_private_method(rb_cModule, "method_added", rb_obj_dummy, 1);
    rb_define_method(rb_cModule, "class_variables", rb_mod_class_variables, 0);
    rb_define_private_method(rb_cModule, "remove_class_variable", rb_mod_remove_cvar, 1);
    rb_define_method(rb_cClass, "new", rb_class_new_instance, -1);
    rb_define_method(rb_cClass, "superclass", rb_class_superclass, 0);
    rb_define_singleton_method(rb_cClass, "new", rb_class_s_new, -1);
    rb_define_singleton_method(rb_cClass, "inherited", rb_class_s_inherited, 1);
    rb_cData = rb_define_class("Data", rb_cObject);
# IGNORE    rb_define_singleton_method(ruby_top_self, "to_s", main_to_s, 0);
rb_define_global_function("to_s", main_to_s, 0);
    rb_cTrueClass = rb_define_class("TrueClass", rb_cObject);
    rb_define_method(rb_cTrueClass, "to_s", true_to_s, 0);
    rb_define_method(rb_cTrueClass, "&", true_and, 1);
    rb_define_method(rb_cTrueClass, "|", true_or, 1);
    rb_define_method(rb_cTrueClass, "^", true_xor, 1);
    rb_define_global_const("TRUE", Qtrue);
    rb_cFalseClass = rb_define_class("FalseClass", rb_cObject);
    rb_define_method(rb_cFalseClass, "to_s", false_to_s, 0);
    rb_define_method(rb_cFalseClass, "&", false_and, 1);
    rb_define_method(rb_cFalseClass, "|", false_or, 1);
    rb_define_method(rb_cFalseClass, "^", false_xor, 1);
    rb_define_global_const("FALSE", Qfalse);
