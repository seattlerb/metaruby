#include "port.h"
require 'port'
require 'io'

    rb_mFileTest = rb_define_module("FileTest");

# IGNORE    rb_define_module_function(rb_mFileTest, name, func, argc);
# IGNORE    rb_define_singleton_method(rb_cFile, name, func, argc);
    rb_cFile = rb_define_class("File", rb_cIO);

# TODO: nuke rb_define_singleton_method for rb_cFile and just include the module
def define_filetest_function(name, func, argc)
    rb_define_module_function(rb_mFileTest, name, argc);
    rb_define_singleton_method(rb_cFile, name, argc);
end

    define_filetest_function("directory?", :test_d, 1);
    define_filetest_function("exist?", :test_e, 1);
    define_filetest_function("exists?", :test_e, 1); # temporary
    define_filetest_function("readable?", :test_r, 1);
    define_filetest_function("readable_real?", :test_R, 1);
    define_filetest_function("writable?", :test_w, 1);
    define_filetest_function("writable_real?", :test_W, 1);
    define_filetest_function("executable?", :test_x, 1);
    define_filetest_function("executable_real?", :test_X, 1);
    define_filetest_function("file?", :test_f, 1);
    define_filetest_function("zero?", :test_z, 1);
    define_filetest_function("size?", :test_s, 1);
    define_filetest_function("size", :rb_file_s_size, 1);
    define_filetest_function("owned?", :test_owned, 1);
    define_filetest_function("grpowned?", :test_grpowned, 1);
    define_filetest_function("pipe?", :test_p, 1);
    define_filetest_function("symlink?", :test_l, 1);
    define_filetest_function("socket?", :test_S, 1);
    define_filetest_function("blockdev?", :test_b, 1);
    define_filetest_function("chardev?", :test_c, 1);
    define_filetest_function("setuid?", :test_suid, 1);
    define_filetest_function("setgid?", :test_sgid, 1);
    define_filetest_function("sticky?", :test_sticky, 1);

    rb_define_singleton_method(rb_cFile, "stat",  rb_file_s_stat, 1);
    rb_define_singleton_method(rb_cFile, "lstat", rb_file_s_lstat, 1);
    rb_define_singleton_method(rb_cFile, "ftype", rb_file_s_ftype, 1);
    rb_define_singleton_method(rb_cFile, "atime", rb_file_s_atime, 1);
    rb_define_singleton_method(rb_cFile, "mtime", rb_file_s_mtime, 1);
    rb_define_singleton_method(rb_cFile, "ctime", rb_file_s_ctime, 1);
    rb_define_singleton_method(rb_cFile, "utime", rb_file_s_utime, -1);
    rb_define_singleton_method(rb_cFile, "chmod", rb_file_s_chmod, -1);
    rb_define_singleton_method(rb_cFile, "chown", rb_file_s_chown, -1);
    rb_define_singleton_method(rb_cFile, "link", rb_file_s_link, 2);
    rb_define_singleton_method(rb_cFile, "symlink", rb_file_s_symlink, 2);
    rb_define_singleton_method(rb_cFile, "readlink", rb_file_s_readlink, 1);
    rb_define_singleton_method(rb_cFile, "unlink", rb_file_s_unlink, -2);
    rb_define_singleton_method(rb_cFile, "delete", rb_file_s_unlink, -2);
    rb_define_singleton_method(rb_cFile, "rename", rb_file_s_rename, 2);
    rb_define_singleton_method(rb_cFile, "umask", rb_file_s_umask, -1);
    rb_define_singleton_method(rb_cFile, "truncate", rb_file_s_truncate, 2);
    rb_define_singleton_method(rb_cFile, "expand_path", rb_file_s_expand_path, -1);
    rb_define_singleton_method(rb_cFile, "basename", rb_file_s_basename, -1);
    rb_define_singleton_method(rb_cFile, "dirname", rb_file_s_dirname, 1);
rb_define_const(rb_cFile, "Separator", File::SEPARATOR.to_s);
rb_define_const(rb_cFile, "SEPARATOR", File::SEPARATOR.to_s);
    rb_define_singleton_method(rb_cFile, "split",  rb_file_s_split, 1);
    rb_define_singleton_method(rb_cFile, "join",   rb_file_s_join, -2);
# TODO make conditional on OS: windoze=rb_define_const(rb_cFile, "ALT_SEPARATOR", "\\");
    rb_define_const(rb_cFile, "ALT_SEPARATOR", Qnil);
