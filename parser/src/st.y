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
  Subprogram* subprogram;
  ProcedureSubprogram* procedure;
  FunctionSubprogram* function;
  List* formals;
  List* actuals;
  List* references;
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
%type subscript_list subscript subprog_decl opt_decl_or_stmt_list
%type opt_formal_decl_list formal_decl_list formal_decl formal_type subprog_call if_stmt
%type bool_expr operation numeric_operation comparison_operation boolean_operation
%type sign_operation result_stmt exit_stmt loop_stmt for_stmt block get_stmt put_stmt
%type var_ref_comma_list opt_expr_comma_list expr_comma_list then_block else_block opt_dot_dot
  /* to enforce ending with result statement in a function syntactically */
%type opt_decl_or_stmt_list_end_with_result_list decl_or_stmt_list_end_with_result_list decl_or_stmt_or_result

%type <expr> expr operation sign_operation numeric_operation comparison_operation boolean_operation bool_expr
%type <compile_time_expr> bool_const explicit_const
%type <var_id> var_decl
%type <const_id> const_decl
%type <ref> var_ref
%type <type_info> type scalar_type array_type formal_decl formal_type
%type <type_info> formal_star_string_type formal_star_array_type formal_star_array_nested_type
%type <subscript_list> subscript subscript_list
%type <procedure> procedure_decl procedure_header
%type <function> function_decl function_header
%type <formals> opt_formal_decl_list formal_decl_list
%type <actuals> opt_expr_comma_list expr_comma_list
%type <subprogram> subprog_call
%type <references> var_ref_comma_list

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
  {
    /*
     * (1) the subprogram must be a procedure
     */
    if ($1->subprogram_type != ST_PROCEDURE_SUBPROGRAM) {
      if ($1->subprogram_type != ST_FUNCTION_SUBPROGRAM) {
        ST_UNREACHABLE();
      }
      ST_FATAL_ERROR(@1, "'function' call cannot be a statement (STMT04)\n");
    }
  }
| RETURN
  {
    /*
     * (1) has to be inside the scope of a procedure
     */
    // (1)
    if (st_get_scope_type(env) != ST_PROCEDURE_SCOPE) {
      ST_FATAL_ERROR(@1, "'return' statement can only appear in the body of 'procedure's (STMT01)\n");
    }
  }
| if_stmt
  { /* no check */ }
| exit_stmt
  {
    /*
     * (1) has to be inside a loop or a for statement
     */
    // (1)
    if (st_get_scope_type(env) != ST_LOOP_SCOPE) {
      ST_FATAL_ERROR(@1, "'exit' statement can only appear in 'for' and 'loop' statements (STMT03)\n");
    }
  }
| {
    /*
     * mid-rule:
     * (1) new loop scope
     */
    // (1)
    st_enter_scope(&env, ST_LOOP_SCOPE);
  }
  loop_stmt
  {
    st_exit_scope(&env);
  }
| {
    /*
     * mid-rule:
     * (1) new loop scope
     */
    // (1)
    st_enter_scope(&env, ST_LOOP_SCOPE);
  }
  for_stmt
  {
    st_exit_scope(&env);
  }
