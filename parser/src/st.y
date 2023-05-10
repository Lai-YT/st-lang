%{
  #include <stdio.h>
  #include <string.h>
  #include "symtab.h"

  typedef Entry* Symbol;

  #define TRACE(...)  fprintf(stderr, __VA_ARGS__)

  void yyerror(const char *s);  /*  defined below; called for each parse error */
  extern int yylex();           /*  the entry point to the lexer  */
  extern int yylineno;
  extern char yytext[];
%}
%define parse.error detailed
%union {
  Symbol symbol;
  char str_const[256];
  int int_const;
  double real_const;
}

/* tokens */
%token ARRAY 258 BEGIN_ 259 BOOL 260 CHAR 261 CONST 262 DECREASING 263 DEFAULT 264
%token DO 265 ELSE 266 END 267 EXIT 268 FALSE 269 FOR 270 FUNCTION 271 GET 272 IF 273
%token INT 274 LOOP 275 OF 276 PUT 277 PROCEDURE 278 REAL 279 RESULT 280 RETURN 281
%token SKIP 282 STRING 283 THEN 284 TRUE 285 VAR 286 WHEN 287
%token <symbol> ID 288
%token <str_const> STR_CONST 289
%token <int_const> INT_CONST 290
%token <real_const> REAL_CONST 291
%token AND 292 OR 293 MOD 294 LE 295 GE 296 NOT 297 ASSIGN 298 NE 299

%type program decl_or_stmt_in_main_program_list decl_or_stmt_in_main_program
%type decl_or_stmt_list decl_or_stmt decl stmt var_decl var_ref expr
%type array_type scalar_type type const_decl explicit_const bool_const
%type subscript_list subscript subprog_decl subprog_header opt_decl_or_stmt_list
%type formal_decl_list formal_decl formal_type subprog_call actual_list if_stmt
%type bool_expr operation numeric_operation comparison_operation boolean_operation
%type sign_operation exit_stmt loop_stmt for_stmt block get_stmt put_stmt
%type get_item_list get_item put_item_list put_item

  /* lowest to highest */
%left OR
%left AND
%right NOT
%left BOOLEAN_OP
%left '<' '>' '=' LE GE NE
%left COMPARISON_OP
%left '+' '-'
%left '*' '/' MOD
%left NUMERIC_OP
%right SIGN_OP


%%
program:
  decl_or_stmt_in_main_program_list
  { TRACE("[program]\n"); }
| /* empty */
  { TRACE("empty program\n"); }
;

decl_or_stmt_in_main_program_list:
  decl_or_stmt_in_main_program_list decl_or_stmt_in_main_program
  { ; }
| decl_or_stmt_in_main_program
  { ; }
;

  /*
   * subprog_decl can only appear in the main program level.
   * Separate it from normal decl_or_stmt.
   */
decl_or_stmt_in_main_program:
  decl_or_stmt
  { ; }
| subprog_decl
  { TRACE("subprogram declaration\n\n"); }
;

decl:
  var_decl
  { TRACE("variable declaration\n"); }
| const_decl
  { TRACE("constant declaration\n"); }
;

stmt:
  var_ref ASSIGN expr
  { TRACE("var_ref := expr\n"); }
| subprog_call
  { TRACE("subprogram call\n"); }
| RETURN
  { TRACE("return\n"); }
| RESULT expr
  { TRACE("result expr\n"); }
| if_stmt
  { TRACE("if statement\n"); }
| exit_stmt
  { ; }
| loop_stmt
  { ; }
| for_stmt
  { ; }
| block
  { ; }
| get_stmt
  { ; }
| put_stmt
  { ; }
;

var_decl:
  VAR ID ASSIGN expr
  { TRACE("var %s := expr\n", $2->name); }
| VAR ID ':' array_type
  { TRACE("var %s: array_type\n", $2->name); }
| VAR ID ':' scalar_type
  { TRACE("var %s: scalar_type\n", $2->name); }
