%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #include "semant.h"
  #include "semant_macros.h"
  #include "st-lex.h"
  #include "symtab.h"

  extern SymbolTable* scope;

  void yyerror(const char *s);  /*  defined below; called for each parse error */
%}
%define parse.error detailed
%union {
  Symbol* symbol;
  char str_const[256];
  int int_const;
  double real_const;
  Expression* expr;
  CompileTimeExpression* compile_time_expr;
  ConstIdentifier* const_id;
  Reference* ref;
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

%type <expr> expr
%type <compile_time_expr> bool_const explicit_const
%type <const_id> const_decl
%type <ref> var_ref

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
  {
    /*
     * (1) new block scope with subprogram table
     */
  }
| /* empty */
  { /* no check */ }
;

decl_or_stmt_in_main_program_list:
  decl_or_stmt_in_main_program_list decl_or_stmt_in_main_program
  { /* no check */ }
| decl_or_stmt_in_main_program
  { /* no check */ }
;

  /*
   * subprog_decl can only appear in the main program level.
   * Separate it from normal decl_or_stmt.
   */
decl_or_stmt_in_main_program:
  decl_or_stmt
  { /* no check */ }
| subprog_decl
  { /* no check */ }
;

decl:
  var_decl
  {
    /*
     * (1) re-declaration error if name exists in the current scope
     * (2) the identifier should be recorded under the scope
     * (3) the identifier should be marked as mutable
     */
  }
| const_decl
  {
    /*
     * (1) re-declaration error if name exists in the current scope
     * (2) the identifier should be recorded under the scope
     * (3) the identifier should be marked as constant
     */
    // (1)
    if (symtab_lookup(scope, $1->name)) {
      ST_FATAL_ERROR("error: re-declaration of identifier '%s'\n", $1->name);
    }
    Identifier* id = malloc(sizeof(Identifier));
    // (3)
    id->id_type = ST_CONST_IDENTIFIER;
    id->const_id = $1;
    // (2)
    symtab_insert(scope, $1->name, id);
  }
;

stmt:
  var_ref ASSIGN expr
  {
    /*
     * (1) the type of the variable reference has to be the same as the expression
     * (2) the reference should be of a mutable variable
     */
    if ($1->ref_type == ST_IDENTIFIER_REFERENCE) {
      // (2)
      if ($1->id_ref->id_type == ST_CONST_IDENTIFIER) {
        ST_FATAL_ERROR("error: assign to const '%s'\n", $1->id_ref->const_id->name);
      }
      // TODO: type compare
    } else if ($1->ref_type == ST_ARRAY_SUBSCRIPT_REFERENCE) {
      // (2)
      if ($1->array_subscript_ref->is_const) {
        // we don't know the name of the array
        ST_FATAL_ERROR("error: assign to const\n");
      }
      // TODO: type compare
    } else {
      ST_UNREACHABLE();
    }
  }
| subprog_call
  { /* no check */ }
| RETURN
  {
    /*
     * (1) has to be inside the scope of a procedure
     */
  }
| RESULT expr
  {
    /*
     * (1) has to be inside the scope of a function
     * (2) expr must have the same type as the declared result type
     * (3) record the occurrence to the function scope
     */
  }
| if_stmt
  { /* no check */ }
| exit_stmt
  {
    /*
     * (1) has to be inside a loop or a for statement
     */
  }
| loop_stmt
  {
    /*
     * (1) new block scope
     */
  }
| for_stmt
  {
    /*
     * (1) new block scope
     */
  }
| block
  {
    /*
     * (1) new block scope
     */
  }
| get_stmt
  { /* no check */ }
| put_stmt
  { /* no check */ }
| SKIP
  { /* no check */ }
;

var_decl:
  VAR ID ASSIGN expr
  { /* no check */ }
| VAR ID ':' array_type
  { /* no check */ }
| VAR ID ':' scalar_type
  { /* no check */ }
| VAR ID ':' scalar_type ASSIGN expr
  {
    /*
     * (1) the expression has the same type as scalar_type
     */
  }
;

  /*
   * Returns a ConstIdentifier.
   */
const_decl:
  CONST ID ASSIGN expr
  {
    /*
     * (1) the expression is not a variable reference in type of a dynamic array
     * (2) if the expression is a compile-time expression, the id can represent a compile-time expression
     * (3) if the expression is a compile-time expression, the value has to be recorded
     */
    // (2)
    $$ = malloc(sizeof(ConstIdentifier));
    $$->name = malloc(sizeof(char) * (strlen($2->name) + 1));
    strcpy($$->name, $2->name);
    if ($4->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      $$->const_id_type = ST_COMPILE_TIME_CONST_IDENTIFIER;
      $$->compile_time_const_id = malloc(sizeof(CompileTimeConstIdentifier));
      $$->compile_time_const_id->data_type = $4->compile_time_expr->data_type;
      // (3)
      switch ($4->compile_time_expr->data_type) {
        case ST_INT_TYPE:
          $$->compile_time_const_id->int_val = $4->compile_time_expr->int_val;
          break;
        case ST_REAL_TYPE:
          $$->compile_time_const_id->real_val = $4->compile_time_expr->real_val;
          break;
        case ST_BOOL_TYPE:
          $$->compile_time_const_id->bool_val = $4->compile_time_expr->bool_val;
          break;
        case ST_STRING_TYPE:
          $$->compile_time_const_id->string = $4->compile_time_expr->string;
          break;
        default:
          ST_UNREACHABLE();
      }
    } else if ($4->expr_type == ST_RUN_TIME_EXPRESSION) {
      $$->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
      $$->run_time_const_id = malloc(sizeof(RunTimeConstIdentifier));
      $$->run_time_const_id->data_type = $4->run_time_expr->data_type;
      switch ($4->run_time_expr->data_type) {
        case ST_STRING_TYPE:
          $$->run_time_const_id->string = $4->run_time_expr->string;
          break;
        case ST_ARRAY_TYPE:
          // (1)
          if ($4->run_time_expr->array->array_type == ST_DYNAMIC_ARRAY) {
            ST_FATAL_ERROR("error: a constant identifier cannot be a dynamic array\n");
          }
          $$->run_time_const_id->array = $4->run_time_expr->array;
          break;
        default:
          /* other types don't have additional information to record */
          break;
      }
      /* no data to copy since its run-time determined */
    } else {
      ST_UNREACHABLE();
    }
  }
| CONST ID ':' scalar_type ASSIGN expr
  {
    /*
     * (1) the expression has the same type as scalar_type
     * (2) if the expression is a compile-time expression, the id can represent a compile-time expression
     */
  }
;

subprog_decl:
  subprog_header opt_decl_or_stmt_list END ID
  {
    /*
     * (1) id is the same name as the one in the header
     * (2) exit the scope
     */
  }
;

subprog_header:
  PROCEDURE ID '(' opt_formal_decl_list ')'
  {
    /*
     * (1) enter a procedure scope
     * (2) the name of the procedure is a declared identifier within the scope
     * (3) the types of the formals have to be recorded so can be checked on a call
     */
  }
| FUNCTION ID '(' opt_formal_decl_list ')' ':' type
  {
    /*
     * (1) enter a function scope
     * (1) the name of the function is a declared identifier within the scope
     * (2) the types of the formals and the result has to be recorded so can be checked on a call
     */
  }
;

opt_decl_or_stmt_list:
  decl_or_stmt_list
  { /* no check */ }
| /* empty */
  { /* no check */ }
;

decl_or_stmt_list:
  decl_or_stmt_list decl_or_stmt
  { /* no check */ }
| decl_or_stmt
  { /* no check */ }
;

decl_or_stmt:
  decl
  { /* no check */ }
| stmt
  { /* no check */ }
;

opt_formal_decl_list:
  formal_decl_list
  { /* no check */ }
| /* empty */
  { /* no check */ }
;

formal_decl_list:
  formal_decl_list ',' formal_decl
  { /* no check */ }
| formal_decl
  { /* no check */ }
;

formal_decl:
  ID ':' formal_type
  {
    /*
     * (1) re-declaration error if name exists in the current scope
     * (2) the identifier should be recorded under the scope marked as constant
     */
  }
| VAR ID ':' formal_type
  {
    /*
     * (1) re-declaration error if name exists in the current scope
     * (2) the identifier should be recorded under the scope marked as mutable
     */
  }
;

formal_type:
  type
  { /* no check */ }
| STRING '(' '*' ')'
  {
    /*
     * (1) the max length of the string is unknown
     */
  }
| ARRAY expr '.' '.' '*' OF type
  {
    /*
     * (1) the expression must be a compile-time expression
     */
  }
| ARRAY expr '.' '.' '*' OF STRING '(' '*' ')'
  {
    /*
     * (1) the expression must be a compile-time expression
     */
  }
;

subprog_call:
  ID '(' ')'
  {
    /*
     * (1) the subprogram which the id indicates should take no parameter
     */
  }
| ID '(' expr_comma_list ')'
  {
    /*
     * (1) the number of the expression should match the number of the declared formals
     * (2) each expressions in the list should have their types match the declared formal types
     */
  }
;

if_stmt:
  IF bool_expr THEN opt_decl_or_stmt_list END IF
  {
    /*
     * (1) new block scope
     */
  }
| IF bool_expr THEN opt_decl_or_stmt_list ELSE opt_decl_or_stmt_list END IF
  {
    /*
     * (1) new block scope for then
     * (2) new block scope for else
     */
  }
;

exit_stmt:
  EXIT
  { /* no check */ }
| EXIT WHEN bool_expr
  { /* no check */ }
;

loop_stmt:
  LOOP opt_decl_or_stmt_list END LOOP
  { /* no check */ }
;

for_stmt:
  FOR ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  {
    /*
     * (1) the expressions must be both of type int
     * (2) the second expression can't be smaller than the first one
     */
  }
| FOR ID ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  {
    /*
     * (1) the expressions must be both of type int
     * (2) the second expression can't be smaller than the first one
     * (3) add id into the scope and marked as constant
     */
  }
| FOR DECREASING ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  {
    /*
     * (1) the expressions must be both of type int
     * (2) the first expression can't be smaller than the second one
     */
  }
| FOR DECREASING ID ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  {
    /*
     * (1) the expressions must be both of type int
     * (2) the first expression can't be smaller than the second one
     * (3) add id into the scope and marked as constant
     */
  }
;

block:
  BEGIN_ opt_decl_or_stmt_list END
  { /* no check */ }
;

get_stmt:
  GET var_ref_comma_list
  {
    /*
     * (1) all variable references should be mutable
     * (2) no variable reference can be in type array
     */
  }
;

var_ref_comma_list:
  var_ref_comma_list ',' var_ref
  { /* no check */ }
| var_ref
  { /* no check */ }
;

put_stmt:
  PUT expr_comma_list
  {
    /*
     * (1) no expression can be in type array
     */
  }
| PUT expr_comma_list '.' '.'
  {
    /*
     * (1) no expression can be in type array
     */
  }
;

expr_comma_list:
  expr_comma_list ',' expr
  { /* no check */ }
| expr
  { /* no check */ }
;

bool_expr:
  var_ref
  {
    /*
     * (1) the reference must be of a variable in type bool
     */
  }
| bool_const
  { /* no check */ }
| comparison_operation %prec COMPARISON_OP
  { /* no check */ }
| boolean_operation %prec BOOLEAN_OP
  { /* no check */ }
  /*
   * NOTE: using '(' bool_expr ')' makes the grammar not LALR(1):
   *  If there's another operator after ')', the expression is an expr,
   *  otherwise a bool_expr.
   * However, that requires 2 lookahead.
   * Non-LALR(1) causes reduce/reduce conflicts.
   * Make it also a '(' expr ')' to resolve the conflicts.
   */
| '(' expr ')'
  {
    /*
     * (1) the expression should have type bool
     */
  }
;

scalar_type:
  INT
  { /* no check */ }
| REAL
  { /* no check */ }
| BOOL
  { /* no check */ }
| STRING
  {
    /*
     * (1) the max length of the string is 255
     */
  }
| STRING '(' expr ')'
  {
    /*
     * (1) the expression must have type int
     * (2) the expression must be a compile-time expression
     * (3) the expression must be positive
     * (4) the expression can't be greater than 255
     */
  }
;

array_type:
  ARRAY expr '.' '.' expr OF type
  {
    /*
     * (1) the expression must be a compile-time expression
     * (2) type may also be an array, but the upper bound of a nested array has
     *     to be a compile-time expression as also, which means we have to record
     *     the bounds of an array type. This is also for type equality checks
     */
  }
;

type:
  scalar_type
  { /* no check */ }
| array_type
  { /* no check */ }
;

  /*
   * Returns a Reference.
   */
var_ref:
  ID
  {
    /*
     * (1) the id has to be declared
     * (2) the id can't be a subprogram
     */
    Symbol* symbol = symtab_lookup(scope, $1->name);
    // (1)
    if (!symbol) {
      ST_FATAL_ERROR("error: identifier '%s' is not declared\n", $1->name);
    }
    Identifier* id = symbol->attribute;
    // (2)
    if (id->id_type == ST_SUBPROGRAM_IDENTIFIER) {
      ST_FATAL_ERROR("error: identifier '%s' is a subprogram\n", $1->name);
    }
    $$ = malloc(sizeof(Reference));
    $$->ref_type = ST_IDENTIFIER_REFERENCE;
    $$->id_ref = id;
  }
  /*
   * NOTE: a ID subscripting can also be a substring
   */
| ID subscript_list
  {
    /*
     * (1) id can't be a subprogram
     * (2) id can only have type string or array
     * (3) if id has type string, the subscript list must have length 1
     * (4) if id has type array, the length of the list should be as same as the dimension of the array
     * NOTE: the expression may be run-time expressions, so range check seems impossible
     */
  }
;

subscript_list:
  subscript_list subscript
  { /* no check */ }
| subscript
  { /* no check */ }
;

subscript:
  '[' expr ']'
  {
    /*
     * (1) the expression should have type int
     */
  }
;

  /*
   * Returns an Expression.
   */
expr:
  /*
   * The reference is used as a rhs.
   */
  var_ref
  {
    $$ = malloc(sizeof(Expression));
    if ($1->ref_type == ST_IDENTIFIER_REFERENCE) {
      // compile-time of not?
      switch ($1->id_ref->id_type) {
        case ST_CONST_IDENTIFIER:
          if ($1->id_ref->const_id->const_id_type == ST_COMPILE_TIME_CONST_IDENTIFIER) {
            $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
            $$->compile_time_expr = malloc(sizeof(CompileTimeExpression));
            ST_COPY_SCALAR_VALUE($$->compile_time_expr, $1->id_ref->const_id->compile_time_const_id);
          } else if ($1->id_ref->const_id->const_id_type == ST_RUN_TIME_CONST_IDENTIFIER) {
            $$->expr_type = ST_RUN_TIME_EXPRESSION;
            $$->run_time_expr = malloc(sizeof(RunTimeExpression));
            ST_COPY_TYPE($$->run_time_expr, $1->id_ref->const_id->run_time_const_id);
          } else {
            ST_UNREACHABLE();
          }
          break;
        case ST_VAR_IDENTIFIER:
          // can't be compile-time expression, so just copy the type
          $$->expr_type = ST_RUN_TIME_EXPRESSION;
          $$->run_time_expr = malloc(sizeof(RunTimeExpression));
          ST_COPY_TYPE($$->run_time_expr, $1->id_ref->var_id);
          break;
        default:
          ST_UNREACHABLE();
      }
    } else if ($1->ref_type == ST_ARRAY_SUBSCRIPT_REFERENCE) {
      // can't be compile-time expression, so just copy the type
      $$->expr_type = ST_RUN_TIME_EXPRESSION;
      $$->run_time_expr = malloc(sizeof(RunTimeExpression));
      ST_COPY_TYPE($$->run_time_expr, $1->array_subscript_ref);
    } else {
      ST_UNREACHABLE();
    }
  }
| explicit_const
  {
    /*
     * (1) always compile-time expression
     */
    $$ = malloc(sizeof(Expression));
    // (1)
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->compile_time_expr = $1;
  }
| subprog_call
  {
    /*
     * (1) always a run-time expression
     * (2) the subprogram has to be a function
     */
  }
  /*
   * Here a hack on the ambiguous grammar:
   *  Since an array subscripting of variable reference and a substring may both be ID[expr],
   *  directly placing a substring non-terminal here causes a reduce/reduce conflict.
   *  The workaround is the put other rules of substring here.
   *  This implies that a substring in the form ID[expr] is treated as an var_ref and
   *  should be resolved further semantically.
   */
| ID '[' expr '.' '.' expr ']'
  {
    /*
     * (1) the id has to have type string
     * (2) both expression has to have type int
     * NOTE: the expression may be run-time expressions, so range check seems impossible
     */
  }
| operation
  { /* no check */ }
| '(' expr ')'
  { /* no check */ }
;

  /*
   * Returns a CompileTimeExpression.
   */
explicit_const:
  INT_CONST
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->data_type = ST_INT_TYPE;
    $$->int_val = $1;
  }
