#include "port.h"
require 'port'
    rb_mMath = rb_define_module("Math");
# HACK use ZMath when you can rb_define_const(rb_mMath, "PI", Math.atan(1.0)*4.0);
# HACK use ZMath when you can rb_define_const(rb_mMath, "E", Math.exp(1.0));
    rb_define_const(rb_mMath, "PI", Math::PI)
    rb_define_const(rb_mMath, "E", Math::E)
    rb_define_module_function(rb_mMath, "atan2", math_atan2, 2);
    rb_define_module_function(rb_mMath, "cos", math_cos, 1);
    rb_define_module_function(rb_mMath, "sin", math_sin, 1);
    rb_define_module_function(rb_mMath, "tan", math_tan, 1);
    rb_define_module_function(rb_mMath, "acos", math_acos, 1);
    rb_define_module_function(rb_mMath, "asin", math_asin, 1);
# HACK    rb_define_module_function(rb_mMath, "atan", math_atan, 1);
    rb_define_module_function(rb_mMath, "exp", math_exp, 1);
    rb_define_module_function(rb_mMath, "log", math_log, 1);
    rb_define_module_function(rb_mMath, "log10", math_log10, 1);
    rb_define_module_function(rb_mMath, "sqrt", math_sqrt, 1);
    rb_define_module_function(rb_mMath, "frexp", math_frexp, 1);
    rb_define_module_function(rb_mMath, "ldexp", math_ldexp, 2);