| VAR ID ':' scalar_type ASSIGN expr
  { TRACE("var %s: scalar_type := expr\n", $2->name); }
;

const_decl:
  CONST ID ASSIGN expr
  { TRACE("const %s = expr\n", $2->name); }
| CONST ID ':' scalar_type ASSIGN expr
  { TRACE("const %s: scalar_type := expr\n", $2->name); }
;

subprog_decl:
  subprog_header opt_decl_or_stmt_list END ID
  { ; }
;

subprog_header:
  PROCEDURE ID
  { TRACE("procedure %s with no param\n", $2->name); }
| PROCEDURE ID '(' formal_decl_list ')'
  { TRACE("procedure %s with params\n", $2->name); }
| FUNCTION ID ':' type
  { TRACE("procedure %s: type with no param\n", $2->name); }
| FUNCTION ID '(' formal_decl_list ')' ':' type
  { TRACE("procedure %s: type with params\n", $2->name); }
;

opt_decl_or_stmt_list:
  decl_or_stmt_list
  { ; }
| /* empty */
  { ; }
;

decl_or_stmt_list:
  decl_or_stmt_list decl_or_stmt
  {}
| decl_or_stmt
  {}
;

decl_or_stmt:
  decl
  { TRACE("declaration\n\n"); }
| stmt
  { TRACE("statement\n\n"); }
;

formal_decl_list:
  formal_decl_list ',' formal_decl
  { ; }
| formal_decl
  { ; }
;

formal_decl:
  ID ':' formal_type
  { TRACE("%s: formal_type\n", $1->name); }
| VAR ID ':' formal_type
  { TRACE("var %s: formal_type\n", $2->name); }
;

formal_type:
  type
  { TRACE("type\n"); }
| STRING '(' '*' ')'
  { TRACE("string(*)\n"); }
| ARRAY expr '.' '.' '*' OF type
  { TRACE("array of type\n"); }
| ARRAY expr '.' '.' '*' OF STRING '(' '*' ')'
  { TRACE("array of string(*)\n"); }
;

subprog_call:
  ID
  { TRACE("%s\n", $1->name); }
| ID '(' actual_list ')'
  { TRACE("%s()\n", $1->name); }
;

actual_list:
  actual_list ',' expr
  { ; }
| expr
  { ; }
;

if_stmt:
  IF bool_expr THEN opt_decl_or_stmt_list END IF
  { TRACE("if-then\n"); }
| IF bool_expr THEN opt_decl_or_stmt_list ELSE opt_decl_or_stmt_list END IF
  { TRACE("if-then-else\n"); }
;

exit_stmt:
  EXIT
  { ; }
| EXIT WHEN bool_expr
  { ; }
;

loop_stmt:
  LOOP opt_decl_or_stmt_list END LOOP
  { ; }
;

for_stmt:
  FOR ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  { ; }
| FOR ID ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  { ; }
| FOR DECREASING ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  { ; }
| FOR DECREASING ID ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  { ; }
;

block:
  BEGIN_ opt_decl_or_stmt_list END
  { ; }
;

get_stmt:
  GET get_item_list
  { ; }
;

get_item_list:
  get_item_list ',' get_item
  { ; }
| get_item
  { ; }
;

get_item:
  var_ref
  { ; }
| SKIP
  { ; }
;

put_stmt:
  PUT put_item_list
  { ; }
| PUT put_item_list '.' '.'
  { ; }
;

put_item_list:
  put_item_list ',' put_item
  { ; }
| put_item
  { ; }
;

put_item:
  expr
  { ; }
| SKIP
  { ; }
;

bool_expr:
  var_ref
  { TRACE("variable reference\n"); }
| bool_const
  { TRACE("bool\n"); }
| comparison_operation %prec COMPARISON_OP
  { TRACE("comparison operation\n"); }
| boolean_operation %prec BOOLEAN_OP
  { TRACE("boolean operation\n"); }
  /* FIXME: reduce/reduce conflict with (expr) */
