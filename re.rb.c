#include "port.h"
require 'port'
require 'error'

    rb_eRegexpError = rb_define_class("RegexpError", rb_eStandardError);
    rb_define_virtual_variable("$~", match_getter, match_setter);
    rb_define_virtual_variable("$&", last_match_getter, 0);
    rb_define_virtual_variable("$`", prematch_getter, 0);
    rb_define_virtual_variable("$'", postmatch_getter, 0);
    rb_define_virtual_variable("$+", last_paren_match_getter, 0);
    rb_define_virtual_variable("$=", ignorecase_getter, ignorecase_setter);
    rb_define_virtual_variable("$KCODE", kcode_getter, kcode_setter);
    rb_define_virtual_variable("$-K", kcode_getter, kcode_setter);
    rb_cRegexp = rb_define_class("Regexp", rb_cObject);
    rb_define_singleton_method(rb_cRegexp, "new", rb_reg_s_new, -1);
    rb_define_singleton_method(rb_cRegexp, "compile", rb_reg_s_new, -1);
    rb_define_singleton_method(rb_cRegexp, "quote", rb_reg_s_quote, -1);
    rb_define_singleton_method(rb_cRegexp, "escape", rb_reg_s_quote, -1);
    rb_define_singleton_method(rb_cRegexp, "last_match", match_getter, 0);
    rb_define_method(rb_cRegexp, "initialize", rb_reg_initialize_m, -1);
    rb_define_method(rb_cRegexp, "clone", rb_reg_clone, 0);
    rb_define_method(rb_cRegexp, "==", rb_reg_equal, 1);
    rb_define_method(rb_cRegexp, "=~", rb_reg_match, 1);
    rb_define_method(rb_cRegexp, "===", rb_reg_match, 1);
    rb_define_method(rb_cRegexp, "~", rb_reg_match2, 0);
    rb_define_method(rb_cRegexp, "match", rb_reg_match_m, 1);
    rb_define_method(rb_cRegexp, "inspect", rb_reg_inspect, 0);
    rb_define_method(rb_cRegexp, "source", rb_reg_source, 0);
    rb_define_method(rb_cRegexp, "casefold?", rb_reg_casefold_p, 0);
    rb_define_method(rb_cRegexp, "kcode", rb_reg_kcode_m, 0);
rb_define_const(rb_cRegexp, "IGNORECASE", Regexp::IGNORECASE);
rb_define_const(rb_cRegexp, "EXTENDED", Regexp::EXTENDED);
rb_define_const(rb_cRegexp, "MULTILINE", Regexp::MULTILINE);
    rb_cMatch  = rb_define_class("MatchData", rb_cObject);
    rb_define_global_const("MatchingData", rb_cMatch.name.intern);
    rb_define_method(rb_cMatch, "clone", match_clone, 0);
    rb_define_method(rb_cMatch, "size", match_size, 0);
    rb_define_method(rb_cMatch, "length", match_size, 0);
    rb_define_method(rb_cMatch, "offset", match_offset, 1);
    rb_define_method(rb_cMatch, "begin", match_begin, 1);
    rb_define_method(rb_cMatch, "end", match_end, 1);
    rb_define_method(rb_cMatch, "to_a", match_to_a, 0);
    rb_define_method(rb_cMatch, "[]", match_aref, -1);
    rb_define_method(rb_cMatch, "pre_match", rb_reg_match_pre, 0);
    rb_define_method(rb_cMatch, "post_match", rb_reg_match_post, 0);
    rb_define_method(rb_cMatch, "to_s", match_to_s, 0);
    rb_define_method(rb_cMatch, "string", match_string, 0);
    rb_define_method(rb_cMatch, "inspect", rb_any_to_s, 0);