| {
    /*
     * mid-rule:
     * (1) new block scope
     */
    st_enter_scope(&env, ST_BLOCK_SCOPE);
  }
  block
  {
    st_exit_scope(&env);
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
    if ($4->data_type == ST_ARRAY_TYPE
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
  {
    /*
     * mid-rule:
     * (1) enter a function scope
     */
    st_enter_scope(&env, ST_FUNCTION_SCOPE);
  }
  function_decl
  {
    /*
     * (1) the name of the function should not be already declared
     */
    st_exit_scope(&env);
    // (1)
    if (st_probe_environment(env, $2->name)) {
      ST_FATAL_ERROR(@2, "re-declaration of identifier '%s' (DECL01)\n", $2->name);
    }
    // NOTE: we have the add the function into the outmost scope,
    // so that it remains across the whole program
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = $2;
  }
| {
    /*
     * mid-rule:
     * (1) enter a procedure scope
     */
    st_enter_scope(&env, ST_PROCEDURE_SCOPE);
  }
  procedure_decl
  {
    /*
     * (1) the name of the procedure should not be already declared
     */
    st_exit_scope(&env);
    // (1)
    if (st_probe_environment(env, $2->name)) {
      ST_FATAL_ERROR(@2, "re-declaration of identifier '%s' (DECL01)\n", $2->name);
    }
    // NOTE: we have the add the procedure into the outmost scope,
    // so that it remains across the whole program
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = $2;
  }
;

procedure_decl:
  procedure_header opt_decl_or_stmt_list END ID
  {
    /*
     * (1) id is the same name as the one in the header
     */
    // (1)
    if (strcmp($1->name, $4->name) != 0) {
      ST_FATAL_ERROR(@4, "the name after 'end' should be the name of the 'subprogram' (SUB01)\n");
    }
    $$ = $1;
  }
;

  /*
   * Enforce a function to end with a result statement syntactically.
   */
function_decl:
  function_header opt_decl_or_stmt_list_end_with_result_list END ID
  {
    /*
     * (1) id is the same name as the one in the header
     */
    // (1)
    if (strcmp($1->name, $4->name) != 0) {
      ST_FATAL_ERROR(@4, "the name after 'end' should be the name of the 'subprogram' (SUB01)\n");
    }
    $$ = $1;
  }
;

  /*
   * A list where the result_stmt may appear and must end with a result_stmt.
   */
opt_decl_or_stmt_list_end_with_result_list:
  decl_or_stmt_list_end_with_result_list
  { /* no check */ }
| /* empty */
  { /* no check */ }
;

decl_or_stmt_list_end_with_result_list:
  decl_or_stmt_or_result decl_or_stmt_list_end_with_result_list
  { /* no check */ }
| result_stmt
  { /* no check */ }
| decl
  {
    ST_FATAL_ERROR(@1, "'function' must ends with a 'result' statement (SUB02)\n");
  }
| stmt
  {
    ST_FATAL_ERROR(@1, "'function' must ends with a 'result' statement (SUB02)\n");
  }
;

decl_or_stmt_or_result:
  decl
  { /* no check */ }
| stmt
  { /* no check */ }
| result_stmt
  { /* no check */ }
;

  /*
   * Returns a ProcedureSubprogram.
   */
procedure_header:
  PROCEDURE ID
  {
    /*
     * mid-rule
     * (1) enter a procedure scope
     * (2) the name of the procedure is a declared identifier within the scope
     */
    // (1)
    $<procedure>$ = malloc(sizeof(ProcedureSubprogram));
    $<procedure>$->id_type = ST_SUBPROGRAM_IDENTIFIER;
    $<procedure>$->subprogram_type = ST_PROCEDURE_SUBPROGRAM;
    $<procedure>$->name = st_strdup($2->name);
    // the formals of the procedure will be added later
    // (2)
    // NOTE: the procedure is added into the scope since it's visible to the
    // formals and the procedure body.
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = $<procedure>$;
  }
  '(' opt_formal_decl_list ')'
  {
    /*
     * (1) the types of the formals have to be recorded so can be checked on a call
     */
    $<procedure>3->formals = $5;
    $$ = $<procedure>3;
  }
;

  /*
   * Returns a FunctionSubprogram.
   */
function_header:
  FUNCTION ID
  {
   /*
    * mid-rule
    * (1) enter a procedure scope
    * (2) the name of the procedure is a declared identifier within the scope
    */
    // (1)
    $<function>$ = malloc(sizeof(FunctionSubprogram));
    $<function>$->id_type = ST_SUBPROGRAM_IDENTIFIER;
    $<function>$->subprogram_type = ST_FUNCTION_SUBPROGRAM;
    $<function>$->name = st_strdup($2->name);
    // the formals and the result type of the function will be added later
    // (2)
    // NOTE: the function is added into the scope since it's visible to the
    // formals and the function body.
    st_add_to_scope(env, $2->name)->attribute = $<function>$;
    // NOTE: add again with a special name for the result statement to check the result type.
    // Since no user-defined identifier can have name leading with underscore,
    // the name "__function" will never collied with user-defined identifiers.
    st_add_to_scope(env, "__function")->attribute = $<function>$;
  }
  '(' opt_formal_decl_list ')' ':' type
  {
    /*
     * (1) the types of the formals and the result has to be recorded so can be checked on a call
     */
    // (1)
    $<function>3->formals = $5;
    $<function>3->result_type = $8;
    $$ = $<function>3;
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
| {
    // NOTE: an error production on the result_stmt since we want to provide more expressive error message.
    // We have to report the error before recognizing the result_stmt, so a mid-rule is used.
    // Here we directly refer to the yylloc, which is the lookahead located at the first(result_stmt).
    ST_FATAL_ERROR(yylloc, "'result' statement can only appear in the body of 'function's (STMT02)\n");
  } result_stmt
  {
    //fatal error in the mid-rule
    ST_UNREACHABLE();
  }
;

  /*
   * Returns a List of StDataTypeInfo.
   */
opt_formal_decl_list:
  formal_decl_list { $$ = $1; }
| /* empty */      { $$ = NULL; }
;

  /*
   * Returns a List of StDataTypeInfo.
   */
formal_decl_list:
  formal_decl_list ',' formal_decl
  {
    $$ = list_create($3, $1);
  }
| formal_decl
  { $$ = list_create($1, NULL); }
;

  /*
   * Returns a StDataTypeInfo.
   * NOTE: the subprogram itself only has to record the types of the formals,
   * while the scope of the subprogram body has to record the formals as identifiers.
   * So formals are added to the scope in the action, add only the type info as semantic value.
   */
formal_decl:
  ID ':' formal_type
  {
    /*
     * (1) re-declaration error if name exists in the current scope
     * (2) the identifier should be recorded under the scope marked as constant
     */
    // (1)
    if (st_probe_environment(env, $1->name)) {
      ST_FATAL_ERROR(@1, "re-declaration of identifier '%s' (DECL01)\n", $1->name);
    }
    // (2): formals cannot be compile-time
    RunTimeConstIdentifier* id = malloc(sizeof(RunTimeConstIdentifier));
    id->id_type = ST_CONST_IDENTIFIER;
    id->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
    id->name = st_strdup($1->name);
    ST_COPY_TYPE(id, $3);
    // add the identifier to the scope
    Symbol* symbol = st_add_to_scope(env, id->name);
    symbol->attribute = id;
    // copy the type info as semantic value
    $$ = malloc(sizeof(StDataTypeInfo));
    ST_COPY_TYPE($$, id);
  }
| VAR ID ':' formal_type
  {
    /*
     * (1) re-declaration error if name exists in the current scope
     * (2) the identifier should be recorded under the scope marked as mutable
     */
    // (1)
    if (st_probe_environment(env, $2->name)) {
      ST_FATAL_ERROR(@2, "re-declaration of identifier '%s' (DECL01)\n", $2->name);
    }
    // (2)
    VarIdentifier* id = malloc(sizeof(VarIdentifier));
    id->id_type = ST_VAR_IDENTIFIER;
    id->name = st_strdup($2->name);
    ST_COPY_TYPE(id, $4);
    // add the identifier to the scope
    Symbol* symbol = st_add_to_scope(env, id->name);
    symbol->attribute = id;
    // copy the type info as semantic value
    $$ = malloc(sizeof(StDataTypeInfo));
    ST_COPY_TYPE($$, id);
  }
;

formal_type:
  type
  {
    /*
     * (1) if the formal type is an array type, it cannot be a dynamic array
     */
    if ($1->data_type == ST_ARRAY_TYPE
        && $1->array_type_info->array_type != ST_STATIC_ARRAY) {
      ST_FATAL_ERROR(@1, "type of formal parameter cannot be a 'dynamic array' (SUB03)\n");
    }
    $$ = $1;
  }
| formal_star_string_type
  { $$ = $1; }
| formal_star_array_type
  { $$ = $1; }
;

formal_star_string_type:
 STRING '(' '*' ')'
  {
    /*
     * (1) the max length of the string is unknown
     */
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    // (1)
    $$->string_type_info->max_length = ST_STAR_STRING_LENGTH;
  }
;

 /*
  * NOTE: Can nest a normal type or a star string, but not a star array.
  * This distinguishes it from the formal_type, so a new non-terminal is introduced.
  */
formal_star_array_nested_type:
  type                    { $$ = $1; }
| formal_star_string_type { $$ = $1; }
;

  /*
   * A star array is a static array with special upper-bound.
   */
formal_star_array_type:
  ARRAY expr '.' '.' '*' OF formal_star_array_nested_type
  {
    /*
     * (1) the expression at the lower bound must be a compile-time expression
     * (2) the expression at the lower bound must have type int
     * (3) type may also be an array, but such array type must be a static array
     *     NOTE: a star array is also a static array, but is excluded syntactically
     * (4) lower bound must have positive value
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
    $$->array_type_info = malloc(sizeof(StStaticArrayTypeInfo));
    $$->array_type_info->array_type = ST_STATIC_ARRAY;
    ST_COPY_TYPE($$->array_type_info, $7);
    $$->array_type_info->lower_bound = lower_bound->int_val;
    ((StStaticArrayTypeInfo*)$$->array_type_info)->upper_bound
        = ST_STAR_ARRAY_UPPER_BOUND;
  }
;

  /*
   * Returns a Subprogram.
   */
subprog_call:
  ID '(' opt_expr_comma_list ')'
  {
    /*
     * (1) the number of the expression should match the number of the declared formals
     * (2) each expressions in the list should have their types match the declared formal types
     */
    Symbol* symbol = st_lookup_environment(env, $1->name);
    if (!symbol) {
      ST_FATAL_ERROR(@1, "identifier '%s' is not declared (REF01)\n", $1->name);
    }
    Identifier* id = (Identifier*)symbol->attribute;
    if (id->id_type != ST_SUBPROGRAM_IDENTIFIER) {
      ST_FATAL_ERROR(@1, "identifier '%s' is not a subprogram (CALL01)\n", $1->name);
    }
    Subprogram* subprogram = (Subprogram*)id;
    // (1)
    const int num_of_formals = list_length(subprogram->formals);
    const int num_of_actuals = list_length($3);
    if (num_of_actuals != num_of_formals) {
      ST_FATAL_ERROR(@3, "mismatch number of formals, expect '%d' but get '%d' (CALL02)\n", num_of_formals, num_of_actuals);
    }
    // (2)
    List* formals = subprogram->formals;
    List* actuals = $3;
    while (actuals) {
      StDataTypeInfo* formal_type = (StDataTypeInfo*)formals->val;
      Expression* actual = (Expression*)actuals->val;
      StDataTypeInfo actual_type = ST_MAKE_DATA_TYPE_INFO(actual);
      if (!st_is_assignable_type(formal_type, &actual_type)) {
        ST_FATAL_ERROR(@3, "type of the actual parameter cannot be assigned as type of the formal parameter (CALL03)\n");
      }
      actuals = actuals->rest;
      formals = formals->rest;
    }
    $$ = subprogram;
  }
;

if_stmt:
  IF bool_expr then_block END IF
  { /* no check */ }
| IF bool_expr then_block else_block END IF
  { /* no check */ }
;

then_block:
  THEN
  {
    // mid-rule
    st_enter_scope(&env, ST_BLOCK_SCOPE);
  }
  opt_decl_or_stmt_list
  {
    st_exit_scope(&env);
  }
;

else_block:
  ELSE
  {
    // mid-rule
    st_enter_scope(&env, ST_BLOCK_SCOPE);
  }
  opt_decl_or_stmt_list
  {
    st_exit_scope(&env);
  }
;

result_stmt:
  RESULT expr
  {
    /*
     * (1) expr must have the same type as the declared result type
     */
    // NOTE: not checking whether is now in the function scope or not because it's already enforced by the grammar.
    // (1): get the current function through the special identifier name
    Symbol* symbol = st_probe_environment(env, "__function");
    if (!symbol) {
      ST_UNREACHABLE();
    }
    FunctionSubprogram* function = (FunctionSubprogram*)symbol->attribute;
    StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($2);
    if (!st_is_assignable_type(function->result_type, &expr_type_info)) {
      ST_FATAL_ERROR(@2, "type of the 'result' expression cannot be assigned as the result type of the 'function' (STMT05)\n");
    }
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
     */
    // (1)
    if ($3->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@3, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
    if ($6->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@6, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
  }
| FOR ID ':' expr '.' '.' expr
  {
    /*
     * mid-rule
     * (1) add id into the scope and marked as constant
     */
    if (st_probe_environment(env, $2->name)) {
      // should always be the first identifier added to the scope
      ST_UNREACHABLE();
    }
    // (1)
    RunTimeConstIdentifier* id = malloc(sizeof(RunTimeConstIdentifier));
    id->id_type = ST_CONST_IDENTIFIER;
    id->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
    id->name = st_strdup($2->name);
    id->data_type = ST_INT_TYPE;
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = id;
  }
  opt_decl_or_stmt_list END FOR
  {
    /*
     * (1) the expressions must be both of type int
     */
    // (1)
    if ($4->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@4, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
    if ($7->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@7, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
  }
| FOR DECREASING ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR
  {
    /*
     * (1) the expressions must be both of type int
     */
    // (1)
    if ($4->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@4, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
    if ($7->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@7, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
  }
| FOR DECREASING ID ':' expr '.' '.' expr
  {
    /*
     * mid-rule
     * (1) add id into the scope and marked as constant
     */
    if (st_probe_environment(env, $3->name)) {
      // should always be the first identifier added to the scope
      ST_UNREACHABLE();
    }
    // (1)
    RunTimeConstIdentifier* id = malloc(sizeof(RunTimeConstIdentifier));
    id->id_type = ST_CONST_IDENTIFIER;
    id->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
    id->name = st_strdup($3->name);
    id->data_type = ST_INT_TYPE;
    Symbol* symbol = st_add_to_scope(env, $3->name);
    symbol->attribute = id;
  }
  opt_decl_or_stmt_list END FOR
  {
    /*
     * (1) the expressions must be both of type int
     */
    // (1)
    if ($5->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@5, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
    if ($8->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@8, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
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
    List* refs = $2;
    while (refs) {
      Reference* ref = (Reference*)refs->val;
      // (1)
      if (ref->is_const) {
        ST_FATAL_ERROR(@2, "references in 'get' statement cannot be constant (STMT07)\n");
      }
      // (2)
      if (ref->data_type == ST_ARRAY_TYPE) {
        ST_FATAL_ERROR(@2, "references in 'get' statement cannot have type 'array' (STMT08)\n");
      }
      refs = refs->rest;
    }
  }
;

var_ref_comma_list:
  var_ref_comma_list ',' var_ref
  { $$ = list_create($3, $1); }
| var_ref
  { $$ = list_create($1, NULL); }
;

put_stmt:
  PUT expr_comma_list opt_dot_dot
  {
    /*
     * (1) no expression can be in type array
     */
    List* exprs = $2;
    // (1)
    while (exprs) {
      if (((Expression*)exprs->val)->data_type == ST_ARRAY_TYPE) {
        ST_FATAL_ERROR(@2, "expressions in 'put' statement cannot have type 'array' (STMT06)\n");
      }
      exprs = exprs->rest;
    }
  }
;

opt_dot_dot:
  '.' '.'
  { /* no check */ }
| /* empty */
  { /* no check */ }
;

 /*
  * Returns a List of Expression.
  * NOTE: due to the rightmost parsing technique,
  * the last expression is the first value of the list.
  */
opt_expr_comma_list:
  expr_comma_list
  { $$ = $1; }
| /* empty */
  { $$ = NULL; }
;

 /*
  * Returns a List of Expression.
  */
expr_comma_list:
  expr_comma_list ',' expr
  { $$ = list_create($3, $1); }
| expr
  { $$ = list_create($1, NULL); }
;

  /*
   * Returns an Expression.
   */
bool_expr:
  var_ref
  {
    /*
     * (1) the reference must be of a variable in type bool
     */
    // (1)
    if ($1->data_type != ST_BOOL_TYPE) {
      ST_FATAL_ERROR(@1, "'boolean' expression must have type 'bool' (EXPR08)\n");
    }
    if ($1->ref_type == ST_IDENTIFIER_REFERENCE) {
      Identifier* id = ((IdentifierReference*)$1)->id;
      if (id->id_type == ST_CONST_IDENTIFIER
          && ((ConstIdentifier*)id)->const_id_type == ST_COMPILE_TIME_CONST_IDENTIFIER) {
        $$ = (Expression*)malloc(sizeof(CompileTimeExpression));
        $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
        $$->data_type = ST_BOOL_TYPE;
        ((CompileTimeExpression*)$$)->bool_val = ((CompileTimeConstIdentifier*)id)->bool_val;
      }
    } else {
      $$ = (Expression*)malloc(sizeof(RunTimeExpression));
      $$->expr_type = ST_RUN_TIME_EXPRESSION;
    }
  }
| bool_const
  { $$ = (Expression*)$1; }
| comparison_operation %prec COMPARISON_OP
  { $$ = $1; }
| boolean_operation %prec BOOLEAN_OP
  { $$ = $1; }
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
    if ($2->data_type != ST_BOOL_TYPE) {
      ST_FATAL_ERROR(@2, "'boolean' expression must have type 'bool' (EXPR08)\n");
    }
    $$ = $2;
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
      $$->array_type_info = malloc(sizeof(StStaticArrayTypeInfo));
      $$->array_type_info->array_type = ST_STATIC_ARRAY;
      ST_COPY_TYPE($$->array_type_info, $7);
      $$->array_type_info->lower_bound = lower_bound->int_val;
      ((StStaticArrayTypeInfo*)($$->array_type_info))->upper_bound = upper_bound->int_val;
    } else if ($5->expr_type == ST_RUN_TIME_EXPRESSION) {
      $$->array_type_info = malloc(sizeof(StDynamicArrayTypeInfo));
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
    // (2)
    if ($1->subprogram_type != ST_FUNCTION_SUBPROGRAM) {
      if ($1->subprogram_type != ST_PROCEDURE_SUBPROGRAM) {
        ST_UNREACHABLE();
      }
      ST_FATAL_ERROR(@1, "'procedure' call cannot be an expression (EXPR01)\n");
    }
    // (1)
    $$ = (Expression*)malloc(sizeof(RunTimeExpression));
    $$->expr_type = ST_RUN_TIME_EXPRESSION;
    ST_COPY_TYPE($$, ((FunctionSubprogram*)$1)->result_type);
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
    // TODO
  }
| operation
  { $$ = $1; }
| '(' expr ')'
  { $$ = $2; }
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
     * (5) if both expressions are compile-time expressions, the operation is also a compile-time operation
     * (6) if is a compile-time string concatenation, the length of the result string must not exceed 255
     */
    /*
     * Handle string concatenation first, then elementary arithmetic
     */
    if ($1->data_type != $3->data_type
        && ($1->data_type == ST_STRING_TYPE || $3->data_type == ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@2, "operands of 'string' concatenation must both have type 'string' (STR04)\n");
    }
    // is string concatenation
    if ($1->data_type == ST_STRING_TYPE && $3->data_type == ST_STRING_TYPE) {
      if ($1->expr_type == ST_COMPILE_TIME_EXPRESSION && $3->expr_type == ST_COMPILE_TIME_EXPRESSION) {
        CompileTimeExpression* lhs = (CompileTimeExpression*)$1;
        CompileTimeExpression* rhs = (CompileTimeExpression*)$3;
        $$ = (Expression*)malloc(sizeof(CompileTimeExpression));
        $$->data_type = ST_STRING_TYPE;
        $$->string_type_info = malloc(sizeof(StStringTypeInfo));
        $$->string_type_info->max_length = strlen(lhs->string_val) + strlen(rhs->string_val);
        // (6)
        if ($$->string_type_info->max_length > 255) {
          ST_FATAL_ERROR(@1, "in compile-time 'string' concatenation, length of the result 'string' must not exceed 255 (STR05)\n");
        }
        ((CompileTimeExpression*)$$)->string_val = malloc(sizeof(char) * ($$->string_type_info->max_length + 1));
        strcpy(((CompileTimeExpression*)$$)->string_val, lhs->string_val);
        strcat(((CompileTimeExpression*)$$)->string_val, rhs->string_val);
      } else {
        $$->data_type = ST_STRING_TYPE;
        $$->string_type_info = malloc(sizeof(StStringTypeInfo));
        $$->string_type_info->max_length
            = $1->string_type_info->max_length + $3->string_type_info->max_length;
        // saturate
        if ($$->string_type_info->max_length > 255) {
          $$->string_type_info->max_length = 255;
        }
      }
    } else {
      // (1)
      if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
        ST_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      }
      if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
        ST_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      }
      $$ = ST_MAKE_BINARY_ARITHMETIC_EXPRESSION($1, +, $3);
    }
  }
| expr '-' expr
  {
    /*
     * (1) expressions can't have type other than int and real
     * (2) if both of the expression have type int, the result type is int
     * (3) if one of the expression has type real, the result type is real
     */
    // (1)
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
    }
    $$ = ST_MAKE_BINARY_ARITHMETIC_EXPRESSION($1, -, $3);
  }
| expr '*' expr
  {
    /*
     * (1) expressions can't have type other than int and real
     * (2) if both of the expression have type int, the result type is int
     * (3) if one of the expression has type real, the result type is real
     */
    // (1)
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
    }
    $$ = ST_MAKE_BINARY_ARITHMETIC_EXPRESSION($1, *, $3);
  }
| expr '/' expr
  {
    /*
     * (1) expressions can't have type other than int and real
     * (2) if both of the expression have type int, the result type is int
     * (3) if one of the expression has type real, the result type is real
     */
    // (1)
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
    }
    $$ = ST_MAKE_BINARY_ARITHMETIC_EXPRESSION($1, *, $3);
  }
| expr MOD expr
  {
    /*
     * (1) both of the expressions must have type int
     */
    // (1)
    if ($1->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@1, "operand of 'mod' operation must have type 'int' (EXPR07)\n");
    }
    if ($3->data_type != ST_INT_TYPE) {
      ST_FATAL_ERROR(@3, "operand of 'mod' operation must have type 'int' (EXPR07)\n");
    }
    if ($1->expr_type == ST_COMPILE_TIME_EXPRESSION && $3->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      $$ = (Expression*)malloc(sizeof(CompileTimeExpression));
      $$->data_type = ST_INT_TYPE;
      ((CompileTimeExpression*)$$)->int_val = ((CompileTimeExpression*)$1)->int_val % ((CompileTimeExpression*)$3)->int_val;
    } else {
      $$ = (Expression*)malloc(sizeof(RunTimeExpression));
      $$->data_type = ST_INT_TYPE;
    }
  }
;

comparison_operation:
 /*
  * All of the comparison operations are the same.
  * (1) expressions can't have type other than int, real, and string
  * (2) both expressions must have the same type
  * (3) if both expressions are compile-time expressions, the operation is also a compile-time operation
  */
  expr '<' expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if ($1->data_type != $3->data_type) {
      ST_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
    }
    $$ = ST_MAKE_BINARY_COMPARISON_EXPRESSION($1, <, $3);
  }
| expr '>' expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if ($1->data_type != $3->data_type) {
      ST_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
    }
    $$ = ST_MAKE_BINARY_COMPARISON_EXPRESSION($1, >, $3);
  }
| expr '=' expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if ($1->data_type != $3->data_type) {
      ST_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
    }
    $$ = ST_MAKE_BINARY_COMPARISON_EXPRESSION($1, ==, $3);
  }
| expr LE expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if ($1->data_type != $3->data_type) {
      ST_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
    }
    $$ = ST_MAKE_BINARY_COMPARISON_EXPRESSION($1, <=, $3);
  }