rb_define_const(rb_cFile, "PATH_SEPARATOR", File::PATH_SEPARATOR.to_s);
    rb_define_method(rb_cIO, "stat",  rb_io_stat, 0);
    rb_define_method(rb_cFile, "lstat",  rb_file_lstat, 0);
    rb_define_method(rb_cFile, "atime", rb_file_atime, 0);
    rb_define_method(rb_cFile, "mtime", rb_file_mtime, 0);
    rb_define_method(rb_cFile, "ctime", rb_file_ctime, 0);
    rb_define_method(rb_cFile, "chmod", rb_file_chmod, 1);
    rb_define_method(rb_cFile, "chown", rb_file_chown, 2);
    rb_define_method(rb_cFile, "truncate", rb_file_truncate, 1);
    rb_define_method(rb_cFile, "flock", rb_file_flock, 1);
    rb_mFConst = rb_define_module_under(rb_cFile, "Constants");
rb_define_const(rb_mFConst, "LOCK_SH", File::Constants::LOCK_SH);
rb_define_const(rb_mFConst, "LOCK_EX", File::Constants::LOCK_EX);
rb_define_const(rb_mFConst, "LOCK_UN", File::Constants::LOCK_UN);
rb_define_const(rb_mFConst, "LOCK_NB", File::Constants::LOCK_NB);

    rb_define_method(rb_cFile, "path",  rb_file_path, 0);
    rb_define_global_function("test", rb_f_test, -1);
    rb_cStat = rb_define_class_under(rb_cFile, "Stat", rb_cObject);
    rb_define_singleton_method(rb_cStat, "new",  rb_stat_s_new, 1);
    rb_define_method(rb_cStat, "initialize", rb_stat_init, 1);
    rb_define_method(rb_cStat, "<=>", rb_stat_cmp, 1);
    rb_define_method(rb_cStat, "dev", rb_stat_dev, 0);
    rb_define_method(rb_cStat, "ino", rb_stat_ino, 0);
    rb_define_method(rb_cStat, "mode", rb_stat_mode, 0);
    rb_define_method(rb_cStat, "nlink", rb_stat_nlink, 0);
    rb_define_method(rb_cStat, "uid", rb_stat_uid, 0);
    rb_define_method(rb_cStat, "gid", rb_stat_gid, 0);
    rb_define_method(rb_cStat, "rdev", rb_stat_rdev, 0);
    rb_define_method(rb_cStat, "size", rb_stat_size, 0);
    rb_define_method(rb_cStat, "blksize", rb_stat_blksize, 0);
    rb_define_method(rb_cStat, "blocks", rb_stat_blocks, 0);
    rb_define_method(rb_cStat, "atime", rb_stat_atime, 0);
    rb_define_method(rb_cStat, "mtime", rb_stat_mtime, 0);
    rb_define_method(rb_cStat, "ctime", rb_stat_ctime, 0);
    rb_define_method(rb_cStat, "inspect", rb_stat_inspect, 0);
    rb_define_method(rb_cStat, "ftype", rb_stat_ftype, 0);
    rb_define_method(rb_cStat, "directory?",  rb_stat_d, 0);
    rb_define_method(rb_cStat, "readable?",  rb_stat_r, 0);
    rb_define_method(rb_cStat, "readable_real?",  rb_stat_R, 0);
    rb_define_method(rb_cStat, "writable?",  rb_stat_w, 0);
    rb_define_method(rb_cStat, "writable_real?",  rb_stat_W, 0);
    rb_define_method(rb_cStat, "executable?",  rb_stat_x, 0);
    rb_define_method(rb_cStat, "executable_real?",  rb_stat_X, 0);
    rb_define_method(rb_cStat, "file?",  rb_stat_f, 0);
    rb_define_method(rb_cStat, "zero?",  rb_stat_z, 0);
    rb_define_method(rb_cStat, "size?",  rb_stat_s, 0);
    rb_define_method(rb_cStat, "owned?",  rb_stat_owned, 0);
    rb_define_method(rb_cStat, "grpowned?",  rb_stat_grpowned, 0);
    rb_define_method(rb_cStat, "pipe?",  rb_stat_p, 0);
    rb_define_method(rb_cStat, "symlink?",  rb_stat_l, 0);
    rb_define_method(rb_cStat, "socket?",  rb_stat_S, 0);
    rb_define_method(rb_cStat, "blockdev?",  rb_stat_b, 0);
    rb_define_method(rb_cStat, "chardev?",  rb_stat_c, 0);
    rb_define_method(rb_cStat, "setuid?",  rb_stat_suid, 0);
    rb_define_method(rb_cStat, "setgid?",  rb_stat_sgid, 0);
    rb_define_method(rb_cStat, "sticky?",  rb_stat_sticky, 0);

# NOTE: brought over from io.rb to avoid circular references
    rb_define_singleton_method(rb_cFile, "open",  rb_file_s_open, -1);
    rb_define_method(rb_cFile, "initialize",  rb_file_initialize, -1);
