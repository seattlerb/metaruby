program		: compstmt
		;

compstmt	: stmts opt_terms
		;

stmts		: none
		| stmt
		| stmts terms stmt
		| error stmt
		;

stmt		: kALIAS fitem fitem
		| kALIAS tGVAR tGVAR
		| kALIAS tGVAR tBACK_REF
		| kALIAS tGVAR tNTH_REF
		| kUNDEF undef_list
		| stmt kIF_MOD expr
		| stmt kUNLESS_MOD expr
		| stmt kWHILE_MOD expr
		| stmt kUNTIL_MOD expr
		| stmt kRESCUE_MOD stmt
		| klBEGIN
		  '{' compstmt '}'
		| klEND '{' compstmt '}'
		| lhs '=' command_call
		| mlhs '=' command_call
		| lhs '=' mrhs_basic
		| expr
		;

expr		: mlhs '=' mrhs
		| kRETURN ret_args
		| command_call
		| expr kAND expr
		| expr kOR expr
		| kNOT expr
		| '!' command_call
		| arg
		;

command_call	: command
		| block_command
		;

block_command	: block_call
		| block_call '.' operation2 command_args
		| block_call tCOLON2 operation2 command_args
		;

command		:  operation command_args
		| primary '.' operation2 command_args
		| primary tCOLON2 operation2 command_args
		| kSUPER command_args
		| kYIELD ret_args
		;

mlhs		: mlhs_basic
		| tLPAREN mlhs_entry ')'
		;

mlhs_entry	: mlhs_basic
		| tLPAREN mlhs_entry ')'
		;

mlhs_basic	: mlhs_head
		| mlhs_head mlhs_item
		| mlhs_head tSTAR mlhs_node
		| mlhs_head tSTAR
		| tSTAR mlhs_node
		| tSTAR
		;

mlhs_item	: mlhs_node
		| tLPAREN mlhs_entry ')'
		;

mlhs_head	: mlhs_item ','
		| mlhs_head mlhs_item ','
		;

mlhs_node	: variable
		| primary '[' aref_args ']'
		| primary '.' tIDENTIFIER
		| primary tCOLON2 tIDENTIFIER
		| primary '.' tCONSTANT
		| backref
		;

lhs		: variable
		| primary '[' aref_args ']'
		| primary '.' tIDENTIFIER
		| primary tCOLON2 tIDENTIFIER
		| primary '.' tCONSTANT
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

fitem		: fname
		| symbol
		;

undef_list	: fitem

		| undef_list ',' fitem
		;

op		: '|' 
		| '^' 
		| '&' 
		| tCMP 
		| tEQ 
		| tEQQ 
		| tMATCH 
		| '>' 
		| tGEQ 
		| '<' 
		| tLEQ 
		| tLSHFT 
		| tRSHFT 
		| '+' 
		| '-' 
		| '*' 
		| tSTAR 
		| '/' 
		| '%' 
		| tPOW 
		| '~' 
		| tUPLUS 
		| tUMINUS 
		| tAREF 
		| tASET 
		| '`' 
		;

reswords	: k__LINE__ | k__FILE__  | klBEGIN | klEND
		| kALIAS | kAND | kBEGIN | kBREAK | kCASE | kCLASS | kDEF
		| kDEFINED | kDO | kELSE | kELSIF | kEND | kENSURE | kFALSE
		| kFOR | kIF_MOD | kIN | kMODULE | kNEXT | kNIL | kNOT
		| kOR | kREDO | kRESCUE | kRETRY | kRETURN | kSELF | kSUPER
		| kTHEN | kTRUE | kUNDEF | kUNLESS_MOD | kUNTIL_MOD | kWHEN
		| kWHILE_MOD | kYIELD | kRESCUE_MOD
		;

arg		: lhs '=' arg
		| variable tOP_ASGN arg
		| primary '[' aref_args ']' tOP_ASGN arg
		| primary '.' tIDENTIFIER tOP_ASGN arg
		| primary '.' tCONSTANT tOP_ASGN arg
		| primary tCOLON2 tIDENTIFIER tOP_ASGN arg
		| backref tOP_ASGN arg
		| arg tDOT2 arg
		| arg tDOT3 arg
		| arg '+' arg
		| arg '-' arg
		| arg '*' arg
		| arg '/' arg
		| arg '%' arg
		| arg tPOW arg
		| tUPLUS arg
		| tUMINUS arg
		| arg '|' arg
		| arg '^' arg
		| arg '&' arg
		| arg tCMP arg
		| arg '>' arg
		| arg tGEQ arg
		| arg '<' arg
		| arg tLEQ arg
		| arg tEQ arg
		| arg tEQQ arg
		| arg tNEQ arg
		| arg tMATCH arg
		| arg tNMATCH arg
		| '!' arg
		| '~' arg
		| arg tLSHFT arg
		| arg tRSHFT arg
		| arg tANDOP arg
		| arg tOROP arg
		| kDEFINED opt_nl arg
		| arg '?' arg ':' arg
		| primary
		;

aref_args	: none
		| command_call opt_nl
		| args ',' command_call opt_nl
		| args trailer
		| args ',' tSTAR arg opt_nl
		| assocs trailer
		| tSTAR arg opt_nl
		;

paren_args	: '(' none ')'
		| '(' call_args opt_nl ')'
		| '(' block_call opt_nl ')'
		| '(' args ',' block_call opt_nl ')'
		;

opt_paren_args	: none
		| paren_args
		;

call_args	: command
		| args ',' command
		| args opt_block_arg
		| args ',' tSTAR arg opt_block_arg
		| assocs opt_block_arg
		| assocs ',' tSTAR arg opt_block_arg
		| args ',' assocs opt_block_arg
		| args ',' assocs ',' tSTAR arg opt_block_arg
		| tSTAR arg opt_block_arg
		| block_arg
		;