| REAL_CONST
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->data_type = ST_REAL_TYPE;
    $$->real_val = $1;
  }
| STR_CONST
  {
    /*
     * (1) record the length of the string
     */
  }
| bool_const
  { $$ = $1; }
;

  /*
   * Returns a CompileTimeExpression.
   */
bool_const:
  TRUE
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->data_type = ST_BOOL_TYPE;
    $$->bool_val = true;
  }
| FALSE
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->data_type = ST_BOOL_TYPE;
    $$->bool_val = false;
  }
;

operation:
  numeric_operation %prec NUMERIC_OP
  { /* no check */ }
| comparison_operation %prec COMPARISON_OP
  { /* no check */ }
| boolean_operation %prec BOOLEAN_OP
  { /* no check */ }
| sign_operation %prec SIGN_OP
  { /* no check */ }
;

numeric_operation:
  expr '+' expr
  {
    /*
     * (1) expressions can't have type other than int, real, and string
     * (2) if one of the expression is a string, the other one must also be a string, which is then a string concatenation
     * (3) if both of the expression have type int, the result type is int
     * (4) if one of the expression has type real, the result type is real
     */
  }
| expr '-' expr
  {
    /*
     * (1) expressions can't have type other than int and real
     * (2) if both of the expression have type int, the result type is int
     * (3) if one of the expression has type real, the result type is real
     */
  }
