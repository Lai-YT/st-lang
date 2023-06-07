%{
  #include <assert.h>
  #include <stdbool.h>
  #include <stddef.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #include "codegen.h"
  #include "list.h"
  #include "scope.h"
  #include "semant.h"
  #include "semant_macros.h"
  #include "st-lex.h"

  #ifndef ST_FATAL_ERROR
  /// @brief Prints the format message to stderr and exits as failure.
  /// @note If allow_semantic_errors is a non-zero value, exits as success.
  #define ST_FATAL_ERROR(yylloc, ...) \
    { \
      ST_NON_FATAL_ERROR(yyloc, __VA_ARGS__); \
      if (allow_semantic_errors) { \
        YYACCEPT; \
      } \
      YYABORT; \
    }
  #endif

  #ifndef ST_NON_FATAL_ERROR
  #define ST_NON_FATAL_ERROR(yylloc, ...) \
    { \
      fprintf(stderr, "%s:%d:%d: error: ", input_filename, (yylloc).first_line, \
              (yylloc).first_column); \
      fprintf(stderr, __VA_ARGS__); \
      ++semantic_errors; \
    }
  #endif

  extern StEnvironment* env;
  extern char* input_filename_stem;

  char* code_gen_class_name;

  /// @brief to know whether we are generating a global identifier or not
  bool is_in_global_scope = false;

  /// @brief the location number of a local variable.
  /// @details After time a new subprogram is entered, the number is reset to 0.
  int local_number = 0;

  /// @brief number of semantic errors
  int semantic_errors = 0;

  /// @brief called for each syntax error
  void yyerror(const char *s);

  /// @brief Compile-time constant identifiers don't generate code, so we need
  /// this flag to tell the expression not the do so.
  static bool is_in_const_decl = false;
%}
%locations
%define parse.error detailed
%union {
  /* terminal values */
  Symbol* symbol;
  char str_const[256];
  int int_const;
  double real_const;
  /* non-terminal values */
  Expression* expr;
  CompileTimeExpression* compile_time_expr;
  Identifier* id;
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

/* non-terminals without semantic value */
%type program opt_decl_in_main_program_list opt_stmt_list stmt_list decl_in_main_program_list decl_in_main_program
%type opt_decl_or_stmt_list decl_or_stmt_list decl_or_stmt decl stmt
%type subprog_decl if_stmt then_block else_block result_stmt exit_stmt
%type loop_stmt for_stmt for_header for_range block get_stmt put_stmt opt_dot_dot
  /* to enforce ending with result statement in a function syntactically */
%type opt_decl_or_stmt_list_end_with_result_list decl_or_stmt_list_end_with_result_list decl_or_stmt_or_result

/* non-terminals with semantic value */
%type <expr> expr operation sign_operation numeric_operation comparison_operation boolean_operation bool_expr opt_init_expr
%type <compile_time_expr> bool_const explicit_const
%type <id> decl_ formal_decl_
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
    // mid-rule: new block scope
    // NOTE: all subprogram type identifiers will be added to this scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
    code_gen_class_name = st_strdup(input_filename_stem);
    ST_CODE_GEN("class %s {\n", code_gen_class_name);
    is_in_global_scope = true;
  }
  opt_decl_in_main_program_list  // code of global identifiers & subprograms are generated
  {
    is_in_global_scope = false;
    // all statements are wrapped into the main function
    ST_CODE_GEN(
      "method public static void main(java.lang.String[])\n"
      "max_stack 15\n"
      "max_locals 15\n"
      "{\n"
    );
  }
  opt_stmt_list  // code of statements are generated
  {
    ST_CODE_GEN(
      "return\n"
      "}\n"
      "}\n"
    );
    free(code_gen_class_name);
    st_exit_scope(&env);
    if (semantic_errors && !allow_semantic_errors) {
      YYABORT;
    }
  }
;

opt_decl_in_main_program_list:
  decl_in_main_program_list
  { /* no check */ }
| /* empty */
  { /* no check */ }
;

opt_stmt_list:
  stmt_list
  { /* no check */ }
| /* empty */
  { /* no check */ }
;

stmt_list:
  stmt_list stmt
  { /* no check */ }
| stmt
  { /* no check */ }
;

decl_in_main_program_list:
  decl_in_main_program_list decl_in_main_program
  { /* no check */ }
| decl_in_main_program
  { /* no check */ }
;

  /*
   * NOTE: subprog_decl can only appear in the main program level.
   * Separate it from normal decl.
   */
decl_in_main_program:
  decl
  { /* no check */ }
| subprog_decl
  { /* no check */ }
;

decl:
  decl_
  {
    // (1) re-declaration error if name exists in the current scope
    if (st_probe_environment(env, $1->name)) {
      // error recovery: skip this declaration
      ST_NON_FATAL_ERROR(@1, "re-declaration of identifier '%s' (DECL01)\n", $1->name);
      st_free_identifier($1);
    } else {
      // (2) the identifier should be recorded under the scope
      Symbol* symbol = st_add_to_scope(env, $1->name);
      symbol->attribute = $1;
    }
  }
;

  /*
   * An intermediate non-terminal so they can share the same action in decl.
   */
decl_:
  var_decl
  { $$ = (Identifier*)$1; }
| const_decl
  { $$ = (Identifier*)$1; }
;

stmt:
  var_ref ASSIGN
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  expr
  {
    // (1) the type of the variable reference has to be the same as the expression
    StDataTypeInfo var_ref_type_info = ST_MAKE_DATA_TYPE_INFO($1);
    StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($4);
    if (!st_is_assignable_type(&var_ref_type_info, &expr_type_info)) {
      ST_NON_FATAL_ERROR(@4, "type of the expression cannot be assigned to the reference (TYPE01)\n");
    }
    // (2) the reference must be a mutable variable
    if ($1->is_const) {
      ST_NON_FATAL_ERROR(@1, "re-assignment on constant reference (CONST02)\n");
    }
    if ($1->ref_type != ST_IDENTIFIER_REFERENCE || $1->data_type != ST_INT_TYPE) {
      ST_UNIMPLEMENTED_ERROR();
    }
    Identifier* id_ref = ((IdentifierReference*)$1)->id;
    if (st_is_global(id_ref)) {
      ST_CODE_GEN("putstatic int %s.%s\n", code_gen_class_name, id_ref->name);
    } else {
      ST_CODE_GEN("istore %d\n", id_ref->local_number);
    }
    st_free_reference($1);
    st_free_expression($4);
  }
| subprog_call
  {
    // (1) the subprogram must be a procedure
    if ($1->subprogram_type != ST_PROCEDURE_SUBPROGRAM) {
      assert($1->subprogram_type == ST_FUNCTION_SUBPROGRAM);
      ST_NON_FATAL_ERROR(@1, "'function' call cannot be a statement (STMT04)\n");
    }
    // the id of $$ is from the symbol table, so no free here
  }
