#include "port.h"
require 'port'
require 'array'
require 'string'

    rb_define_method(rb_cArray, "pack", pack_pack, 1);
    rb_define_method(rb_cString, "unpack", pack_unpack, 1);
