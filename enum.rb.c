#include "port.h"
require 'port'
    rb_mEnumerable = rb_define_module("Enumerable");
    rb_define_method(rb_mEnumerable,"to_a", enum_to_a, 0);
    rb_define_method(rb_mEnumerable,"entries", enum_to_a, 0);
    rb_define_method(rb_mEnumerable,"sort", enum_sort, 0);
    rb_define_method(rb_mEnumerable,"grep", enum_grep, 1);
    rb_define_method(rb_mEnumerable,"find", enum_find, -1);
    rb_define_method(rb_mEnumerable,"detect", enum_find, -1);
    rb_define_method(rb_mEnumerable,"find_all", enum_find_all, 0);
    rb_define_method(rb_mEnumerable,"select", enum_find_all, 0);
    rb_define_method(rb_mEnumerable,"reject", enum_reject, 0);
    rb_define_method(rb_mEnumerable,"collect", enum_collect, 0);
    rb_define_method(rb_mEnumerable,"map", enum_collect, 0);
    rb_define_method(rb_mEnumerable,"min", enum_min, 0);
    rb_define_method(rb_mEnumerable,"max", enum_max, 0);
    rb_define_method(rb_mEnumerable,"member?", enum_member, 1);
    rb_define_method(rb_mEnumerable,"include?", enum_member, 1);
    rb_define_method(rb_mEnumerable,"each_with_index", enum_each_with_index, 0);