| RETURN
  {
    // (1) has to be inside the scope of a procedure
    if (!st_lookup_environment(env, ST_PROCEDURE_SCOPE_NAME)) {
      ST_NON_FATAL_ERROR(@1, "'return' statement can only appear in the body of 'procedure's (STMT01)\n");
    }
  }
| if_stmt
  { /* no check */ }
| exit_stmt
  {
    // (1) has to be inside a loop or a for statement
    if (!st_lookup_environment(env, ST_LOOP_SCOPE_NAME)) {
      ST_NON_FATAL_ERROR(@1, "'exit' statement can only appear in 'for' and 'loop' statements (STMT03)\n");
    }
  }
| {
    // mid-rule: new loop scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_LOOP_SCOPE_NAME);
  }
  loop_stmt
  { st_exit_scope(&env); }
| {
    // mid-rule: new loop scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_LOOP_SCOPE_NAME);
  }
  for_stmt
  { st_exit_scope(&env); }
| {
    // mid-rule: new block scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
  }
  block
  { st_exit_scope(&env); }
| get_stmt
  { /* no check */ }
| put_stmt
  { /* no check */ }
| { ST_CODE_GEN_SOURCE_COMMENT(@0); }
  SKIP
  {
    ST_CODE_GEN("getstatic java.io.PrintStream java.lang.System.out\n");
    ST_CODE_GEN("invokevirtual void java.io.PrintStream.println()\n");
  }
;

  /*
   * Returns a VarIdentifier.
   */
var_decl:
  VAR ID ASSIGN
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  expr
  {
    $$ = ST_CREATE_VAR_IDENTIFIER($2->name, $5);
    if (is_in_global_scope && $5->expr_type != ST_COMPILE_TIME_EXPRESSION) {
      ST_UNIMPLEMENTED_ERROR();
    }
    CompileTimeExpression* compile_time_expr = (CompileTimeExpression*)$5;
    if (is_in_global_scope) {
      switch ($5->data_type) {
        case ST_INT_TYPE:
          ST_CODE_GEN("field static int %s = %d\n", $2->name, compile_time_expr->int_val);
          break;
        case ST_BOOL_TYPE:
          // booleans are treated as int, with true = 1, false = 0
          ST_CODE_GEN("field static int %s = %d\n", $2->name, compile_time_expr->bool_val);
          break;
        default:
          ST_UNIMPLEMENTED_ERROR();
      }
    } else {
      ST_CODE_GEN("istore %d\n", $$->local_number);
    }
    st_free_expression($5);
  }
| VAR ID ':' array_type
  {
    $$ = ST_CREATE_VAR_IDENTIFIER($2->name, $4);
    st_free_data_type_info($4);
    ST_UNIMPLEMENTED_ERROR();
  }
| VAR ID ':' scalar_type
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  opt_init_expr
  {
    if (!$6 /* no init */ ) {
      $$ = ST_CREATE_VAR_IDENTIFIER($2->name, $4);
      st_free_data_type_info($4);
      if (is_in_global_scope) {
        ST_CODE_GEN("field static int %s\n", $2->name);
      } else {
        /* the location of the variable is kept by the symbol table */
      }
    } else /* has init expr */ {
      // (1) the expression has the same type as scalar_type
      StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($6);
      if (!st_is_assignable_type($4, &expr_type_info)) {
        // error recovery: since we respect the declared type, error on expression does not cascade
        ST_NON_FATAL_ERROR(@6, "type of the expression cannot be assigned as the declared type (TYPE02)\n");
      }
      // use the declared type, not the type of the expression
      $$ = ST_CREATE_VAR_IDENTIFIER($2->name, $4);
      st_free_data_type_info($4);
      if (is_in_global_scope && $6->expr_type != ST_COMPILE_TIME_EXPRESSION) {
        ST_UNIMPLEMENTED_ERROR();
      }
      CompileTimeExpression* compile_time_expr = (CompileTimeExpression*)$6;
      if (is_in_global_scope) {
        switch ($4->data_type) {
          case ST_INT_TYPE:
            ST_CODE_GEN("field static int %s = %d\n", $2->name, compile_time_expr->int_val);
            break;
          case ST_BOOL_TYPE:
            // booleans are treated as int, with true = 1, false = 0
            ST_CODE_GEN("field static int %s = %d\n", $2->name, compile_time_expr->bool_val);
            break;
          default:
            ST_UNIMPLEMENTED_ERROR();
        }
      } else {
        ST_CODE_GEN("istore %d\n", $$->local_number);
      }
      st_free_expression($6);
    }
  }
;

  /*
   * Since the source line has to be generate in the mid-rule, which causes
   * ambiguity, we have to left-factor them.
   */
opt_init_expr:
  ASSIGN expr
  { $$ = $2; }
| /* empty */
  { $$ = NULL; }
;

  /*
   * Returns a ConstIdentifier.
   * Global constants are held by the symbol table, and the compiler performs
   * constant propagation when encountering them in the program.
   */
const_decl:
  CONST ID ASSIGN
  {
    is_in_const_decl = true;
    ST_CODE_GEN_SOURCE_COMMENT(@1);
  }
  expr
  {
    // (1) the expression is not a variable reference in type of a dynamic array
    if ($5->data_type == ST_ARRAY_TYPE
        && $5->array_type_info->array_type == ST_DYNAMIC_ARRAY) {
      st_free_expression($5);
      ST_FATAL_ERROR(@5, "a constant identifier cannot be a 'dynamic array' (CONST01)\n");
    }
    $$ = ST_CREATE_CONST_IDENTIFIER($2->name, $5, $5);
    if (is_in_global_scope || $5->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      /* kept by the symbol table, no code gen */
    } else {
      // the value of the expression is on the top of the stack, store to the identifier
      ST_CODE_GEN("istore %d\n", $$->local_number);
    }
    st_free_expression($5);
    is_in_const_decl = false;
  }
| CONST ID ':' scalar_type ASSIGN
  {
    ST_CODE_GEN_SOURCE_COMMENT(@1);
    is_in_const_decl = true;
  }
  expr
  {
    // (1) the expression is not a variable reference in type of a dynamic array
    // although an expression with dynamic array type will never be assignable to a scalar type,
    // we'll check first to emphasize that a constant identifier cannot be a dynamic array
    if($7->data_type == ST_ARRAY_TYPE
        && $7->array_type_info->array_type == ST_DYNAMIC_ARRAY) {
      st_free_data_type_info($4);
      st_free_expression($7);
      ST_FATAL_ERROR(@4, "a constant identifier cannot be a 'dynamic array' (CONST01)\n");
    }
    // (2) the expression has the same type with the scalar_type
    StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($7);
    if (!st_is_assignable_type($4, &expr_type_info)) {
      ST_NON_FATAL_ERROR(@7, "type of the expression cannot be assigned as the declared type (TYPE02)\n");
      // error recovery: make the expression a run-time expression with the expected type
      st_free_expression($7);
      $7 = (Expression*)malloc(sizeof(RunTimeExpression));
      $7->expr_type = ST_RUN_TIME_EXPRESSION;
      ST_COPY_TYPE($7, $4);
    }
    // Use the declared type, not the type of the expression.
    // The exception is string constant, respect the true length.
    $$ = $7->data_type == ST_STRING_TYPE
        ? ST_CREATE_CONST_IDENTIFIER($2->name, $7, $7)
        : ST_CREATE_CONST_IDENTIFIER($2->name, $4, $7);
    st_free_data_type_info($4);
    if (is_in_global_scope || $7->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      /* kept by the symbol table, no code gen */
    } else {
      // the value of the expression is on the top of the stack, store to the identifier
      ST_CODE_GEN("istore %d\n", $$->local_number);
    }
    st_free_expression($7);
    is_in_const_decl = false;
  }
