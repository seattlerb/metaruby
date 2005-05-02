#!/usr/local/bin/ruby -w

# C code produced by gperf version 2.7.2
# Command-line: gperf -p -j1 -i 1 -g -o -t -N rb_reserved_word -k'1,3,$' ./keywords
# hand translated to ruby by ryand-ruby@zenspider.com

class KWtable
  attr_accessor :name, :id, :state
  def initialize(name, id=[], state=nil)
    @name = name
    @id = id
    @state = state
  end
end

TOTAL_KEYWORDS=40
MIN_WORD_LENGTH=2
MAX_WORD_LENGTH=8
MIN_HASH_VALUE=6
MAX_HASH_VALUE=55
# maximum key range = 50, duplicates = 0

EXPR_BEG = 0			# ignore newline, +/- is a sign.
EXPR_END = 1			# newline significant, +/- is a operator.
EXPR_ARG = 2			# newline significant, +/- is a operator.
EXPR_CMDARG = 3 		# newline significant, +/- is a operator.
EXPR_ENDARG = 4         	# newline significant, +/- is a operator.
EXPR_MID = 5			# newline significant, +/- is a operator.
EXPR_FNAME = 6			# ignore newline, no reserved words.
EXPR_DOT = 7			# right after `.' or `::', no reserved words.
EXPR_CLASS = 8			# immediate after `class', no here document.

K_CLASS=257
K_MODULE=258
K_DEF=259
K_UNDEF=260
K_BEGIN=261
K_RESCUE=262
K_ENSURE=263
K_END=264
K_IF=265
K_UNLESS=266
K_THEN=267
K_ELSIF=268
K_ELSE=269
K_CASE=270
K_WHEN=271
K_WHILE=272
K_UNTIL=273
K_FOR=274
K_BREAK=275
K_NEXT=276
K_REDO=277
K_RETRY=278
K_IN=279
K_DO=280
K_DO_COND=281
K_DO_BLOCK=282
K_RETURN=283
K_YIELD=284
K_SUPER=285
K_SELF=286
K_NIL=287
K_TRUE=288
K_FALSE=289
K_AND=290
K_OR=291
K_NOT=292
K_IF_MOD=293
K_UNLESS_MOD=294
K_WHILE_MOD=295
K_UNTIL_MOD=296
K_RESCUE_MOD=297
K_ALIAS=298
K_DEFINED=299
K_lBEGIN=300
K_lEND=301
K___LINE__=302
K___FILE__=303
T_IDENTIFIER=304
T_FID=305
T_GVAR=306
T_IVAR=307
T_CONSTANT=308
T_CVAR=309
T_INTEGER=310
T_FLOAT=311
T_STRING_CONTENT=312
T_NTH_REF=313
T_BACK_REF=314
T_REGEXP_END=315
T_UPLUS=316
T_UMINUS=317
T_POW=318
T_CMP=319
T_EQ=320
T_EQQ=321
T_NEQ=322
T_GEQ=323
T_LEQ=324
T_ANDOP=325
T_OROP=326
T_MATCH=327
T_NMATCH=328
T_DOT2=329
T_DOT3=330
T_AREF=331
T_ASET=332
T_LSHFT=333
T_RSHFT=334
T_COLON2=335
T_COLON3=336
T_OP_ASGN=337
T_ASSOC=338
T_LPAREN=339
T_LPAREN_ARG=340
T_RPAREN=341
T_LBRACK=342
T_LBRACE=343
T_LBRACE_ARG=344
T_STAR=345
T_AMPER=346
T_SYMBEG=347
T_STRING_BEG=348
T_XSTRING_BEG=349
T_REGEXP_BEG=350
T_WORDS_BEG=351
T_QWORDS_BEG=352
T_STRING_DBEG=353
T_STRING_DVAR=354
T_STRING_END=355
T_LOWEST=356
T_UMINUS_NUM=357
T_LAST_TOKEN=358