command_args	: call_args
		;

block_arg	: tAMPER arg
		;

opt_block_arg	: ',' block_arg
		| none
		;

args 		: arg
		| args ',' arg
		;

mrhs		: arg
		| mrhs_basic
		;

mrhs_basic	: args ',' arg
		| args ',' tSTAR arg
		| tSTAR arg
		;

ret_args	: call_args
		;

primary		: literal
		| string
		| tXSTRING
		| tQWORDS
		| tDXSTRING
		| tDREGEXP
		| var_ref
		| backref
		| tFID
		| kBEGIN
		  compstmt
		  rescue
		  opt_else
		  ensure
		  kEND
		| tLPAREN compstmt ')'
		| primary tCOLON2 tCONSTANT
		| tCOLON3 cname
		| primary '[' aref_args ']'
		| tLBRACK aref_args ']'
		| tLBRACE assoc_list '}'
		| kRETURN '(' ret_args ')'
		| kRETURN '(' ')'
		| kRETURN
		| kYIELD '(' ret_args ')'
		| kYIELD '(' ')'
		| kYIELD
		| kDEFINED opt_nl '(' expr ')'
		| operation brace_block
		| method_call
		| method_call brace_block
		| kIF expr then
		  compstmt
		  if_tail
		  kEND
		| kUNLESS expr then
		  compstmt
		  opt_else
		  kEND
		| kWHILE expr do 
		  compstmt
		  kEND
		| kUNTIL expr do 
		  compstmt
		  kEND
		| kCASE expr opt_terms
		  case_body
		  kEND
		| kCASE opt_terms case_body kEND
		| kFOR block_var kIN expr do 
		  compstmt
		  kEND
		| kCLASS cname superclass
		  compstmt
		  kEND
		| kCLASS tLSHFT expr
		  term
		  compstmt
		  kEND
		| kMODULE cname
		  compstmt
		  kEND
		| kDEF fname
		  f_arglist
		  compstmt
		  rescue
		  opt_else
		  ensure
		  kEND
		| kDEF singleton dot_or_colon fname
		  f_arglist
		  compstmt
		  rescue
		  opt_else
		  ensure
		  kEND
		| kBREAK
		| kNEXT
		| kREDO
		| kRETRY
		;

then		: term
		| kTHEN
		| term kTHEN
		;

do		: term
		| kDO_COND
		;

if_tail		: opt_else
		| kELSIF expr then
		  compstmt
		  if_tail
		;

opt_else	: none
		| kELSE compstmt
		;

block_var	: lhs
		| mlhs
		;

opt_block_var	: none
		| '|' /* none */ '|'
		| tOROP
		| '|' block_var '|'
		;


do_block	: kDO_BLOCK
		  opt_block_var
		  compstmt
		  kEND
		;

block_call	: command do_block
		| block_call '.' operation2 opt_paren_args
		| block_call tCOLON2 operation2 opt_paren_args
		;

method_call	: operation paren_args
		| primary '.' operation2 opt_paren_args
		| primary tCOLON2 operation2 paren_args
		| primary tCOLON2 operation3
		| kSUPER paren_args
		| kSUPER
		;

brace_block	: '{'
		  opt_block_var
		  compstmt '}'
		| kDO
		  opt_block_var
		  compstmt kEND
		;

case_body	: kWHEN when_args then
		  compstmt
		  cases
		;

when_args	: args
		| args ',' tSTAR arg
		| tSTAR arg
		;

cases		: opt_else
		| case_body
		;

exc_list	: none
		| args
		;

exc_var		: tASSOC lhs
		| none
		;

rescue		: kRESCUE exc_list exc_var then
		  compstmt
		  rescue
		| none
		;

ensure		: none
		| kENSURE compstmt
		;

literal		: numeric
		| symbol
		| tREGEXP
		;

string		: tSTRING
		| tDSTRING
		| string tSTRING
		| string tDSTRING
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

backref		: tNTH_REF
		| tBACK_REF
		;

superclass	: term
		| '<'
		  expr term
		| error term 
		;

f_arglist	: '(' f_args opt_nl ')'
		| f_args term
		;

f_args		: f_arg ',' f_optarg ',' f_rest_arg opt_f_block_arg
		| f_arg ',' f_optarg opt_f_block_arg
		| f_arg ',' f_rest_arg opt_f_block_arg
		| f_arg opt_f_block_arg
		| f_optarg ',' f_rest_arg opt_f_block_arg
		| f_optarg opt_f_block_arg
		| f_rest_arg opt_f_block_arg
		| f_block_arg
		| /* none */
		;

f_norm_arg	: tCONSTANT
                | tIVAR
                | tGVAR
                | tCVAR
		| tIDENTIFIER
		;

f_arg		: f_norm_arg
		| f_arg ',' f_norm_arg
		;

f_opt		: tIDENTIFIER '=' arg
		;

f_optarg	: f_opt
		| f_optarg ',' f_opt
		;

f_rest_arg	: tSTAR tIDENTIFIER
		| tSTAR
		;

f_block_arg	: tAMPER tIDENTIFIER
		;

opt_f_block_arg	: ',' f_block_arg
		| none
		;

singleton	: var_ref
		| '(' expr opt_nl ')'
		;

assoc_list	: none
		| assocs trailer
		| args trailer
		;

assocs		: assoc
		| assocs ',' assoc
		;

assoc		: arg tASSOC arg
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

dot_or_colon	: '.'
		| tCOLON2
		;

opt_terms	:
		| terms
		;

opt_nl		:
		| '\n'
		;

trailer		:
		| '\n'
		| ','
		;

term		: ';' 
		| '\n'
		;

terms		: term
		| terms ';' 
		;

none		: /* none */
		;