;

  /*
   * NOTE: we have to add the subprograms into the outmost scope,
   * so that they remain across the whole program
   */
subprog_decl:
  {
    // mid-rule: enter a function scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_FUNCTION_SCOPE_NAME);
  }
  function_decl
  {
    // the subprogram identifier is stored for the result statements to get the
    // return type and for type checks on recursive calls, but we don't want
    // it to be freed when the scope exit, so replace it with a NULL
    st_probe_environment(env, ST_FUNCTION_SCOPE_NAME)
        ->attribute = NULL;
    st_probe_environment(env, $2->name)
        ->attribute = NULL;
    st_exit_scope(&env);
    // (1) the name of the function should not be already declared
    if (st_probe_environment(env, $2->name)) {
      // error recovery: skip this declaration
      ST_NON_FATAL_ERROR(@2, "re-declaration of identifier '%s' (DECL01)\n", $2->name);
      st_free_identifier((Identifier*)$2);
    } else {
      Symbol* symbol = st_add_to_scope(env, $2->name);
      symbol->attribute = $2;
    }
  }
| {
    // mid-rule: enter a procedure scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_PROCEDURE_SCOPE_NAME);
  }
  procedure_decl
  {
    // the subprogram identifier is stored for type checks on recursive calls,
    // but we don't want it to be freed when the scope exit, so replace it with a NULL
    st_probe_environment(env, $2->name)->attribute = NULL;
    st_exit_scope(&env);
    // (1) the name of the procedure should not be already declared
    if (st_probe_environment(env, $2->name)) {
      // error recovery: skip this declaration
      ST_NON_FATAL_ERROR(@2, "re-declaration of identifier '%s' (DECL01)\n", $2->name);
      st_free_identifier((Identifier*)$2);
    } else {
      Symbol* symbol = st_add_to_scope(env, $2->name);
      symbol->attribute = $2;
    }
  }
;