| '(' bool_expr ')'
  { TRACE("(bool_expr)\n"); }
;

scalar_type:
  INT
  { TRACE("int\n"); }
| REAL
  { TRACE("real\n"); }
| BOOL
  { TRACE("bool\n"); }
| STRING
  { TRACE("string\n"); }
| STRING '(' expr ')'
  { TRACE("string(expr)\n"); }
;

array_type:
  ARRAY expr '.' '.' expr OF type
  { TRACE("array expr..expr of type\n"); }
;

type:
  scalar_type
  { TRACE("scalar_type\n"); }
| array_type
  { TRACE("array_type\n"); }
;

var_ref:
  /*
   * NOTE: a single ID can also be a subprogram call
   */
  ID
  { TRACE("%s\n", $1->name); }
  /*
   * NOTE: a ID subscripting can also be a substring
   */
| ID subscript_list
  { TRACE("%s", $1->name); }
;

subscript_list:
  subscript_list subscript
  { ; }
| subscript
  { ; }
;

subscript:
  '[' expr ']'
  { TRACE("[]\n"); }
;

expr:
  var_ref
  { TRACE("variable reference\n"); }
| explicit_const
  { TRACE("explicit constant\n"); }
  /*
   * Here a hack on the ambiguous grammar:
   *  Since an variable reference and a subprogram call may both be a single ID,
   *  directly placing a subprog_call non-terminal here causes a reduce/reduce conflict.
   *  The workaround is the put the rules of subprog_call except ID here.
   *  This implies that a subprog_call with ID is treated as an var_ref and
   *  should be resolved further semantically.
   */
| ID '(' actual_list ')'
  { TRACE("subprogram call\n"); }
  /*
   * Here a hack on the ambiguous grammar:
   *  Since an array subscripting of variable reference and a substring may both be ID[expr],
   *  directly placing a substring non-terminal here causes a reduce/reduce conflict.
   *  The workaround is the put other rules of substring here.
   *  This implies that a substring in the form ID[expr] is treated as an var_ref and
   *  should be resolved further semantically.
   */
| ID '[' expr '.' '.' expr ']'
  { TRACE("substring\n"); }
| operation
  { TRACE("operation\n"); }
| '(' expr ')'
  { TRACE("(expr)\n"); }
;

explicit_const:
  INT_CONST
  { TRACE("int_const: %d\n", $1); }
| REAL_CONST
  { TRACE("real_const: %f\n", $1); }
| STR_CONST
  { TRACE("str_const: %s\n", $1); }
| bool_const
  { TRACE("bool_const: "); }
;

bool_const:
  TRUE
  { TRACE("true\n"); }
| FALSE
  { TRACE("false\n"); }
;

operation:
  numeric_operation %prec NUMERIC_OP
  { TRACE("numeric operation\n"); }
| comparison_operation %prec COMPARISON_OP
  { TRACE("comparison operation\n"); }
| boolean_operation %prec BOOLEAN_OP
  { TRACE("boolean operation\n"); }
| sign_operation %prec SIGN_OP
  { TRACE("sign operation\n"); }
;

numeric_operation:
  expr '+' expr {}
| expr '-' expr {}
| expr '*' expr {}
| expr '/' expr {}
| expr MOD expr {}
;

comparison_operation:
  expr '<' expr {}
| expr '>' expr {}
| expr '=' expr {}
| expr LE expr {}
| expr GE expr {}
| expr NE expr {}
;

  /*
   * NOTE: enforcing semantic here with bool_expr instead of expr causes
   * reduce/reduce error, since bool_expr is a subset of expr, and
   * boolean_operation belongs to both of them.
   */
boolean_operation:
  expr AND expr {}
| expr OR expr {}
| NOT expr {}
;

sign_operation:
  '+' expr {}
| '-' expr {}
;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "line %d on symbol '%s': %s\n", yylineno, yytext, msg);
}
