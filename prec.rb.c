#include "port.h"
require 'port'
# IGNORE    rb_define_singleton_method(include, "induced_from", prec_induced_from, 1);
    rb_mPrecision = rb_define_module("Precision");
    rb_define_singleton_method(rb_mPrecision, "append_features", prec_append_features, 1);
    rb_define_method(rb_mPrecision, "prec", prec_prec, 1);
    rb_define_method(rb_mPrecision, "prec_i", prec_prec_i, 0);
    rb_define_method(rb_mPrecision, "prec_f", prec_prec_f, 0);
