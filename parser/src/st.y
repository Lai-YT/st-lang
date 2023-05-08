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

%type program decl_or_stmt_list decl_or_stmt decl stmt var_decl var_ref expr
%type array_type scalar_type type const_decl


%%
program:
  decl_or_stmt_list
  { TRACE("[program]\n"); }
| /* empty */
  { TRACE("empty program\n"); }
;

decl_or_stmt_list:
  decl_or_stmt_list decl_or_stmt
  { ; }
| decl_or_stmt
  { ; }
;

decl_or_stmt:
  decl
  { TRACE("declaration\n\n"); }
| stmt
  { TRACE("statement\n\n"); }
;

  /* TODO */
decl:
  var_decl
  { TRACE("variable declaration\n"); }
| const_decl
  { TRACE("constant declaration\n"); }
;

  /* TODO */
stmt:
  var_ref
  { TRACE("variable reference\n"); }
;

var_decl:
  VAR ID ASSIGN expr
  { TRACE("var %s = expr\n", $2->name); }
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

  /* TODO */
var_ref:
  ID
  { TRACE("%s\n", $1->name); }
;

  /* TODO */
expr:
  var_ref
  { TRACE("expression\n"); }
| INT_CONST
  { TRACE("%d\n", $1); }
;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "line %d on symbol '%s': %s\n", yylineno, yytext, msg);
}