def hash(str, len)
  asso_values = [
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 11, 56, 56, 36, 56,  1, 37,
    31,  1, 56, 56, 56, 56, 29, 56,  1, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56,  1, 56, 32,  1,  2,
    1,  1,  4, 23, 56, 17, 56, 20,  9,  2,
    9, 26, 14, 56,  5,  1,  1, 16, 56, 21,
    20,  9, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56, 56, 56, 56, 56,
    56, 56, 56, 56, 56, 56
  ]
  hval = len;

  case hval
  when 2,1 then
    hval += asso_values[str[0]];
  else
    hval += asso_values[str[2]];
    hval += asso_values[str[0]];
  end

  hval += asso_values[str[len - 1]];
  return hval
end

def rb_reserved_word(str, len)
# TODO: move this out
  wordlist = [
    [""], [""], [""], [""], [""], [""],
    ["end", [K_END, K_END], EXPR_END],
    ["else", [K_ELSE, K_ELSE], EXPR_BEG],
    ["case", [K_CASE, K_CASE], EXPR_BEG],
    ["ensure", [K_ENSURE, K_ENSURE], EXPR_BEG],
    ["module", [K_MODULE, K_MODULE], EXPR_BEG],
    ["elsif", [K_ELSIF, K_ELSIF], EXPR_BEG],
    ["def", [K_DEF, K_DEF], EXPR_FNAME],
    ["rescue", [K_RESCUE, K_RESCUE_MOD], EXPR_MID],
    ["not", [K_NOT, K_NOT], EXPR_BEG],
    ["then", [K_THEN, K_THEN], EXPR_BEG],
    ["yield", [K_YIELD, K_YIELD], EXPR_ARG],
    ["for", [K_FOR, K_FOR], EXPR_BEG],
    ["self", [K_SELF, K_SELF], EXPR_END],
    ["false", [K_FALSE, K_FALSE], EXPR_END],
    ["retry", [K_RETRY, K_RETRY], EXPR_END],
    ["return", [K_RETURN, K_RETURN], EXPR_MID],
    ["true", [K_TRUE, K_TRUE], EXPR_END],
    ["if", [K_IF, K_IF_MOD], EXPR_BEG],
    ["defined?", [K_DEFINED, K_DEFINED], EXPR_ARG],
    ["super", [K_SUPER, K_SUPER], EXPR_ARG],
    ["undef", [K_UNDEF, K_UNDEF], EXPR_FNAME],
    ["break", [K_BREAK, K_BREAK], EXPR_MID],
    ["in", [K_IN, K_IN], EXPR_BEG],
    ["do", [K_DO, K_DO], EXPR_BEG],
    ["nil", [K_NIL, K_NIL], EXPR_END],
    ["until", [K_UNTIL, K_UNTIL_MOD], EXPR_BEG],
    ["unless", [K_UNLESS, K_UNLESS_MOD], EXPR_BEG],
    ["or", [K_OR, K_OR], EXPR_BEG],
    ["next", [K_NEXT, K_NEXT], EXPR_MID],
    ["when", [K_WHEN, K_WHEN], EXPR_BEG],
    ["redo", [K_REDO, K_REDO], EXPR_END],
    ["and", [K_AND, K_AND], EXPR_BEG],
    ["begin", [K_BEGIN, K_BEGIN], EXPR_BEG],
    ["__LINE__", [K___LINE__, K___LINE__], EXPR_END],
    ["class", [K_CLASS, K_CLASS], EXPR_CLASS],
    ["__FILE__", [K___FILE__, K___FILE__], EXPR_END],
    ["END", [K_lEND, K_lEND], EXPR_END],
    ["BEGIN", [K_lBEGIN, K_lBEGIN], EXPR_END],
    ["while", [K_WHILE, K_WHILE_MOD], EXPR_BEG],
    [""], [""], [""], [""], [""], [""], [""], [""], [""],
    [""],
    ["alias", [K_ALIAS, K_ALIAS], EXPR_FNAME]
  ].map { |args| KWtable.new(*args) }

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH) then
    key = hash(str, len)
    
    if (key <= MAX_HASH_VALUE && key >= 0) then
      s = wordlist[key].name;
      return wordlist[key] if str == s
    end
  end
  return 0;
end

if $0 == __FILE__ then
# I have no idea what this should output at ALL.
  [ "class",
    "if",
    "fooby",
    "alias" ].each do |word|
    p rb_reserved_word(word, word.length)
  end
end