| expr '*' expr
  {
    /*
     * (1) expressions can't have type other than int and real
     * (2) if both of the expression have type int, the result type is int
     * (3) if one of the expression has type real, the result type is real
     */
  }
| expr '/' expr
  {
    /*
     * (1) expressions can't have type other than int and real
     * (2) if both of the expression have type int, the result type is int
     * (3) if one of the expression has type real, the result type is real
     */
  }
| expr MOD expr
  {
    /*
     * (1) both of the expressions must have type int
     */
  }
;

comparison_operation:
 /*
  * All of the comparison operations are the same.
  * (1) both expressions must be one of the scalar types
  * (2) both expressions must have the same type
  * (3) if both expressions are compile-time expressions, the operation is also a compile-time operation
  */
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
  expr AND expr
  {
    /*
     * (1) both expressions must have type bool
     * (2) if both expressions are compile-time expressions, the operation is also a compile-time operation
     */
  }
| expr OR expr
  {
    /*
     * (1) both expressions must have type bool
     * (2) if both expressions are compile-time expressions, the operation is also a compile-time operation
     */
  }
| NOT expr
  {
    /*
     * (1) the expression must have type bool
     * (2) if the expression is a compile-time expression, the operation is also a compile-time operation
     */
  }
;

  /*
   * All of the sign operations are the same.
   * (1) the expression must have type int or real
   * (2) if the expression is a compile-time expression, the operation is also a compile-time operation
   */
sign_operation:
  '+' expr {}
| '-' expr {}
;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "line %d on symbol '%s': %s\n", yylineno, yytext, msg);
}
