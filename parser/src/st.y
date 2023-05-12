%{
  #include <stdio.h>
  #include <string.h>

  #include "st-lex.h"
  #include "symtab.h"

  #define TRACE(...)  fprintf(stderr, __VA_ARGS__)

  void yyerror(const char *s);  /*  defined below; called for each parse error */
%}
%define parse.error detailed
%union {
  Symbol* symbol;
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
%type opt_formal_decl_list formal_decl_list formal_decl formal_type subprog_call if_stmt
%type bool_expr operation numeric_operation comparison_operation boolean_operation
%type sign_operation exit_stmt loop_stmt for_stmt block get_stmt put_stmt
%type var_ref_comma_list expr_comma_list

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
  { ; }
| /* empty */
  { ; }
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
  { ; }
;

decl:
  var_decl
  { ; }
| const_decl
  { ; }
;

stmt:
  var_ref ASSIGN expr
  { ; }
| subprog_call
  { ; }
| RETURN
  { ; }
| RESULT expr
  { ; }
| if_stmt
  { ; }
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
| SKIP
  { ; }
;

var_decl:
  VAR ID ASSIGN expr
  { ; }
| VAR ID ':' array_type
  { ; }
| VAR ID ':' scalar_type
  { ; }
| VAR ID ':' scalar_type ASSIGN expr
  { ; }
;

const_decl:
  CONST ID ASSIGN expr
  { ; }
| CONST ID ':' scalar_type ASSIGN expr
  { ; }
;

subprog_decl:
  subprog_header opt_decl_or_stmt_list END ID
  { ; }
;

subprog_header:
  PROCEDURE ID '(' opt_formal_decl_list ')'
  { ; }
| FUNCTION ID '(' opt_formal_decl_list ')' ':' type
  { ; }
;

opt_decl_or_stmt_list:
  decl_or_stmt_list
  { ; }
| /* empty */
  { ; }
;

decl_or_stmt_list:
  decl_or_stmt_list decl_or_stmt
  { ; }
| decl_or_stmt
  { ; }
;

decl_or_stmt:
  decl
  { ; }
| stmt
  { ; }
;

opt_formal_decl_list:
  formal_decl_list
  { ; }
| /* empty */
  { ; }
;

formal_decl_list:
  formal_decl_list ',' formal_decl
  { ; }
| formal_decl
  { ; }
;

formal_decl:
  ID ':' formal_type
  { ; }
| VAR ID ':' formal_type
  { ; }
;

formal_type:
  type
  { ; }
| STRING '(' '*' ')'
  { ; }
| ARRAY expr '.' '.' '*' OF type
  { ; }
| ARRAY expr '.' '.' '*' OF STRING '(' '*' ')'
  { ; }
;

subprog_call:
  ID '(' ')'
  { ; }
| ID '(' expr_comma_list ')'
  { ; }
;

if_stmt:
  IF bool_expr THEN opt_decl_or_stmt_list END IF
  { ; }
| IF bool_expr THEN opt_decl_or_stmt_list ELSE opt_decl_or_stmt_list END IF
  { ; }
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
  GET var_ref_comma_list
  { ; }
;

var_ref_comma_list:
  var_ref_comma_list ',' var_ref
  { ; }
| var_ref
  { ; }
;

put_stmt:
  PUT expr_comma_list
  { ; }
| PUT expr_comma_list '.' '.'
  { ; }
;

expr_comma_list:
  expr_comma_list ',' expr
  { ; }
| expr
  { ; }
;

bool_expr:
  var_ref
  { ; }
| bool_const
  { ; }
| comparison_operation %prec COMPARISON_OP
  { ; }
| boolean_operation %prec BOOLEAN_OP
  { ; }
  /*
   * NOTE: using '(' bool_expr ')' makes the grammar not LALR(1):
   *  If there's another operator after ')', the expression is an expr,
   *  otherwise a bool_expr.
   * However, that requires 2 lookahead.
   * Non-LALR(1) causes reduce/reduce conflicts.
   * Make it also a '(' expr ')' to resolve the conflicts.
   */
| '(' expr ')'
  { ; }
;

scalar_type:
  INT
  { ; }
| REAL
  { ; }
| BOOL
  { ; }
| STRING
  { ; }
| STRING '(' expr ')'
  { ; }
;

array_type:
  ARRAY expr '.' '.' expr OF type
  { ; }
;

type:
  scalar_type
  { ; }
| array_type
  { ; }
;

var_ref:
  ID
  { ; }
  /*
   * NOTE: a ID subscripting can also be a substring
   */
| ID subscript_list
  { ; }
;

subscript_list:
  subscript_list subscript
  { ; }
| subscript
  { ; }
;

subscript:
  '[' expr ']'
  { ; }
;

expr:
  var_ref
  { ; }
| explicit_const
  { ; }
| subprog_call
  { ; }
  /*
   * Here a hack on the ambiguous grammar:
   *  Since an array subscripting of variable reference and a substring may both be ID[expr],
   *  directly placing a substring non-terminal here causes a reduce/reduce conflict.
   *  The workaround is the put other rules of substring here.
   *  This implies that a substring in the form ID[expr] is treated as an var_ref and
   *  should be resolved further semantically.
   */
| ID '[' expr '.' '.' expr ']'
  { ; }
| operation
  { ; }
| '(' expr ')'
  { ; }
;

explicit_const:
  INT_CONST
  { ; }
| REAL_CONST
  { ; }
| STR_CONST
  { ; }
| bool_const
  { ; }
;

bool_const:
  TRUE
  { ; }
| FALSE
  { ; }
;

operation:
  numeric_operation %prec NUMERIC_OP
  { ; }
| comparison_operation %prec COMPARISON_OP
  { ; }
| boolean_operation %prec BOOLEAN_OP
  { ; }
| sign_operation %prec SIGN_OP
  { ; }
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