procedure_decl:
  procedure_header opt_decl_or_stmt_list END ID
  {
    // Reset the location number since the stack frame of the procedure is popped.
    // NOTE: there isn't any local identifiers yet (excluding those inside
    // subprogram declarations, which use a difference stack frame), it is ok
    // that we reset the number to 0 instead of restore the number before the
    // subprogram declaration.
    local_number = 0;
    // (1) id is the same name as the one in the header
    if (strcmp($1->name, $4->name) != 0) {
      ST_NON_FATAL_ERROR(@4, "the name after 'end' should be the name of the 'subprogram' (SUB01)\n");
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
    // Reset the location number since the stack frame of the function is popped.
    // NOTE: there isn't any local identifiers yet (excluding those inside
    // subprogram declarations, which use a difference stack frame), it is ok
    // that we reset the number to 0 instead of restore the number before the
    // subprogram declaration.
    local_number = 0;
    // (1) id is the same name as the one in the header
    if (strcmp($1->name, $4->name) != 0) {
      ST_NON_FATAL_ERROR(@4, "the name after 'end' should be the name of the 'subprogram' (SUB01)\n");
    }
    $$ = $1;
  }
;

  /*
   * A list which must end with a result_stmt.
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
  { ST_NON_FATAL_ERROR(@1, "'function' must ends with a 'result' statement (SUB02)\n"); }
| stmt
  { ST_NON_FATAL_ERROR(@1, "'function' must ends with a 'result' statement (SUB02)\n"); }
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
    // mid-rule: add the procedure itself to the procedure scope since it's
    //           visible to the formals and the procedure body
    ProcedureSubprogram* procedure = malloc(sizeof(ProcedureSubprogram));
    procedure->id_type = ST_SUBPROGRAM_IDENTIFIER;
    procedure->subprogram_type = ST_PROCEDURE_SUBPROGRAM;
    procedure->name = st_strdup($2->name);
    // the formals of the procedure will be added in the later action
    procedure->formals = NULL;
    $<procedure>$ = procedure;
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = $<procedure>$;
  }
  '(' opt_formal_decl_list ')'
  {
    // (1) the types of the formals have to be recorded so can be checked on a call
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
    // mid-rule: add the function itself to the function scope since it's
    //           visible to the formals and the function body
    FunctionSubprogram* function = malloc(sizeof(FunctionSubprogram));
    function->id_type = ST_SUBPROGRAM_IDENTIFIER;
    function->subprogram_type = ST_FUNCTION_SUBPROGRAM;
    function->name = st_strdup($2->name);
    // the formals and the result type of the function will be added later
    function->formals = NULL;
    function->result_type = NULL;
    $<function>$ = function;
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = $<function>$;
    // also add to the special identifier for result statements to retrieve the
    // result type of the function
    Symbol* special_symbol = st_lookup_environment(env, ST_FUNCTION_SCOPE_NAME);
    special_symbol->attribute = $<function>$;
  }
  '(' opt_formal_decl_list ')' ':' type
  {
    // (1) the types of the formals and the result has to be recorded so can be checked on a call
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
  /*
   * NOTE: to make decl_or_stmt_list distinguishable from decl_or_stmt_list_end_with_result_list,
   * the result_stmt is handled separately instead of being put inside stmt
   */
| result_stmt
  { /* no check */ }
;

  /*
   * Returns a List of StDataTypeInfo.
   */
opt_formal_decl_list:
  formal_decl_list
  { $$ = $1; }
| /* empty */
  { $$ = NULL; }
;

  /*
   * Returns a List of StDataTypeInfo.
   */
formal_decl_list:
  formal_decl_list ',' formal_decl
  { $$ = list_create($3, $1); }
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
  formal_decl_
  {
    // (1) re-declaration error if name exists in the current scope
    if (st_probe_environment(env, $1->name)) {
      ST_NON_FATAL_ERROR(@1, "re-declaration of identifier '%s' (DECL01)\n", $1->name);
      // error recovery: postfix a underscore to the name until no more collision
      // (in case it's re-declared several times).
      do {
        char* mangled_name = malloc(sizeof(char) * (strlen($1->name) + 1 + 1));
        strcpy(mangled_name, $1->name);
        strcat(mangled_name, "_");
        free($1->name);
        $1->name = mangled_name;
      } while (st_probe_environment(env, $1->name));
    }
    // add the identifier to the scope
    Symbol* symbol = st_add_to_scope(env, $1->name);
    symbol->attribute = $1;
    // add the identifier to the scope
    $$ = malloc(sizeof(StDataTypeInfo));
    ST_COPY_TYPE($$, $1);
  }
;

  /*
   * An intermediate non-terminal so they can share the same action in formal_decl.
   * Returns an Identifier.
   */
formal_decl_:
  ID ':' formal_type
  {
    // (1) the identifier should be marked as constant
    // formals are never compile-time
    RunTimeConstIdentifier* id = malloc(sizeof(RunTimeConstIdentifier));
    id->id_type = ST_CONST_IDENTIFIER;
    id->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
    id->name = st_strdup($1->name);
    if (is_in_global_scope) {
      id->local_number = -1;
    } else {
      id->local_number = local_number++;
    }
    ST_COPY_TYPE(id, $3);
    $$ = (Identifier*)id;
    st_free_data_type_info($3);
  }
| VAR ID ':' formal_type
  {
    // (1) the identifier should be recorded under the scope marked as mutable
    VarIdentifier* id = malloc(sizeof(VarIdentifier));
    id->id_type = ST_VAR_IDENTIFIER;
    id->name = st_strdup($2->name);
    if (is_in_global_scope) {
      id->local_number = -1;
    } else {
      id->local_number = local_number++;
    }
    ST_COPY_TYPE(id, $4);
    $$ = (Identifier*)id;
    st_free_data_type_info($4);
  }
;

formal_type:
  type
  {
    // (1) if the formal type is an array type, it cannot be a dynamic array
    if ($1->data_type == ST_ARRAY_TYPE
        && $1->array_type_info->array_type != ST_STATIC_ARRAY) {
      st_free_data_type_info($1);
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
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    // (1) the max length of the string is run-time determined
    $$->string_type_info->max_length = ST_STAR_STRING_LENGTH;
  }
;

 /*
  * NOTE: Can nest a normal type or a star string, but not a star array.
  * This distinguishes it from the formal_type, so a new non-terminal is introduced.
  */
formal_star_array_nested_type:
  type
  { $$ = $1; }
| formal_star_string_type
  { $$ = $1; }
;

  /*
   * A star array is a static array with special upper-bound.
   */
formal_star_array_type:
  ARRAY expr '.' '.' '*' OF formal_star_array_nested_type
  {
    #define CLEAN_UP \
      st_free_expression($2); \
      st_free_data_type_info($7);

    // (1) the expression at the lower bound must be a compile-time expression
    if ($2->expr_type != ST_COMPILE_TIME_EXPRESSION) {
      CLEAN_UP;
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must be a compile-time expression (ARR01)\n");
    }
    CompileTimeExpression* lower_bound = (CompileTimeExpression*)$2;
    // (2) the expression at the lower bound must have type int
    if (lower_bound->data_type != ST_INT_TYPE) {
      CLEAN_UP;
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must have type 'int' (ARR02)\n");
    }
    // (3) type may also be an array, but such array type must be a static array
    // NOTE: a star array is also a static array, but is excluded syntactically
    if ($7->data_type == ST_ARRAY_TYPE
        && $7->array_type_info->array_type != ST_STATIC_ARRAY) {
      CLEAN_UP;
      ST_FATAL_ERROR(@7, "type of an 'array' must be a 'static array' (ARR03)\n");
    }
    // (4) lower bound must have positive value
    if (lower_bound->int_val < 1) {
      CLEAN_UP;
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
    CLEAN_UP;
    #undef CLEAN_UP
  }
;

  /*
   * Returns a Subprogram.
   */
subprog_call:
  ID '(' opt_expr_comma_list ')'
  {
    #define CLEAN_UP \
      { \
        List* actual = $3; \
        while (actual) { \
          st_free_expression(actual->val); \
          actual = actual->rest; \
        } \
        list_delete($3); \
      }

    Symbol* symbol = st_lookup_environment(env, $1->name);
    if (!symbol) {
      CLEAN_UP;
      ST_FATAL_ERROR(@1, "identifier '%s' is not declared (REF01)\n", $1->name);
    }
    Identifier* id = (Identifier*)symbol->attribute;
    if (id->id_type != ST_SUBPROGRAM_IDENTIFIER) {
      CLEAN_UP;
      ST_FATAL_ERROR(@1, "identifier '%s' is not a subprogram (CALL01)\n", $1->name);
    }
    Subprogram* subprogram = (Subprogram*)id;
    $$ = subprogram;
    // (1) the number of the expression should match the number of the declared formals
    const int num_of_formals = list_length(subprogram->formals);
    const int num_of_actuals = list_length($3);
    if (num_of_actuals != num_of_formals) {
      // error recovery: skip type check of parameters
      ST_NON_FATAL_ERROR(@3, "mismatch number of formals, expect '%d' but get '%d' (CALL02)\n", num_of_formals, num_of_actuals);
    } else {
      // (2) each expressions in the list should have their types match the declared formal types
      List* formals = subprogram->formals;
      List* actuals = $3;
      while (actuals) {
        StDataTypeInfo* formal_type = (StDataTypeInfo*)formals->val;
        Expression* actual = (Expression*)actuals->val;
        StDataTypeInfo actual_type = ST_MAKE_DATA_TYPE_INFO(actual);
        if (!st_is_assignable_type(formal_type, &actual_type)) {
          ST_NON_FATAL_ERROR(@3, "type of the actual parameter cannot be assigned as type of the formal parameter (CALL03)\n");
        }
        actuals = actuals->rest;
        formals = formals->rest;
      }
    }
    CLEAN_UP;
    #undef CLEAN_UP
  }
;

if_stmt:
  IF bool_expr then_block END IF
  { st_free_expression($2); }
| IF bool_expr then_block else_block END IF
  { st_free_expression($2); }
;

then_block:
  THEN
  {
    // mid-rule
    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
  }
  opt_decl_or_stmt_list
  { st_exit_scope(&env); }
;

else_block:
  ELSE
  {
    // mid-rule
    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
  }
  opt_decl_or_stmt_list
  { st_exit_scope(&env); }
;

result_stmt:
  RESULT expr
  {
    // (1) expr must have the same type as the declared result type
    // get the current function through the special identifier name
    Symbol* symbol = st_lookup_environment(env, ST_FUNCTION_SCOPE_NAME);
    if (symbol) {
      FunctionSubprogram* function = (FunctionSubprogram*)symbol->attribute;
      StDataTypeInfo expr_type_info = ST_MAKE_DATA_TYPE_INFO($2);
      if (!st_is_assignable_type(function->result_type, &expr_type_info)) {
        ST_NON_FATAL_ERROR(@2, "type of the 'result' expression cannot be assigned as the result type of the 'function' (STMT05)\n");
      }
    } else {
      ST_NON_FATAL_ERROR(@1, "'result' statement can only appear in the body of 'function's (STMT02)\n");
    }
    st_free_expression($2);
  }
;

exit_stmt:
  EXIT
  { /* no check */ }
| EXIT WHEN bool_expr
  { st_free_expression($3); }
;

loop_stmt:
  LOOP opt_decl_or_stmt_list END LOOP
  { /* no check */ }
;

for_stmt:
  for_header opt_decl_or_stmt_list END FOR
  { /* no check */ }
;

for_header:
  FOR ':' for_range
  { /* no check */ }
| FOR DECREASING ':' for_range
  { /* no check */ }
| FOR ID ':' for_range
  {
    // (1) add id into the scope and marked as constant
    RunTimeConstIdentifier* id = malloc(sizeof(RunTimeConstIdentifier));
    id->id_type = ST_CONST_IDENTIFIER;
    id->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
    id->name = st_strdup($2->name);
    id->data_type = ST_INT_TYPE;
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = id;
  }

| FOR DECREASING ID ':' for_range
  {
    // (1) add id into the scope and marked as constant
    RunTimeConstIdentifier* id = malloc(sizeof(RunTimeConstIdentifier));
    id->id_type = ST_CONST_IDENTIFIER;
    id->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER;
    id->name = st_strdup($3->name);
    id->data_type = ST_INT_TYPE;
    Symbol* symbol = st_add_to_scope(env, $3->name);
    symbol->attribute = id;
  }
;

for_range:
  expr '.' '.' expr
  {
    // (1) the expressions must be both of type int
    if ($1->data_type != ST_INT_TYPE) {
      ST_NON_FATAL_ERROR(@1, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
    if ($4->data_type != ST_INT_TYPE) {
      ST_NON_FATAL_ERROR(@4, "range of a 'for' statement must have type 'int' (FOR01)\n");
    }
    st_free_expression($1);
    st_free_expression($4);
  }
;

block:
  BEGIN_
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  opt_decl_or_stmt_list END
  { ST_CODE_GEN_SOURCE_COMMENT(@4); }
;

get_stmt:
  GET var_ref_comma_list
  {
    List* refs = $2;
    while (refs) {
      Reference* ref = (Reference*)refs->val;
      // (1) all variable references should be mutable
      if (ref->is_const) {
        ST_NON_FATAL_ERROR(@2, "references in 'get' statement cannot be constant (STMT07)\n");
      }
      // (2) no variable reference can be in type array
      if (ref->data_type == ST_ARRAY_TYPE) {
        ST_NON_FATAL_ERROR(@2, "references in 'get' statement cannot have type 'array' (STMT08)\n");
      }
      // free at the same time since not needed later
      st_free_reference(refs->val);
      refs = refs->rest;
    }
    list_delete($2);
  }
;

var_ref_comma_list:
  var_ref_comma_list ',' var_ref
  { $$ = list_create($3, $1); }
| var_ref
  { $$ = list_create($1, NULL); }
;

put_stmt:
  PUT
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  expr_comma_list
  {
    List* exprs = $3;
    // (1) no expression can be in type array
    while (exprs) {
      if (((Expression*)exprs->val)->data_type == ST_ARRAY_TYPE) {
        ST_NON_FATAL_ERROR(@3, "expressions in 'put' statement cannot have type 'array' (STMT06)\n");
      }
      // free at the same time since not needed later
      st_free_expression(exprs->val);
      exprs = exprs->rest;
    }
    list_delete($3);
  }
  opt_dot_dot
  { /* no check */ }
;

opt_dot_dot:
  '.' '.'
  { ST_CODE_GEN_COMMENT(".., no newline"); }
| /* empty */
  {
    ST_CODE_GEN_COMMENT("newline");
    ST_CODE_GEN("getstatic java.io.PrintStream java.lang.System.out\n");
    ST_CODE_GEN("invokevirtual void java.io.PrintStream.println()\n");
  }
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
  expr_comma_list ','
  { ST_CODE_GEN("getstatic java.io.PrintStream java.lang.System.out\n"); }
  expr
  {
    $$ = list_create($4, $1);
    ST_CODE_GEN("invokevirtual void java.io.PrintStream.print(");
    switch ($4->data_type) {
      case ST_INT_TYPE:
        ST_CODE_GEN("int");
        break;
      case ST_BOOL_TYPE:
        ST_CODE_GEN("boolean");
        break;
      case ST_STRING_TYPE:
        ST_CODE_GEN("java.lang.String");
        break;
      default:
        ST_UNIMPLEMENTED_ERROR();
    }
    ST_CODE_GEN(")\n");
  }
| { ST_CODE_GEN("getstatic java.io.PrintStream java.lang.System.out\n"); }
  expr
  {
    $$ = list_create($2, NULL);
    ST_CODE_GEN("invokevirtual void java.io.PrintStream.print(");
    switch ($2->data_type) {
      case ST_INT_TYPE:
        ST_CODE_GEN("int");
        break;
      case ST_BOOL_TYPE:
        ST_CODE_GEN("boolean");
        break;
      case ST_STRING_TYPE:
        ST_CODE_GEN("java.lang.String");
        break;
      default:
        ST_UNIMPLEMENTED_ERROR();
    }
    ST_CODE_GEN(")\n");
  }
;

  /*
   * Returns an Expression.
   */
bool_expr:
  var_ref
  {
    // (1) the reference must be of a variable in type bool
    if ($1->data_type != ST_BOOL_TYPE) {
      ST_NON_FATAL_ERROR(@1, "'boolean' expression must have type 'bool' (EXPR08)\n");
      $$ = st_create_recovery_expression(ST_BOOL_TYPE);
    } else {
      // only a id reference may be a compile-time expression
      if ($1->ref_type == ST_IDENTIFIER_REFERENCE
            && ((IdentifierReference*)$1)->id->id_type
                == ST_CONST_IDENTIFIER
            && ((ConstIdentifier*)((IdentifierReference*)$1)->id)->const_id_type
                == ST_COMPILE_TIME_CONST_IDENTIFIER) {
          $$ = (Expression*)malloc(sizeof(CompileTimeExpression));
          $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
          $$->data_type = ST_BOOL_TYPE;
          ((CompileTimeExpression*)$$)->bool_val
              = ((CompileTimeConstIdentifier*)((IdentifierReference*)$1)->id)->bool_val;
      } else {
        $$ = (Expression*)malloc(sizeof(RunTimeExpression));
        $$->expr_type = ST_RUN_TIME_EXPRESSION;
        $$->data_type = ST_BOOL_TYPE;
      }
    }
    st_free_reference($1);
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
    // (1) the expression should have type bool
    if ($2->data_type != ST_BOOL_TYPE) {
      ST_NON_FATAL_ERROR(@2, "'boolean' expression must have type 'bool' (EXPR08)\n");
      st_free_expression($2);
      $2 = st_create_recovery_expression(ST_BOOL_TYPE);
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
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    // (1) the max length of the string is 255
    $$->string_type_info->max_length = 255;
  }
| STRING '(' expr ')'
  {
    bool has_error = false;
    // (1) the expression must have type int
    if ($3->data_type != ST_INT_TYPE) {
      ST_NON_FATAL_ERROR(@3, "max length of a 'string' must have type 'int' (STR01)\n");
      has_error = true;
    } else if ($3->expr_type != ST_COMPILE_TIME_EXPRESSION) {
      // (2) the expression must be a compile-time expression
      ST_NON_FATAL_ERROR(@3, "max length of a 'string' must be a compile-time expression (STR02)\n");
      has_error = true;
    }
    if (has_error) {
      // error recovery: make expr an compile-time expression in type int,
      // and the max length of the string be 255
      st_free_expression($3);
      $3 = (Expression*)malloc(sizeof(CompileTimeExpression));
      $3->expr_type = ST_COMPILE_TIME_EXPRESSION;
      $3->data_type = ST_INT_TYPE;
      ((CompileTimeExpression*)$3)->int_val = 255;
    }
    CompileTimeExpression* compile_time_expr = (CompileTimeExpression*)$3;
    // (3) the expression must be positive and cannot be greater than 255
    if (compile_time_expr->int_val < 1 || compile_time_expr->int_val > 255) {
      ST_NON_FATAL_ERROR(@3, "max length of a 'string' must be in range 1 ~ 255 (STR03)\n");
      // error recovery: fix the length to 255
      compile_time_expr->int_val = 255;
    }
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    $$->string_type_info->max_length = compile_time_expr->int_val;
    st_free_expression($3);
  }
;

  /*
   * Returns an StDataTypeInfo.
   */
array_type:
  ARRAY expr '.' '.' expr OF type
  {
    #define CLEAN_UP \
      st_free_expression($2); \
      st_free_expression($5); \
      st_free_data_type_info($7);

    // (1) the expression of the lower bound must be a compile-time expression
    if ($2->expr_type != ST_COMPILE_TIME_EXPRESSION) {
      CLEAN_UP;
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must be a compile-time expression (ARR01)\n");
    }
    CompileTimeExpression* lower_bound = (CompileTimeExpression*)$2;
    // (2) the expressions must both have type int
    if (lower_bound->data_type != ST_INT_TYPE) {
      CLEAN_UP;
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must have type 'int' (ARR02)\n");
    }
    if ($5->data_type != ST_INT_TYPE) {
      CLEAN_UP;
      ST_FATAL_ERROR(@5, "upper bound of an 'array' must have type 'int' (ARR02)\n");
    }
    // (3) type may also be an array, but the upper bound of a nested array has
    //     to be a compile-time expression as also, which means we have to record
    //     the bounds of an array type. This is also for type equality checks
    if ($7->data_type == ST_ARRAY_TYPE
        && $7->array_type_info->array_type != ST_STATIC_ARRAY) {
      CLEAN_UP;
      ST_FATAL_ERROR(@7, "type of an 'array' must be a 'static array' (ARR03)\n");
    }
    // (4) lower bound must have positive value
    if (lower_bound->int_val < 1) {
      CLEAN_UP;
      ST_FATAL_ERROR(@2, "lower bound of an 'array' must be positive (ARR04)\n");
    }
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_ARRAY_TYPE;
    if ($5->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      CompileTimeExpression* upper_bound = (CompileTimeExpression*)$5;
      // (5) upper bound of a static array must have positive value
      if (upper_bound->int_val < 1) {
        CLEAN_UP;
        free($$);  // in the middle of the construction of $$, has to clean as also
        ST_FATAL_ERROR(@5, "upper bound of a 'static array' must be positive (ARR05)\n");
      }
      // (6) the upper bound of a static array must be greater than the lower bound
      if (upper_bound->int_val <= lower_bound->int_val) {
        CLEAN_UP;
        free($$);  // in the middle of the construction of $$, has to clean as also
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
    CLEAN_UP;
    #undef CLEAN_UP
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
    Symbol* symbol = st_lookup_environment(env, $1->name);
    // (1) the id has to be declared
    if (!symbol) {
      ST_FATAL_ERROR(@1, "identifier '%s' is not declared (REF01)\n", $1->name);
    }
    Identifier* id = symbol->attribute;
    // (2) the id can't be a subprogram
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
    #define CLEAN_UP \
      { \
        List* curr = $2; \
        while (curr) { \
          st_free_expression(curr->val); \
          curr = curr->rest; \
        } \
        list_delete($2); \
      }

    Symbol* symbol = st_lookup_environment(env, $1->name);
    // (1) id can't be a subprogram
    if (!symbol) {
      CLEAN_UP;
      ST_FATAL_ERROR(@1, "identifier '%s' is not declared (REF01)\n", $1->name);
    }
    Identifier* id = symbol->attribute;
    // (2) id can only have type string or array
    if (id->id_type == ST_SUBPROGRAM_IDENTIFIER) {
      CLEAN_UP;
      ST_FATAL_ERROR(@1, "identifier '%s' is a 'subprogram', cannot be used as reference (REF02)\n", $1->name);
    }

    if (id->data_type == ST_STRING_TYPE) {
      // (3) if id has type string, the subscript list must have length 1
      if (list_length($2) != 1) {
        CLEAN_UP;
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
      // (4) if id has type array, the length of the list cannot exceed the dimension of the array
      // the expression may be run-time expressions, so no range check
      if (num_of_sub > dim_of_arr) {
        CLEAN_UP;
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
      // free the subscript list
      CLEAN_UP;
    } else {
      // (2) id can only have type string or array
      CLEAN_UP;
      ST_FATAL_ERROR(@1, "identifier '%s' has unsubscriptable type (REF04)\n", $1->name);
    }
    #undef CLEAN_UP
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
    // (1) the expression should have type int
    if ($2->data_type != ST_INT_TYPE) {
      ST_NON_FATAL_ERROR(@2, "subscript must have type 'int' (REF06)\n");
      st_free_expression($2);
      $2 = st_create_recovery_expression(ST_INT_TYPE);
    }
    $$ = list_create($2, NULL);
  }
;

  /*
   * Returns an Expression.
   * Has the value on the top of the stack.
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
            ST_COPY_TYPE($$, id);
            CompileTimeConstIdentifier* compile_time_const_id = (CompileTimeConstIdentifier*)id;
            ST_COPY_SCALAR_VALUE((CompileTimeExpression*)$$, compile_time_const_id);
            // constant propagation
            if (!is_in_const_decl && !is_in_global_scope) {
              switch (id->data_type) {
                case ST_INT_TYPE:
                  ST_CODE_GEN("sipush %d\n", compile_time_const_id->int_val);
                  break;
                case ST_BOOL_TYPE:
                  ST_CODE_GEN("iconst_%d\n", compile_time_const_id->bool_val);
                  break;
                case ST_STRING_TYPE:
                  ST_CODE_GEN("ldc %s\n", compile_time_const_id->string_val);
                  break;
                default:
                  ST_UNIMPLEMENTED_ERROR();
              }
            }
          } else if (((ConstIdentifier*)id)->const_id_type == ST_RUN_TIME_CONST_IDENTIFIER) {
            $$ = malloc(sizeof(RunTimeExpression));
            $$->expr_type = ST_RUN_TIME_EXPRESSION;
            ST_COPY_TYPE($$, $1);
            switch (id->data_type) {
              case ST_INT_TYPE:
                // since boolean uses int as also, can fallthrough
              case ST_BOOL_TYPE:
                if (st_is_global(id)) {
                  ST_CODE_GEN("iload %s.%s\n", code_gen_class_name, id->name);
                } else {
                  ST_CODE_GEN("iload %d\n", id->local_number);
                }
                break;
              case ST_STRING_TYPE:
                // variable strings are not allowed
              default:
                ST_UNIMPLEMENTED_ERROR();
            }
          } else {
            ST_UNREACHABLE();
          }
          break;
        case ST_VAR_IDENTIFIER:
          $$ = malloc(sizeof(RunTimeExpression));
          $$->expr_type = ST_RUN_TIME_EXPRESSION;
          ST_COPY_TYPE($$, $1);
          switch (id->data_type) {
            case ST_INT_TYPE:
              // since boolean uses int as also, can fallthrough
            case ST_BOOL_TYPE:
              if (st_is_global(id)) {
                ST_CODE_GEN("iload %s.%s\n", code_gen_class_name, id->name);
              } else {
                ST_CODE_GEN("iload %d\n", id->local_number);
              }
              break;
            case ST_STRING_TYPE:
              // variable strings are not allowed
            default:
              ST_UNIMPLEMENTED_ERROR();
          }
          break;
        default:
          ST_UNREACHABLE();
      }
      // cannot free the id since its held by the symbol table
      st_free_reference($1);
    } else if ($1->ref_type == ST_ARRAY_SUBSCRIPT_REFERENCE) {
      $$ = malloc(sizeof(RunTimeExpression));
      $$->expr_type = ST_RUN_TIME_EXPRESSION;
      ST_COPY_TYPE($$, $1);
      st_free_reference($1);
      ST_UNIMPLEMENTED_ERROR();
    } else {
      ST_UNREACHABLE();
    }
  }
| explicit_const
  { $$ = (Expression*)$1; }
| subprog_call
  {
    // (1) always a run-time expression
    if ($1->subprogram_type != ST_FUNCTION_SUBPROGRAM) {
      assert($1->subprogram_type == ST_PROCEDURE_SUBPROGRAM);
      ST_FATAL_ERROR(@1, "'procedure' call cannot be an expression (EXPR01)\n");
    }
    // (2) the subprogram has to be a function
    $$ = (Expression*)malloc(sizeof(RunTimeExpression));
    $$->expr_type = ST_RUN_TIME_EXPRESSION;
    ST_COPY_TYPE($$, ((FunctionSubprogram*)$1)->result_type);
    // the id of $$ is from the symbol table, so no free here
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
    if (is_in_global_scope) {
      // will be generated with the declaration
    } else if (is_in_const_decl) {
      // compile-time constant identifiers are record by the symbol table, no code
    } else {
      // push onto the operand stack
      ST_CODE_GEN("sipush %d\n", $1);
    }
  }
| REAL_CONST
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_REAL_TYPE;
    $$->real_val = $1;
    ST_UNIMPLEMENTED_ERROR();
  }
| STR_CONST
  {
    // (1) record the length of the string
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_STRING_TYPE;
    $$->string_type_info = malloc(sizeof(StStringTypeInfo));
    $$->string_type_info->max_length = strlen($1);
    $$->string_val = st_strdup($1);
    if (is_in_global_scope) {
      // will be generated with the declaration
    } else if (is_in_const_decl) {
      // compile-time constant identifiers are record by the symbol table, no code
    } else {
      ST_CODE_GEN("ldc \"%s\"\n", $1);
    }
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
    if (is_in_global_scope) {
      // will be generated with the declaration
    } else if (is_in_const_decl) {
      // compile-time constant identifiers are record by the symbol table, no code
    } else {
      // push onto the operand stack
      ST_CODE_GEN("iconst_1\n");
    }
  }
| FALSE
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_BOOL_TYPE;
    $$->bool_val = false;
    if (is_in_global_scope) {
      // will be generated with the declaration
    } else if (is_in_const_decl) {
      // compile-time constant identifiers are record by the symbol table, no code
    } else {
      // push onto the operand stack
      ST_CODE_GEN("iconst_0\n");
    }
  }
;

operation:
  numeric_operation %prec NUMERIC_OP
  { $$ = $1; }
| comparison_operation %prec COMPARISON_OP
  { $$ = $1; }
| boolean_operation %prec BOOLEAN_OP
  { $$ = $1; }
| sign_operation %prec SIGN_OP
  { $$ = $1; }
;

  /*
   * Returns an Expression.
   */
numeric_operation:
  expr '+' expr
  {
    #define CLEAN_UP \
      st_free_expression($1); \
      st_free_expression($3);
    /*
     * Handle string concatenation first, then elementary arithmetic
     */
    // TODO: support STR04 and STR05 as non-fatal errors by resulting a run-time string expression
    // (1) string can only concatenate with string
    if ($1->data_type != $3->data_type
        && ($1->data_type == ST_STRING_TYPE || $3->data_type == ST_STRING_TYPE)) {
      CLEAN_UP;
      ST_FATAL_ERROR(@2, "operands of 'string' concatenation must both have type 'string' (STR04)\n");
    }
    // is string concatenation
    if ($1->data_type == ST_STRING_TYPE && $3->data_type == ST_STRING_TYPE) {
      // (2) if both expressions are compile-time expressions, the operation is also a compile-time operation
      if ($1->expr_type == ST_COMPILE_TIME_EXPRESSION && $3->expr_type == ST_COMPILE_TIME_EXPRESSION) {
        CompileTimeExpression* lhs = (CompileTimeExpression*)$1;
        CompileTimeExpression* rhs = (CompileTimeExpression*)$3;
        $$ = (Expression*)malloc(sizeof(CompileTimeExpression));
        $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
        $$->data_type = ST_STRING_TYPE;
        $$->string_type_info = malloc(sizeof(StStringTypeInfo));
        $$->string_type_info->max_length = strlen(lhs->string_val) + strlen(rhs->string_val);
        // (3) the length of the result string must not exceed 255
        if ($$->string_type_info->max_length > 255) {
          CLEAN_UP;
          // in the middle of the construction of $$, make it a valid expression and free as also
          ((CompileTimeExpression*)$$)->string_val = NULL;
          st_free_expression($$);
          ST_FATAL_ERROR(@1, "in compile-time 'string' concatenation, length of the result 'string' must not exceed 255 (STR05)\n");
        }
        ((CompileTimeExpression*)$$)->string_val = malloc(sizeof(char) * ($$->string_type_info->max_length + 1));
        strcpy(((CompileTimeExpression*)$$)->string_val, lhs->string_val);
        strcat(((CompileTimeExpression*)$$)->string_val, rhs->string_val);
      } else {
        $$ = (Expression*)malloc(sizeof(RunTimeExpression));
        $$->expr_type = ST_RUN_TIME_EXPRESSION;
        $$->data_type = ST_STRING_TYPE;
        $$->string_type_info = malloc(sizeof(StStringTypeInfo));
        $$->string_type_info->max_length
            = $1->string_type_info->max_length + $3->string_type_info->max_length;
        // saturate
        if ($$->string_type_info->max_length > 255) {
          $$->string_type_info->max_length = 255;
        }
      }
    } else { // is arithmetic
      // (4) expressions can't have type other than int and real
      bool has_error = false;
      if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
        ST_NON_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
        has_error = true;
      }
      if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
        ST_NON_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
        has_error = true;
      }
      $$ = has_error
          ? st_create_recovery_expression(ST_INT_TYPE)
          : ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, +, $3);
    }
    CLEAN_UP;
    #undef CLEAN_UP
  }
| expr '-' expr
  {
    // (1) expressions can't have type other than int and real
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_INT_TYPE)
        : ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, -, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr '*' expr
  {
    // (1) expressions can't have type other than int and real
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_INT_TYPE)
        : ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, *, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr '/' expr
  {
    // (1) expressions can't have type other than int and real
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'arithmetic' operation must have type 'int' or 'real' (EXPR06)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_INT_TYPE)
        : ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, /, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr MOD expr
  {
    // (1) both of the expressions must have type int
    bool has_error = false;
    if ($1->data_type != ST_INT_TYPE) {
      ST_NON_FATAL_ERROR(@1, "operand of 'mod' operation must have type 'int' (EXPR07)\n");
      has_error = true;
    }
    if ($3->data_type != ST_INT_TYPE) {
      ST_NON_FATAL_ERROR(@3, "operand of 'mod' operation must have type 'int' (EXPR07)\n");
      has_error = true;
    }
    if (has_error) {
      $$ = st_create_recovery_expression(ST_INT_TYPE);
    } else {
      if ($1->expr_type == ST_COMPILE_TIME_EXPRESSION
          && $3->expr_type == ST_COMPILE_TIME_EXPRESSION) {
        $$ = (Expression*)malloc(sizeof(CompileTimeExpression));
        $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
        $$->data_type = ST_INT_TYPE;
        ((CompileTimeExpression*)$$)->int_val
            = ((CompileTimeExpression*)$1)->int_val
                % ((CompileTimeExpression*)$3)->int_val;
      } else {
        $$ = (Expression*)malloc(sizeof(RunTimeExpression));
        $$->expr_type = ST_RUN_TIME_EXPRESSION;
        $$->data_type = ST_INT_TYPE;
      }
    }
    st_free_expression($1);
    st_free_expression($3);
  }
;

comparison_operation:
 /*
  * All of the comparison operations are the same.
  * (1) expressions can't have type other than int, real, and string
  * (2) both expressions must have the same type
  */
  expr '<' expr
  {
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    // skip if operands already has type errors
    if (!has_error && $1->data_type != $3->data_type) {
      ST_NON_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, <, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr '>' expr
  {
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    // skip if operands already has type errors
    if (!has_error && $1->data_type != $3->data_type) {
      ST_NON_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, >, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr '=' expr
  {
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    // skip if operands already has type errors
    if (!has_error && $1->data_type != $3->data_type) {
      ST_NON_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, ==, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr LE expr
  {
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    // skip if operands already has type errors
    if (!has_error && $1->data_type != $3->data_type) {
      ST_NON_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, <=, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr GE expr
  {
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    // skip if operands already has type errors
    if (!has_error && $1->data_type != $3->data_type) {
      ST_NON_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, >=, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr NE expr
  {
    bool has_error = false;
    if (!ST_HAS_ONE_OF_DATA_TYPES($1, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@1, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    if (!ST_HAS_ONE_OF_DATA_TYPES($3, ST_INT_TYPE, ST_REAL_TYPE, ST_STRING_TYPE)) {
      ST_NON_FATAL_ERROR(@3, "operand of 'comparison' operation have type 'int', 'real', or 'string' (EXPR04)\n");
      has_error = true;
    }
    // skip if operands already has type errors
    if (!has_error && $1->data_type != $3->data_type) {
      ST_NON_FATAL_ERROR(@1, "operands of 'comparison' operation must have the same type (EXPR05)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, !=, $3);
    st_free_expression($1);
    st_free_expression($3);
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
    // (1) both expressions must have type bool
    bool has_error = false;
    if ($1->data_type != ST_BOOL_TYPE) {
      ST_NON_FATAL_ERROR(@1, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
      has_error = true;
    }
    if ($3->data_type != ST_BOOL_TYPE) {
      ST_NON_FATAL_ERROR(@3, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, &&, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr OR expr
  {
    // (1) both expressions must have type bool
    bool has_error = false;
    if ($1->data_type != ST_BOOL_TYPE) {
      ST_NON_FATAL_ERROR(@1, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
      has_error = true;
    }
    if ($3->data_type != ST_BOOL_TYPE) {
      ST_NON_FATAL_ERROR(@3, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
      has_error = true;
    }
    $$ = has_error
        ? st_create_recovery_expression(ST_BOOL_TYPE)
        : ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, ||, $3);
    st_free_expression($1);
    st_free_expression($3);
  }
| NOT expr
  {
    // (1) the expression must have type bool
    if ($2->data_type != ST_BOOL_TYPE) {
      ST_NON_FATAL_ERROR(@2, "operand of 'boolean' operation must have type 'bool' (EXPR03)\n");
      $$ = st_create_recovery_expression(ST_BOOL_TYPE);
    } else {
      // (2) if the expression is a compile-time expression, the operation is also a compile-time operation
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
    st_free_expression($2);
    ST_CODE_GEN("sipush 1\n");
    ST_CODE_GEN("ixor\n");
  }
;

  /*
   * All of the sign operations are the same.
   * (1) the expression must have type int or real
   */
sign_operation:
  '+' expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($2, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@2, "operand of 'sign' operation must have type 'int' or 'real' (EXPR02)\n");
      // NOTE: 'int' can be implicitly converted to 'real', so choose 'int'
      $$ = st_create_recovery_expression(ST_INT_TYPE);
    } else {
      $$ = ST_CREATE_UNARY_SIGN_EXPRESSION(+, $2);
    }
    st_free_expression($2);
  }
| '-' expr
  {
    if (!ST_HAS_ONE_OF_DATA_TYPES($2, ST_INT_TYPE, ST_REAL_TYPE)) {
      ST_NON_FATAL_ERROR(@2, "operand of 'sign' operation must have type 'int' or 'real' (EXPR02)\n");
      // NOTE: 'int' can be implicitly converted to 'real', so choose 'int'
      $$ = st_create_recovery_expression(ST_INT_TYPE);
    } else {
      $$ = ST_CREATE_UNARY_SIGN_EXPRESSION(-, $2);
    }
    st_free_expression($2);
  }
;

%%
extern char* input_filename;

void yyerror(const char *msg) {
  fprintf(stderr, "%s:%d:%d: %s\n",
      input_filename, yylloc.first_line, yylloc.first_column, msg);
}