| expr GE expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if ($1->data_type != $3->data_type) {
      ST_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
    }
    $$ = ST_MAKE_BINARY_COMPARISON_EXPRESSION($1, >=, $3);
  }
| expr NE expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
    }
    if ($1->data_type != $3->data_type) {
      ST_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
    }
    $$ = ST_MAKE_BINARY_COMPARISON_EXPRESSION($1, !=, $3);
  }
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
    // (1)
    if ($1->data_type != ST_BOOL_TYPE) {
      ST_FATAL_ERROR(@1, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
    }
    if ($3->data_type != ST_BOOL_TYPE) {
      ST_FATAL_ERROR(@3, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
    }
    // (2)
    $$ = ST_MAKE_BINARY_BOOLEAN_EXPRESSION($1, &&, $3);
  }
| expr OR expr
  {
    /*
     * (1) both expressions must have type bool
     * (2) if both expressions are compile-time expressions, the operation is also a compile-time operation
     */
    // (1)
    if ($1->data_type != ST_BOOL_TYPE) {
      ST_FATAL_ERROR(@1, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
    }
    if ($3->data_type != ST_BOOL_TYPE) {
      ST_FATAL_ERROR(@3, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
    }
    // (2)
    $$ = ST_MAKE_BINARY_BOOLEAN_EXPRESSION($1, ||, $3);
  }
| NOT expr
  {
    /*
     * (1) the expression must have type bool
     * (2) if the expression is a compile-time expression, the operation is also a compile-time operation
     */
    // (1)
    if ($2->data_type != ST_BOOL_TYPE) {
      ST_FATAL_ERROR(@2, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
    }
    // (2)
    if ($2->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      $$ = malloc(sizeof(CompileTimeExpression));
      $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
      $$->data_type = ST_BOOL_TYPE;
      ((CompileTimeExpression*)$$)->bool_val = !((CompileTimeExpression*)$2)->bool_val;
    } else if ($2->expr_type == ST_RUN_TIME_EXPRESSION) {
      $$ = malloc(sizeof(RunTimeExpression));
      $$->expr_type = ST_RUN_TIME_EXPRESSION;
      $$->data_type = ST_BOOL_TYPE;
    } else {
      ST_UNREACHABLE();
    }
  }
;

  /*
   * All of the sign operations are the same.
   * (1) the expression must have type int or real
   * (2) if the expression is a compile-time expression, the operation is also a compile-time operation
   */
sign_operation:
  '+' expr
  {
    // (1)
    if (!ST_HAS_ONE_OF_DATA_TYPES($2, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@2, "operand of 'sign' operation must have type 'int' or 'real' (EXPR02)\n");
    }
    // (2)
    $$ = ST_MAKE_UNARY_SIGN_EXPRESSION(+, $2);
  }
| '-' expr
  {
    // (1)
    if (!ST_HAS_ONE_OF_DATA_TYPES($2, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_FATAL_ERROR(@2, "operand of 'sign' operation must have type 'int' or 'real' (EXPR02)\n");
    }
    // (2)
    $$ = ST_MAKE_UNARY_SIGN_EXPRESSION(-, $2);
  }
;

%%
extern char* input_filename;

void yyerror(const char *msg) {
  fprintf(stderr, "%s:%d:%d: %s\n",
      input_filename, yylloc.first_line, yylloc.first_column, msg);
}
