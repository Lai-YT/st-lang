%{
  #include <stddef.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #include "list.h"
  #include "scope.h"
  #include "semant.h"
  #include "semant_macros.h"
  #include "st-lex.h"
  #include "symtab.h"

  extern StEnvironment* env;

  /// @brief called for each syntax error
  void yyerror(const char *s);
%}
%locations
%define parse.error detailed
%union {
  Symbol* symbol;
  char str_const[256];
  int int_const;
  double real_const;
  Expression* expr;
  CompileTimeExpression* compile_time_expr;
  ConstIdentifier* const_id;
  VarIdentifier* var_id;
  Reference* ref;
  StDataTypeInfo* type_info;
  List* subscript_list;
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
%type <var_id> var_decl
%type <const_id> const_decl
%type <ref> var_ref
%type <type_info> type scalar_type array_type
%type <subscript_list> subscript subscript_list

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
  {
    /*
     * mid-rule:
     * (1) new block scope
     * NOTE: all subprogram type identifiers will be added to this scope
     */
    // (1)
    st_enter_scope(&env, ST_BLOCK_SCOPE);
  }
  decl_or_stmt_in_main_program_list
  {
    st_exit_scope(&env);
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
     */
    // (1)
    if (st_probe_environment(env, $1->name)) {
      ST_FATAL_ERROR(@1, "re-declaration of identifier '%s' (DECL01)\n", $1->name);
    }
    // (2)
    Symbol* symbol = st_add_to_scope(env, $1->name);
    symbol->attribute = $1;
  }
| const_decl
  {
    /*
     * (1) re-declaration error if name exists in the current scope
     * (2) the identifier should be recorded under the scope
     */
    // (1)
    if (st_probe_environment(env, $1->name)) {
      ST_FATAL_ERROR(@1, "re-declaration of identifier '%s' (DECL01)\n", $1->name);
    }
    // (2)
    Symbol* symbol = st_add_to_scope(env, $1->name);
    symbol->attribute = $1;
  }
;

stmt:
  var_ref ASSIGN expr
  {
    /*
     * (1) the type of the variable reference has to be the same as the expression
     * (2) the reference should be of a mutable variable
     */
    // (1)
    StDataTypeInfo var_ref_type_info = ST_MAKE_DATA_TYPE_INFO($1);
    StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($3);
    if (!st_is_assignable_type(&var_ref_type_info, &expr_type_info)) {
      ST_FATAL_ERROR(@3, "type of the expression cannot be assigned to the reference (TYPE01)\n");
    }
    // (2)
    if ($1->is_const) {
      ST_FATAL_ERROR(@1, "re-assignment on constant reference (CONST02)\n");
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
     * (1) new loop scope
     */
  }
| for_stmt
  {
    /*
     * (1) new loop scope
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

  /*
   * Returns a VarIdentifier.
   */
var_decl:
  VAR ID ASSIGN expr
  {
    $$ = malloc(sizeof(VarIdentifier));
    $$->id_type = ST_VAR_IDENTIFIER;
    $$->name = st_strdup($2->name);
    ST_COPY_TYPE($$, $4);
  }
| VAR ID ':' array_type
  {
    $$ = malloc(sizeof(VarIdentifier));
    $$->id_type = ST_VAR_IDENTIFIER;
    $$->name = st_strdup($2->name);
    ST_COPY_TYPE($$, $4);
  }
| VAR ID ':' scalar_type
  {
    $$ = malloc(sizeof(VarIdentifier));
    $$->id_type = ST_VAR_IDENTIFIER;
    $$->name = st_strdup($2->name);
    ST_COPY_TYPE($$, $4);
  }
| VAR ID ':' scalar_type ASSIGN expr
  {
    /*
     * (1) the expression has the same type as scalar_type
     */
    // (1)
    StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($6);
    if (!st_is_assignable_type($4, &expr_type_info)) {
      ST_FATAL_ERROR(@4, "type of the expression cannot be assigned as the declared type (TYPE02)\n");
    }
    $$ = malloc(sizeof(VarIdentifier));
    $$->id_type = ST_VAR_IDENTIFIER;
    $$->name = st_strdup($2->name);
    // use the declared type, not the type of the expression
    ST_COPY_TYPE($$, $4);
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
    // (1)
    if($4->data_type == ST_ARRAY_TYPE
        && $4->array_type_info->array_type == ST_DYNAMIC_ARRAY) {
      ST_FATAL_ERROR(@4, "a constant identifier cannot be a 'dynamic array' (CONST01)\n");
    }
    // (2)
    if ($4->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      $$ = malloc(sizeof(CompileTimeConstIdentifier));
      $$->const_id_type = ST_COMPILE_TIME_CONST_IDENTIFIER;
      // (3)
      ST_COPY_TYPE($$, $4);
      ST_COPY_SCALAR_VALUE((CompileTimeConstIdentifier*)$$, (CompileTimeExpression*)$4);
    } else if ($4->expr_type == ST_RUN_TIME_EXPRESSION) {
      $$ = malloc(sizeof(RunTimeConstIdentifier));
      $$->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
      ST_COPY_TYPE($$, $4);
    } else {
      ST_UNREACHABLE();
    }
    $$->id_type = ST_CONST_IDENTIFIER;
    $$->name = st_strdup($2->name);
  }
| CONST ID ':' scalar_type ASSIGN expr
  {
    /*
     * (1) the expression has the same type as scalar_type
     * (2) if the expression is a compile-time expression, the id can represent a compile-time expression
     */
    // although an expression with dynamic array type will never be assignable to a scalar type,
    // we'll check first to emphasize that a constant identifier cannot be a dynamic array
    if($6->data_type == ST_ARRAY_TYPE
        && $6->array_type_info->array_type == ST_DYNAMIC_ARRAY) {
      ST_FATAL_ERROR(@4, "a constant identifier cannot be a 'dynamic array' (CONST01)\n");
    }
    // (1)
    StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($6);
    if (!st_is_assignable_type($4, &expr_type_info)) {
      ST_FATAL_ERROR(@4, "type of the expression cannot be assigned as the declared type (TYPE02)\n");
    }
    // (2)
    if ($6->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      $$ = malloc(sizeof(CompileTimeConstIdentifier));
      $$->const_id_type = ST_COMPILE_TIME_CONST_IDENTIFIER;
      // use the declared type, not the type of the expression
      ST_COPY_TYPE($$, $4);
      ST_COPY_SCALAR_VALUE((CompileTimeConstIdentifier*)$$, (CompileTimeExpression*)$6);
    } else if ($6->expr_type == ST_RUN_TIME_EXPRESSION) {
      $$ = malloc(sizeof(RunTimeConstIdentifier));
      $$->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
      // use the declared type, not the type of the expression
      ST_COPY_TYPE($$, $4);
    } else {
      ST_UNREACHABLE();
    }
    $$->id_type = ST_CONST_IDENTIFIER;
    $$->name = st_strdup($2->name);
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

  /*
   * Returns an StDataTypeInfo.
   */
scalar_type:
  INT
  {
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_INT_TYPE;
  }
| REAL
  {
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_REAL_TYPE;
  }
| BOOL
  {
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_BOOL_TYPE;
  }
| STRING
  {
    /*
     * (1) the max length of the string is 255
     */
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    // (1)
    $$->string_type_info->max_length = 255;
  }
| STRING '(' expr ')'
  {
    /*
     * (1) the expression must have type int
     * (2) the expression must be a compile-time expression
     * (3) the expression must be positive
     * (4) the expression can't be greater than 255
     */
    // (1)
    if ($3->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@3, "max length of a 'string' must have type 'int' (STR01)\n");
    }
    // (2)
    if ($3->expr_type != ST_COMPILE_TIME_EXPRESSION) {
      ST_FATAL_ERROR(@3, "max length of a 'string' must be a compile-time expression (STR02)\n");
    }
    CompileTimeExpression* compile_time_expr = (CompileTimeExpression*)$3;
    // (3), (4)
    if (compile_time_expr->int_val < 1 || compile_time_expr->int_val > 255) {
      ST_FATAL_ERROR(@3, "max length of a 'string' must be in range 1 ~ 255 (STR03)\n");
    }
    // checks are done, it's now safe to construct the type
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    $$->string_type_info->max_length = compile_time_expr->int_val;
  }
;

  /*
   * Returns an StDataTypeInfo.
   */
array_type:
  ARRAY expr '.' '.' expr OF type
  {
    /*
     * (1) the expression of the lower bound must be a compile-time expression
     * (2) the expressions must both have type int
     * (3) type may also be an array, but the upper bound of a nested array has
     *     to be a compile-time expression as also, which means we have to record
     *     the bounds of an array type. This is also for type equality checks
     * (4) lower bound must have positive value
     * (5) upper bound of a static array must have positive value
     * (6) the upper bound of a static array must be greater than the lower bound
     */
    // (1)
    if ($2->expr_type != ST_COMPILE_TIME_EXPRESSION) {
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must be a compile-time expression (ARR01)\n");
    }
    CompileTimeExpression* lower_bound = (CompileTimeExpression*)$2;
    // (2)
    if (lower_bound->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must have type 'int' (ARR02)\n");
    }
    if ($5->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@5, "upper bound of an 'array' must have type 'int' (ARR02)\n");
    }
    // (3)
    if ($7->data_type == ST_ARRAY_TYPE
        && $7->array_type_info->array_type != ST_STATIC_ARRAY) {
      ST_FATAL_ERROR(@7, "type of an 'array' must be a 'static array' (ARR03)\n");
    }
    // (4)
    if (lower_bound->int_val < 1) {
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must be positive (ARR04)\n");
    }
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_ARRAY_TYPE;
    $$->array_type_info = malloc(sizeof(StArrayTypeInfo));
    if ($5->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      CompileTimeExpression* upper_bound = (CompileTimeExpression*)$5;
      // (5)
      if (upper_bound->int_val < 1) {
        ST_FATAL_ERROR(@5, "upper bound of a 'static array' must be positive (ARR05)\n");
      }
      // (6)
      if (upper_bound->int_val <= lower_bound->int_val) {
        ST_FATAL_ERROR(@5, "upper bound of a 'static array' must be greater than its lower bound (ARR06)\n");
      }
      $$->array_type_info->array_type = ST_STATIC_ARRAY;
      ST_COPY_TYPE($$->array_type_info, $7);
      $$->array_type_info->lower_bound = lower_bound->int_val;
      ((StStaticArrayTypeInfo*)($$->array_type_info))->upper_bound = upper_bound->int_val;
    } else if ($5->expr_type == ST_RUN_TIME_EXPRESSION) {
      $$->array_type_info->array_type = ST_DYNAMIC_ARRAY;
      ST_COPY_TYPE($$->array_type_info, $7);
      $$->array_type_info->lower_bound = lower_bound->int_val;
    } else {
      ST_UNREACHABLE();
    }
  }
;

type:
  scalar_type
  { $$ = $1; }
| array_type
  { $$ = $1; }
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
    Symbol* symbol = st_lookup_environment(env, $1->name);
    // (1)
    if (!symbol) {
      ST_FATAL_ERROR(@1, "identifier '%s' is not declared (REF01)\n", $1->name);
    }
    Identifier* id = symbol->attribute;
    // (2)
    if (id->id_type == ST_SUBPROGRAM_IDENTIFIER) {
      ST_FATAL_ERROR(@1, "identifier '%s' is a 'subprogram', cannot be used as reference (REF02)\n", $1->name);
    }
    $$ = malloc(sizeof(IdentifierReference));
    $$->ref_type = ST_IDENTIFIER_REFERENCE;
    ((IdentifierReference*)$$)->id = id;
    // forward
    ST_COPY_TYPE($$, id);
    if (id->id_type == ST_CONST_IDENTIFIER) {
      $$->is_const = true;
    } else if (id->id_type == ST_VAR_IDENTIFIER) {
      $$->is_const = false;
    } else {
      ST_UNREACHABLE();
    }
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
     * (4) if id has type array, the length of the list cannot exceed the dimension of the array
     * NOTE: the expression may be run-time expressions, so range check seems impossible
     */
    Symbol* symbol = st_lookup_environment(env, $1->name);
    // (1)
    if (!symbol) {
      ST_FATAL_ERROR(@1, "identifier '%s' is not declared (REF01)\n", $1->name);
    }
    Identifier* id = symbol->attribute;
    // (2)
    if (id->id_type == ST_SUBPROGRAM_IDENTIFIER) {
      ST_FATAL_ERROR(@1, "identifier '%s' is a 'subprogram', cannot be used as reference (REF02)\n", $1->name);
    }

    if (id->data_type == ST_STRING_TYPE) {
      // (3)
      if (list_length($2) != 1) {
        ST_FATAL_ERROR(@2, "'character' is unsubscriptable, for substrings, use '%s[n .. m]' instead (REF03)\n", $1->name);
      }
      // TODO: return a character
    } else if (id->data_type == ST_ARRAY_TYPE) {
      if (id->id_type == ST_CONST_IDENTIFIER
          && ((ConstIdentifier*)id)->const_id_type == ST_COMPILE_TIME_CONST_IDENTIFIER) {
        // a compile-time identifier should not have an array type
        ST_UNREACHABLE();
      }
      const int num_of_sub = list_length($2);
      const int dim_of_arr = st_dimension_of_array(id->array_type_info);
      // (4)
      if (num_of_sub > dim_of_arr) {
        ST_FATAL_ERROR(@2, "'%d'-dimensional 'array' cannot have '%d' subscripts (REF05)\n", dim_of_arr, num_of_sub);
      }
      $$ = malloc(sizeof(ArraySubscriptReference));
      $$->ref_type = ST_ARRAY_SUBSCRIPT_REFERENCE;
      $$->is_const = id->id_type == ST_CONST_IDENTIFIER;
      StArrayTypeInfo* sub_array_type_info = (StArrayTypeInfo*)id->array_type_info;
      // find the correct dimension of the array
      for (int i = 0; i < num_of_sub - 1; ++i) {
        sub_array_type_info = sub_array_type_info->array_type_info;
      }
      ST_COPY_TYPE($$, sub_array_type_info);
    } else {
      // (2)
      ST_FATAL_ERROR(@1, "identifier '%s' has unsubscriptable type (REF04)\n", $1->name);
    }
  }
;

  /*
   * Returns a List of Expressions.
   */
subscript_list:
  subscript_list subscript
  {
    $2->rest = $1;
    $$ = $2;
  }
| subscript
  { $$ = $1; }
;

  /*
   * Returns a List of Expressions.
   */
subscript:
  '[' expr ']'
  {
    /*
     * (1) the expression should have type int
     */
    // (1)
    if ($2->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@2, "subscript must have type 'int' (REF06)\n");
    }
    $$ = list_create($2, NULL);
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
    if ($1->ref_type == ST_IDENTIFIER_REFERENCE) {
      // compile-time of not?
      Identifier* id = ((IdentifierReference*)$1)->id;
      switch (id->id_type) {
        case ST_CONST_IDENTIFIER:
          if (((ConstIdentifier*)id)->const_id_type == ST_COMPILE_TIME_CONST_IDENTIFIER) {
            $$ = malloc(sizeof(CompileTimeExpression));
            $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
            ST_COPY_TYPE($$, ((IdentifierReference*)$1)->id);
            ST_COPY_SCALAR_VALUE((CompileTimeExpression*)$$, (CompileTimeConstIdentifier*)((IdentifierReference*)$1)->id);
          } else if (((ConstIdentifier*)id)->const_id_type == ST_RUN_TIME_CONST_IDENTIFIER) {
            $$ = malloc(sizeof(RunTimeExpression));
            $$->expr_type = ST_RUN_TIME_EXPRESSION;
            ST_COPY_TYPE($$, $1);
          } else {
            ST_UNREACHABLE();
          }
          break;
        case ST_VAR_IDENTIFIER:
          $$ = malloc(sizeof(RunTimeExpression));
          $$->expr_type = ST_RUN_TIME_EXPRESSION;
          ST_COPY_TYPE($$, $1);
          break;
        default:
          ST_UNREACHABLE();
      }
    } else if ($1->ref_type == ST_ARRAY_SUBSCRIPT_REFERENCE) {
      $$ = malloc(sizeof(RunTimeExpression));
      $$->expr_type = ST_RUN_TIME_EXPRESSION;
      ST_COPY_TYPE($$, $1);
    } else {
      ST_UNREACHABLE();
    }
  }
| explicit_const
  { $$ = (Expression*)$1; }
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
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_INT_TYPE;
    $$->int_val = $1;
  }
| REAL_CONST
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_REAL_TYPE;
    $$->real_val = $1;
  }
| STR_CONST
  {
    /*
     * (1) record the length of the string
     */
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    $$->string_type_info->max_length = strlen($1);
    $$->string_val = st_strdup($1);
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
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_BOOL_TYPE;
    $$->bool_val = true;
  }
| FALSE
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
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
extern char* input_filename;

void yyerror(const char *msg) {
  fprintf(stderr, "%s:%d:%d: %s\n",
      input_filename, yylloc.first_line, yylloc.first_column, msg);
}
