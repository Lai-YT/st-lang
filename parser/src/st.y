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
%type subscript_list subscript subprog_decl subprog_header subprog_body
%type formal_decl_list formal_decl formal_type subprog_call actual_list

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

  /* TODO */
stmt:
  var_ref ASSIGN expr
  { TRACE("var_ref := expr\n"); }
| subprog_call
  { TRACE("subprogram call\n"); }
| RETURN
  { TRACE("return\n"); }
| RESULT expr
  { TRACE("result expr\n"); }
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
  subprog_header subprog_body END ID
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

subprog_body:
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
  { TRACE("declaration\n\n"); }
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
  ID
  { TRACE("%s\n", $1->name); }
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

  /* TODO */
expr:
  var_ref
  { TRACE("expression\n"); }
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

%%

void yyerror(const char *msg) {
  fprintf(stderr, "line %d on symbol '%s': %s\n", yylineno, yytext, msg);
}
