program		: compstmt
		;

compstmt	: { stmt ( ( term )+ stmt )* } ( term )*
		;

stmt		: ( kALIAS ( fitem fitem | tGVAR ( tGVAR | tBACK_REF | tNTH_REF )
		  | kUNDEF fitems
		  | klBEGIN '{' compstmt '}'
		  | klEND   '{' compstmt '}'
		  | mlhs '=' command_call
		  | lhs  '=' ( command_call | mrhs_basic )
		  | expr
		  ) ( ( kIF_MOD | kUNLESS_MOD | kWHILE_MOD | kUNTIL_MOD ) expr
		    | stmt kRESCUE_MOD stmt )*
		;

expr		: ( mlhs '=' mrhs
		  | kRETURN ret_args
		  | command_call
		  | kNOT expr
		  | '!' command_call
		  | arg
		  ) ( ( kAND | kOR ) expr )*
		;

command_call	: command
		| block_command
		;

block_command	: block_call { ( '.' | '::' ) operation2 command_args }
		;

command		: operation command_args
		| kSUPER    command_args
		| primary ( '.' | '::' ) operation2 command_args
		| kYIELD ret_args
		;

# TODO: LHS abiguity
mlhs		: ( mlhs_item ',' )+ { ( mlhs_item | '*' { lhs } ) }
		|                                    '*' { lhs }
		| '(' mlhs ')'
 		;

#  a, b  = 1, 2
#  a, *  = 1, 2
#  a,    = 1, 2
#  *     = 1, 2
#  *a    = 1, 2
# (a, *) = 1, 2
# ...

mlhs		: mlhs_item ( ',' mlhs_item )* {','} { '*' { lhs } }
		| '*' { lhs }
		| '(' mlhs ')'
		;

mlhs_item	:     lhs
		| '(' lhs ')'

lhs		: variable
		| primary ( '[' { aref_args } ']' | '::' tIDENTIFIER | primary '.' ( tIDENTIFIER |  tCONSTANT ) )
		| backref
		;

cname		: tIDENTIFIER
		| tCONSTANT
		;

fname		: tIDENTIFIER
		| tCONSTANT
		| tFID
		| op
		| reswords
		;

# RENAMED to fitems from undef_list
fitems		: fitem ( ',' fitem )*
		;

fitem		: fname
		| symbol
		;

op		: '|' | '^' | '&' | '<=>' | '==' | '===' | '=~' | '>' | '>=' | '<' | '<=' | '<<'  | '>>'
		| '+' | '-' | '*' | '*'   | '/'  | '%'   | '**' | '~' | '+'  | '-' | '[]' | '[]=' | '`'
		;

reswords	: k__LINE__ | k__FILE__ | klBEGIN | klEND
		| kALIAS | kAND | kBEGIN | kBREAK | kCASE | kCLASS | kDEF
		| kDEFINED | kDO | kELSE | kELSIF | kEND | kENSURE | kFALSE
		| kFOR | kIF_MOD | kIN | kMODULE | kNEXT | kNIL | kNOT
		| kOR | kREDO | kRESCUE | kRETRY | kRETURN | kSELF | kSUPER
		| kTHEN | kTRUE | kUNDEF | kUNLESS_MOD | kUNTIL_MOD | kWHEN
		| kWHILE_MOD | kYIELD | kRESCUE_MOD
		;

arg		: ( lhs '=' arg
		  | variable assignment_op arg
		  | primary '[' { aref_args } ']'                assignment_op arg		# TODO: cleanup?
		  | primary '.'  ( tCONSTANT | tIDENTIFIER ) assignment_op arg
		  | primary '::' tIDENTIFIER                 assignment_op arg
		  | primary
		  | backref assignment_op arg
		  | ( '+' | '-' | '!' | '~' ) arg
		  | kDEFINED { nl } arg
		  ) ( ( '!=' | '!~' | '%' | '&&' | '&' | '*' | '**' | '+' | '-' | '..' | '...' | '/' | '<'
		      | '<<' | '<=' | '<=>' | '==' | '===' | '=~' | '>' | '>=' | '>>' | '^' | '|' | '||' ) arg
		    | arg '?' arg ':' arg )*
		;

paren_args	: '('                             ')'
		| '(' call_args            { nl } ')'
		| '('           block_call { nl } ')'
		| '(' args  ',' block_call { nl } ')'
		;

call_args	: command
		| args ',' command
		| args                          { ',' block_arg }
		| args ',' '*' arg            { ',' block_arg }
		| args ',' assocs               { ',' block_arg }
		| args ',' assocs ',' '*' arg { ',' block_arg }
		|          assocs               { ',' block_arg }
		|          assocs ',' '*' arg { ',' block_arg }
		|                     '*' arg { ',' block_arg }
		|                                     block_arg
		;

command_args	: call_args
		;

block_arg	: '&' arg
		;

args 		: arg ( ',' arg )*
		;

mrhs		: arg
		| mrhs_basic
		;

mrhs_basic	: args ',' arg
		| args ',' '*' arg
		| '*' arg
		;

ret_args	: call_args
		;

primary		: ( literal
		  | string
		  | tXSTRING
		  | tQWORDS
		  | tDXSTRING
		  | tDREGEXP
		  | var_ref
		  | backref
		  | tFID
		  | kBEGIN compstmt rescue opt_else ensure kEND
		  | '(' compstmt ')'
		  | '::' cname
		  | '[' { aref_args } ']'
		  | '{' assoc_list '}'
		  | kRETURN { '(' { ret_args } ')' }
		  | kYIELD  { '(' { ret_args } ')' }
		  | kDEFINED { nl } '(' expr ')'
		  | operation brace_block
		  | method_call { brace_block }
		  | kIF     expr then compstmt if_tail  kEND
		  | kUNLESS expr then compstmt opt_else kEND
		  | kWHILE  expr do compstmt kEND
		  | kUNTIL  expr do compstmt kEND
		  | kCASE { expr } ( term )* case_body kEND
		  | kFOR block_var kIN expr do compstmt kEND
		  | kCLASS ( cname superclass | '<<' expr term ) compstmt kEND
		  | kMODULE cname compstmt kEND
		  | kDEF { singleton dot_or_colon } fname f_arglist compstmt rescue opt_else ensure kEND
		  | kBREAK
		  | kNEXT
		  | kREDO
		  | kRETRY
		  ) ('::' tCONSTANT | '[' { aref_args } ']' )*
		;

aref_args	: command_call          { nl }
		| args ',' command_call { nl }
		| args trailer
		| args ',' '*' arg      { nl }
		| assocs trailer
		| '*' arg               { nl }
		;

then		: { term } { kTHEN }
		;

do		: term
		| kDO_COND
		;

if_tail		: opt_else
		| kELSIF expr then compstmt if_tail
		;

opt_else	: { kELSE compstmt }
		;

# RENAME: terrible!
block_var	: lhs
		| mlhs
		;

# RENAME: terrible!
opt_block_var	: { '||' | '|' { block_var } '|' }
		;

do_block	: kDO_BLOCK opt_block_var compstmt kEND
		;

block_call	: command do_block ( ( '.' | '::' ) operation2 { paren_args } )*
		;

method_call	: operation paren_args
		| primary '.'     operation2 opt_paren_args
		| primary '::' operation2 paren_args
		| primary '::' operation3
		| kSUPER paren_args
		| kSUPER
		;

brace_block	: '{' opt_block_var compstmt '}'
		| kDO opt_block_var compstmt kEND
		;

case_body	: kWHEN when_args then compstmt cases
		;

when_args	: args { ',' '*' arg }
		| '*' arg
		;

cases		: opt_else
		| case_body
		;

rescue		: { kRESCUE { args } { '=>' lhs } then compstmt rescue }
		;

ensure		: { kENSURE compstmt }
		;

literal		: numeric
		| symbol
		| tREGEXP
		;

string		: ( tSTRING | tDSTRING )+
		;

symbol		: tSYMBEG sym
		;

sym		: fname
		| tIVAR
		| tGVAR
		| tCVAR
		;

numeric		: tINTEGER
		| tFLOAT
		;

variable	: tIDENTIFIER
		| tIVAR
		| tGVAR
		| tCONSTANT
		| tCVAR
		| kNIL
		| kSELF
		| kTRUE
		| kFALSE
		| k__FILE__
		| k__LINE__
		;

var_ref		: variable
		;

backref		: tNTH_REF  # /\$\d+/
		| tBACK_REF # /\$[\&\`\\\+]
		;

superclass	:          term
		| '<' expr term
		;

f_arglist	: '(' { f_args } { nl } ')'
		|     { f_args } term
		;

f_args		: f_norm_args { ',' f_opts } { ',' f_rest_arg } { ',' f_block_arg }
		|                   f_opts   { ',' f_rest_arg } { ',' f_block_arg }
		|                                  f_rest_arg   { ',' f_block_arg }
		|                                                     f_block_arg
		;

f_norm_args	: f_norm_arg ( ',' f_norm_arg )*
		;

f_norm_arg	: tCONSTANT
		| tIVAR
		| tGVAR
		| tCVAR
		| tIDENTIFIER
		;

# RENAMED: to f_opts from f_opt_args
f_opts		: f_opt ( ',' f_opt )*
		;

f_opt		: tIDENTIFIER '=' arg
		;

f_rest_arg	: '*' { tIDENTIFIER }
		;

f_block_arg	: '&' tIDENTIFIER
		;

singleton	: var_ref
		| '(' expr { nl } ')'
		;

assoc_list	: { ( assocs | args ) trailer }
		;

assocs		: assoc ( ',' assoc )*
		;

assoc		: arg '=>' arg
		;

operation	: tIDENTIFIER
		| tCONSTANT
		| tFID
		;

operation2	: tIDENTIFIER
		| tCONSTANT
		| tFID
		| op
		;

operation3	: tIDENTIFIER
		| tFID
		| op
		;

assignment_op	: '*=' | '**=' | '<<=' | '>>=' | '&&=' | '&=' | '||=' | '|=' | '+=' | '-=' | '/=' | '^=' | '%=' ;
dot_or_colon	: '.' | '::' ;
nl		: '\n'
trailer		: { ( nl | ',' ) } ;
term		: ';' | nl ;
