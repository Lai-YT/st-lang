%{
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

  extern char* input_filename;

  #ifndef ST_UNSUPPORTED_FEATURE
  #define ST_UNSUPPORTED_FEATURE(yylloc, ...) \
    { \
      fprintf(stderr, "%s:%d:%d: error: use of unsupported feature (", \
              input_filename, (yylloc).first_line, (yylloc).first_column); \
      fprintf(stderr, __VA_ARGS__); \
      fprintf(stderr, ")\n"); \
      YYABORT; \
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

  /// @brief called for each syntax error
  void yyerror(const char *s);

  /// @brief Compile-time constant identifiers don't generate code, so we need
  /// this flag to tell the expression not the do so.
  static bool is_in_const_decl = false;

  /// @brief To make sure every generated labels are unique.
  static int label_number = 0;

  typedef enum ForLoopKind {
    INCREASING_LOOP,
    DECREASING_LOOP,
  } ForLoopKind;

  /// @brief Since the construct of for_stmt is split into several non-terminals,
  /// we create a structure and store it into the symbol table to share across the non-terminals.
  typedef struct LoopInfo {
    /// @brief The label number of the begin branch.
    int begin_branch;
    /// @brief The label number of the end branch.
    int end_branch;
    /// @note ONLY used by the for-loops.
    /// @note We'll have the name be a shallow copy from the Identifier,
    /// so do not free this.
    char* name_of_counter;
    /// @note ONLY used by the for-loops.
    ForLoopKind for_loop_kind;
  } LoopInfo;
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
  int label_number;
  LoopInfo* loop_info;
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
%type subprog_decl if_stmt if_body then_block result_stmt exit_stmt
%type loop_stmt for_stmt for_header for_range block get_stmt put_stmt opt_dot_dot
  /* to enforce ending with result statement in a function syntactically */
%type opt_decl_or_stmt_list_end_with_result_list decl_or_stmt_list_end_with_result_list decl_or_stmt_or_result

/* non-terminals with semantic value */
%type <expr> expr operation sign_operation numeric_operation comparison_operation boolean_operation opt_init_expr
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
%type <actuals> opt_expr_comma_list expr_comma_list put_expr_comma_list
%type <subprogram> subprog_call
%type <references> var_ref_comma_list
%type <label_number> then_block

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
    INIT_INDENTION();
    code_gen_class_name = st_strdup(input_filename_stem);
    ST_CODE_GEN("%sclass %s {\n", indentions, code_gen_class_name);
    is_in_global_scope = true;
    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
    INDENT();
  }
  opt_decl_in_main_program_list  // code of global identifiers & subprograms are generated
  {
    is_in_global_scope = false;
    // all statements are wrapped into the main function
    ST_CODE_GEN("\n");  // vertical space between fields and methods
    ST_CODE_GEN("%smethod public static void main(java.lang.String[])\n", indentions);
    ST_CODE_GEN("%smax_stack 15\n", indentions);
    ST_CODE_GEN("%smax_locals 15\n", indentions);
    ST_CODE_GEN("%s{\n", indentions);
    INDENT();
  }
  opt_stmt_list  // code of statements are generated
  {
    ST_CODE_GEN("%sreturn\n", indentions);
    DEDENT();
    ST_CODE_GEN("%s}\n", indentions);
    DEDENT();
    free(code_gen_class_name);
    st_exit_scope(&env);
    ST_CODE_GEN("%s}\n", indentions);
  }
;

opt_decl_in_main_program_list:
  decl_in_main_program_list
  { /* no code gen */ }
| /* empty */
  { /* no code gen */ }
;

opt_stmt_list:
  stmt_list
  { /* no code gen */ }
| /* empty */
  { /* no code gen */ }
;

stmt_list:
  stmt_list stmt
  { /* no code gen */ }
| stmt
  { /* no code gen */ }
;

decl_in_main_program_list:
  decl_in_main_program_list decl_in_main_program
  { /* no code gen */ }
| decl_in_main_program
  { /* no code gen */ }
;

  /*
   * NOTE: subprog_decl can only appear in the main program level.
   * Separate it from normal decl.
   */
decl_in_main_program:
  decl
  { /* no code gen */ }
| subprog_decl
  { /* no code gen */ }
;

decl:
  decl_
  {
    Symbol* symbol = st_add_to_scope(env, $1->name);
    symbol->attribute = $1;
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
    Identifier* id_ref = ((IdentifierReference*)$1)->id;
    if (st_is_global(id_ref)) {
      ST_CODE_GEN("%sputstatic int %s.%s\n", indentions, code_gen_class_name, id_ref->name);
    } else {
      ST_CODE_GEN("%sistore %d\n", indentions, id_ref->local_number);
    }
    st_free_reference($1);
    st_free_expression($4);
  }
| subprog_call
  { /* the id of $$ is from the symbol table, so no free here */ }
| RETURN
  {
    ST_CODE_GEN_SOURCE_COMMENT(@1);
    ST_CODE_GEN("%sreturn\n", indentions);
  }
| if_stmt
  { /* no code gen */ }
| exit_stmt
  { /* no code gen */ }
| {
    // mid-rule: new loop scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_LOOP_SCOPE_NAME);
    INDENT();
  }
  loop_stmt
  {
    DEDENT();
    st_exit_scope(&env);
  }
| {
    // mid-rule: new loop scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_LOOP_SCOPE_NAME);
    INDENT();
  }
  for_stmt
  {
    DEDENT();
    st_exit_scope(&env);
  }
| {
    // mid-rule: new block scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
    INDENT();
  }
  block
  {
    DEDENT();
    st_exit_scope(&env);
  }
| get_stmt
  { /* no code gen */ }
| put_stmt
  { /* no code gen */ }
| SKIP
  {
    ST_CODE_GEN_SOURCE_COMMENT(@1);
    ST_CODE_GEN("%sgetstatic java.io.PrintStream java.lang.System.out\n", indentions);
    ST_CODE_GEN("%sinvokevirtual void java.io.PrintStream.println()\n", indentions);
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
      ST_UNSUPPORTED_FEATURE(@5, "run-time init expr");
    }
    CompileTimeExpression* compile_time_expr = (CompileTimeExpression*)$5;
    ST_CODE_GEN("%s", indentions);
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
          ST_UNSUPPORTED_FEATURE(@5, "expr type");
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
    ST_UNSUPPORTED_FEATURE(@4, "array");
  }
| VAR ID ':' scalar_type
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  opt_init_expr
  {
    if (!$6 /* no init */ ) {
      $$ = ST_CREATE_VAR_IDENTIFIER($2->name, $4);
      if (is_in_global_scope) {
        switch ($4->data_type) {
          case ST_INT_TYPE:
            /* fallthrough */
          case ST_BOOL_TYPE:
            ST_CODE_GEN("%sfield static int %s\n", indentions, $2->name);
            break;
          default:
            ST_UNSUPPORTED_FEATURE(@4, "type");
        }
      } else {
        /* the location of the variable is kept by the symbol table */
      }
    } else /* has init expr */ {
      // use the declared type, not the type of the expression
      $$ = ST_CREATE_VAR_IDENTIFIER($2->name, $4);
      if (is_in_global_scope && $6->expr_type != ST_COMPILE_TIME_EXPRESSION) {
        ST_UNSUPPORTED_FEATURE(@6, "run-time init expr");
      }
      CompileTimeExpression* compile_time_expr = (CompileTimeExpression*)$6;
      ST_CODE_GEN("%s", indentions);
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
            ST_UNSUPPORTED_FEATURE(@4, "type");
        }
      } else {
        ST_CODE_GEN("istore %d\n", $$->local_number);
      }
      st_free_expression($6);
    }
    st_free_data_type_info($4);
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
    $$ = ST_CREATE_CONST_IDENTIFIER($2->name, $5, $5);
    if (is_in_global_scope || $5->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      /* kept by the symbol table, no code gen */
    } else {
      // the value of the expression is on the top of the stack, store to the identifier
      ST_CODE_GEN("%sistore %d\n", indentions, $$->local_number);
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
      ST_CODE_GEN("%sistore %d\n", indentions, $$->local_number);
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
    INDENT();
    is_in_global_scope = false;
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
    DEDENT();
    st_exit_scope(&env);
    is_in_global_scope = true;
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = $2;
  }
| {
    // mid-rule: enter a procedure scope
    st_enter_scope(&env);
    st_add_to_scope(env, ST_PROCEDURE_SCOPE_NAME);
    INDENT();
    is_in_global_scope = false;
  }
  procedure_decl
  {
    // the subprogram identifier is stored for type checks on recursive calls,
    // but we don't want it to be freed when the scope exit, so replace it with a NULL
    st_probe_environment(env, $2->name)->attribute = NULL;
    DEDENT();
    st_exit_scope(&env);
    is_in_global_scope = true;
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = $2;
  }
;

procedure_decl:
  procedure_header
  {
    ST_CODE_GEN("%smethod public static void %s(", indentions, $1->name);
    // Since the formals are stored in the reverse order, we'll have to reverse it again.
    List* stack = NULL;
    List* formals = $1->formals;
    while (formals) {
      StDataTypeInfo* formal = formals->val;
      stack = list_create(&formal->data_type, stack);
      formals = formals->rest;
    }
    List* formal_types = stack;
    while (formal_types) {
      StDataType* formal_type = formal_types->val;
      switch (*formal_type) {
        case ST_INT_TYPE:
          /* fallthrough since int and bool are both represented by int */
        case ST_BOOL_TYPE:
          ST_CODE_GEN("int");
          break;
        default:
          ST_UNSUPPORTED_FEATURE(@1, "formal type");
      }
      formal_types = formal_types->rest;
      if (formal_types) {
        ST_CODE_GEN(", ");
      }
    }
    list_delete(stack);
    ST_CODE_GEN(")\n");
    ST_CODE_GEN("%smax_stack 15\n", indentions);
    ST_CODE_GEN("%smax_locals 15\n", indentions);
    ST_CODE_GEN("%s{\n", indentions);
    INDENT();
  }
  opt_decl_or_stmt_list END
  {
    ST_CODE_GEN("%sreturn\n", indentions);
    ST_CODE_GEN_SOURCE_COMMENT(@4); }
  ID
  {
    DEDENT();
    ST_CODE_GEN("%s}\n", indentions);
    ST_CODE_GEN("\n");
    // Reset the location number since the stack frame of the procedure is popped.
    // NOTE: since the statements can only appear after the global declarations,
    // there isn't any local identifiers yet (excluding those inside
    // subprogram declarations, which use a difference stack frame), it is ok
    // that we reset the number to 0 instead of restore the number before the
    // subprogram declaration.
    local_number = 0;
    $$ = $1;
  }
;

  /*
   * Enforce a function to end with a result statement syntactically.
   */
function_decl:
  function_header
  {
    ST_CODE_GEN("%smethod public static ", indentions);
    switch ($1->result_type->data_type) {
      case ST_INT_TYPE:
        /* fallthrough */
      case ST_BOOL_TYPE:
        ST_CODE_GEN("int");
        break;
      default:
        ST_UNSUPPORTED_FEATURE(@1, "return type");
    }
    ST_CODE_GEN(" %s(", $1->name);
    // Since the formals are stored in the reverse order, we'll have to reverse it again.
    List* stack = NULL;
    List* formals = $1->formals;
    while (formals) {
      StDataTypeInfo* formal = formals->val;
      stack = list_create(&formal->data_type, stack);
      formals = formals->rest;
    }
    List* formal_types = stack;
    while (formal_types) {
      StDataType* formal_type = formal_types->val;
      switch (*formal_type) {
        case ST_INT_TYPE:
          /* fallthrough since int and bool are both represented by int */
        case ST_BOOL_TYPE:
          ST_CODE_GEN("int");
          break;
        default:
          ST_UNSUPPORTED_FEATURE(@1, "formal type");
      }
      formal_types = formal_types->rest;
      if (formal_types) {
        ST_CODE_GEN(", ");
      }
    }
    list_delete(stack);
    ST_CODE_GEN(")\n");
    ST_CODE_GEN("%smax_stack 15\n", indentions);
    ST_CODE_GEN("%smax_locals 15\n", indentions);
    ST_CODE_GEN("%s{\n", indentions);
    INDENT();
  }
  opt_decl_or_stmt_list_end_with_result_list END
  { ST_CODE_GEN_SOURCE_COMMENT(@4); }
  ID
  {
    DEDENT();
    ST_CODE_GEN("%s}\n", indentions);
    ST_CODE_GEN("\n");
    // Reset the location number since the stack frame of the function is popped.
    // NOTE: there isn't any local identifiers yet (excluding those inside
    // subprogram declarations, which use a difference stack frame), it is ok
    // that we reset the number to 0 instead of restore the number before the
    // subprogram declaration.
    local_number = 0;
    $$ = $1;
  }
;

  /*
   * A list which must end with a result_stmt.
   */
opt_decl_or_stmt_list_end_with_result_list:
  decl_or_stmt_list_end_with_result_list
  { /* no code gen */ }
| /* empty */
  { /* no code gen */ }
;

decl_or_stmt_list_end_with_result_list:
  decl_or_stmt_or_result decl_or_stmt_list_end_with_result_list
  { /* no code gen */ }
| result_stmt
  { /* no code gen */ }
;

decl_or_stmt_or_result:
  decl
  { /* no code gen */ }
| stmt
  { /* no code gen */ }
| result_stmt
  { /* no code gen */ }
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
    ST_CODE_GEN("\n");  // vertical space between fields and methods
    ST_CODE_GEN_SOURCE_COMMENT(@1);
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
    ST_CODE_GEN("\n");  // vertical space between fields and methods
    ST_CODE_GEN_SOURCE_COMMENT(@1);
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
  { /* no code gen */ }
| /* empty */
  { /* no code gen */ }
;

decl_or_stmt_list:
  decl_or_stmt_list decl_or_stmt
  { /* no code gen */ }
| decl_or_stmt
  { /* no code gen */ }
;

decl_or_stmt:
  decl
  { /* no code gen */ }
| stmt
  { /* no code gen */ }
  /*
   * NOTE: to make decl_or_stmt_list distinguishable from decl_or_stmt_list_end_with_result_list,
   * the result_stmt is handled separately instead of being put inside stmt
   */
| result_stmt
  { /* no code gen */ }
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
      // subprograms should start a new local scope
      ST_UNREACHABLE();
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
      ST_UNREACHABLE();
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
  { $$ = $1; }
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
    CompileTimeExpression* lower_bound = (CompileTimeExpression*)$2;
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_ARRAY_TYPE;
    $$->array_type_info = malloc(sizeof(StStaticArrayTypeInfo));
    $$->array_type_info->array_type = ST_STATIC_ARRAY;
    ST_COPY_TYPE($$->array_type_info, $7);
    $$->array_type_info->lower_bound = lower_bound->int_val;
    ((StStaticArrayTypeInfo*)$$->array_type_info)->upper_bound
        = ST_STAR_ARRAY_UPPER_BOUND;
    st_free_expression($2);
    st_free_data_type_info($7);
  }
;

  /*
   * Returns a Subprogram.
   */
subprog_call:
  ID '(' opt_expr_comma_list ')'
  {
    Symbol* symbol = st_lookup_environment(env, $1->name);
    Identifier* id = (Identifier*)symbol->attribute;
    Subprogram* subprogram = (Subprogram*)id;
    $$ = subprogram;
    // actuals are already pushed onto the operand stack
    ST_CODE_GEN("%sinvokestatic ", indentions);
    // 1. the return type
    switch (subprogram->subprogram_type) {
      case ST_PROCEDURE_SUBPROGRAM:
        ST_CODE_GEN("void");
        break;
      case ST_FUNCTION_SUBPROGRAM:
        switch (((FunctionSubprogram*)subprogram)->result_type->data_type) {
          case ST_INT_TYPE:
            /* fallthrough */
          case ST_BOOL_TYPE:
            ST_CODE_GEN("int");
            break;
          default:
            ST_UNSUPPORTED_FEATURE(@1, "return type");
        }
        break;
      default:
        ST_UNREACHABLE();
    }
    ST_CODE_GEN(" %s.%s(", input_filename_stem, subprogram->name);
    // 2. the formal types
    // Since the formals are stored in the reverse order, we'll have to reverse it again.
    List* stack = NULL;
    List* formals = subprogram->formals;
    while (formals) {
      StDataTypeInfo* formal = formals->val;
      stack = list_create(&formal->data_type, stack);
      formals = formals->rest;
    }
    List* formal_types = stack;
    while (formal_types) {
      StDataType* formal_type = formal_types->val;
      switch (*formal_type) {
        case ST_INT_TYPE:
          /* fallthrough */
        case ST_BOOL_TYPE:
          ST_CODE_GEN("int");
          break;
        default:
          ST_UNSUPPORTED_FEATURE(@1, "formal type");
      }
      formal_types = formal_types->rest;
      if (formal_types) {
        ST_CODE_GEN(", ");
      }
    }
    list_delete(stack);
    ST_CODE_GEN(")\n");

    // free the actuals
    List* actual = $3;
    while (actual) {
      st_free_expression(actual->val);
      actual = actual->rest;
    }
    list_delete($3);
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

expr_comma_list:
  expr_comma_list ',' expr
  { $$ = list_create($3, $1); }
| expr
  { $$ = list_create($1, NULL); }
;

  /*
   * NOTE: `IF` is left factored for the line number of the source comment to be correct.
   */
if_stmt:
  IF
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  if_body
  { /* no code gen */}
;

if_body:
  expr then_block END IF
  {
    st_free_expression($1);
    ST_CODE_GEN_SOURCE_COMMENT(@4);
    ST_CODE_GEN("%sLfalse%d:\n", indentions, $2);
  }
| expr then_block
  {
    int end_branch = label_number++;
    ST_CODE_GEN("%sgoto Lend%d\n", indentions, end_branch);
    $<label_number>$ = end_branch;
  }
  ELSE
  {
    // mid-rule
    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
    INDENT();
    ST_CODE_GEN_SOURCE_COMMENT(@4);
    ST_CODE_GEN("%sLfalse%d:\n", indentions, $2);
  }
  opt_decl_or_stmt_list END IF
  {
    DEDENT();
    st_exit_scope(&env);
    st_free_expression($1);
    ST_CODE_GEN_SOURCE_COMMENT(@7);
    ST_CODE_GEN("%sLend%d:\n", indentions, $<label_number>3);
  }
;

  /*
   * Returns the label number of the false branch.
   */
then_block:
  THEN
  {
    // mid-rule
    int false_branch = label_number++;
    ST_CODE_GEN("%sifeq Lfalse%d\n", indentions, false_branch);
    $<label_number>$ = false_branch;

    st_enter_scope(&env);
    st_add_to_scope(env, ST_BLOCK_SCOPE_NAME);
    INDENT();
  }
  opt_decl_or_stmt_list
  {
    $$ = $<label_number>2;
    DEDENT();
    st_exit_scope(&env);
  }
;

result_stmt:
  RESULT
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  expr
  {
    ST_CODE_GEN("%sireturn\n", indentions);
    st_free_expression($3);
  }
;

exit_stmt:
  EXIT
  {
    ST_CODE_GEN_SOURCE_COMMENT(@1);
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    ST_CODE_GEN("%sgoto Lend%d\n", indentions, loop_info->end_branch);
  }
| EXIT
  { ST_CODE_GEN_SOURCE_COMMENT(@1); }
  WHEN expr
  {
    st_free_expression($4);
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    ST_CODE_GEN("%sifne Lend%d\n", indentions, loop_info->end_branch);
  }
;

loop_stmt:
  LOOP
  {
    ST_CODE_GEN_SOURCE_COMMENT(@1);
    Symbol* symbol = st_probe_environment(env, ST_LOOP_SCOPE_NAME);
    LoopInfo* loop_info = malloc(sizeof(LoopInfo));
    symbol->attribute = loop_info;
    loop_info->begin_branch = label_number++;
    ST_CODE_GEN("%sLbegin%d:\n", indentions, loop_info->begin_branch);
    // Also we create an end_branch so that the exit statement knows where to
    // jump out of the loop.
    // Note that the label might not be used, but that's ok.
    loop_info->end_branch = label_number++;
  }
  opt_decl_or_stmt_list
  {
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    ST_CODE_GEN("%sgoto Lbegin%d\n", indentions, loop_info->begin_branch);
  }
  END LOOP
  {
    ST_CODE_GEN_SOURCE_COMMENT(@5);
    Symbol* symbol = st_probe_environment(env, ST_LOOP_SCOPE_NAME);
    LoopInfo* loop_info = symbol->attribute;
    ST_CODE_GEN("%sLend%d:\n", indentions, loop_info->end_branch);
    free(loop_info);
    symbol->attribute = NULL;
  }
;

  /*
   * A for loop with code
   *
   *  for i : 0 .. 2
   *    % do something
   *  end for
   *
   * is effectively as the following
   *
   *  const i := 0
   *  loop
   *    exit when 2 < i
   *    % do something
   *    i := i + 1
   *  end loop
   *
   * Notice that while i is a constant to the user,
   * it's increased in each loop.
   */
for_stmt:
  FOR
  {
    ST_CODE_GEN_SOURCE_COMMENT(@1);
    // Just as the loop statement.
    Symbol* symbol = st_probe_environment(env, ST_LOOP_SCOPE_NAME);
    LoopInfo* loop_info = malloc(sizeof(LoopInfo));
    loop_info->end_branch = label_number++;
    symbol->attribute = loop_info;
    // We'll fill in the begin branch & name in the successive non-terminals.
  }
  for_header opt_decl_or_stmt_list
  {
    // Generate code for `counter := counter +/- 1`.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    ST_CODE_GEN("%s", indentions);
    switch (loop_info->for_loop_kind) {
      case INCREASING_LOOP:
        ST_CODE_GEN_COMMENT("%s := %s + 1", loop_info->name_of_counter, loop_info->name_of_counter);
        break;
      case DECREASING_LOOP:
        ST_CODE_GEN_COMMENT("%s := %s - 1", loop_info->name_of_counter, loop_info->name_of_counter);
        break;
      default:
        ST_UNREACHABLE();
    }
    VarIdentifier* counter
        = st_probe_environment(env, loop_info->name_of_counter)->attribute;
    ST_CODE_GEN("%siload %d\n", indentions, counter->local_number);
    ST_CODE_GEN("%ssipush 1\n", indentions);
    ST_CODE_GEN("%s", indentions);
    switch (loop_info->for_loop_kind) {
      case INCREASING_LOOP:
        ST_CODE_GEN("iadd\n");
        break;
      case DECREASING_LOOP:
        ST_CODE_GEN("isub\n");
        break;
      default:
        ST_UNREACHABLE();
    }
    ST_CODE_GEN("%sistore %d\n", indentions, counter->local_number);
    // Back to the beginning of the loop.
    ST_CODE_GEN("%sgoto Lbegin%d\n", indentions, loop_info->begin_branch);
  }
  END FOR
  {
    ST_CODE_GEN_SOURCE_COMMENT(@4);
    Symbol* symbol = st_probe_environment(env, ST_LOOP_SCOPE_NAME);
    LoopInfo* loop_info = symbol->attribute;
    ST_CODE_GEN("%sLend%d:\n", indentions, loop_info->end_branch);
    free(loop_info);
    symbol->attribute = NULL;
  }
;

for_header:
  ':'
  {
    // Create a counting identifier.
    ST_CODE_GEN("%s", indentions);
    ST_CODE_GEN_COMMENT("__i: int");
    StDataTypeInfo type_info = { .data_type = ST_INT_TYPE };
    VarIdentifier* counter = ST_CREATE_VAR_IDENTIFIER("__i", &type_info);
    st_add_to_scope(env, counter->name)->attribute = counter;
    // Record the name nad kind of the counter, so that we can increase it later.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    loop_info->name_of_counter = counter->name;
    loop_info->for_loop_kind = INCREASING_LOOP;
  }
  for_range
  {
    // NOTE: if we initialize here, the begin and end value of the range are
    // already push onto the operand stack, but then we can no longer retrieve
    // the begin value since it's now not on the top. So we'll move the work
    // on the begin value to the for_range.
    // On the other hand, the end value can be handled here. We'll generate
    // the proper exit condition.

    // Generate code for `exit when end < counter`.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    // 1. end < counter
    // `end` is already on the top of the stack
    VarIdentifier* counter
        = st_probe_environment(env, loop_info->name_of_counter)->attribute;
    ST_CODE_GEN("%siload %d\n", indentions, counter->local_number);
    const int true_branch = label_number++;
    const int false_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("iflt", true_branch, false_branch);
    // 2. exit when expr
    ST_CODE_GEN("%sifne Lend%d\n", indentions, loop_info->end_branch);
  }
| DECREASING
  {
    // Create a counting identifier.
    ST_CODE_GEN("%s", indentions);
    ST_CODE_GEN_COMMENT("__i: int");
    StDataTypeInfo type_info = { .data_type = ST_INT_TYPE };
    VarIdentifier* counter = ST_CREATE_VAR_IDENTIFIER("__i", &type_info);
    st_add_to_scope(env, counter->name)->attribute = counter;
    // Record the name and kind of the counter, so that we can decrease it later.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    loop_info->name_of_counter = counter->name;
    loop_info->for_loop_kind = DECREASING_LOOP;
  }
  ':' for_range
  {
    // Generate code for `exit when end > counter`.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    // 1. end > counter
    // `end` is already on the top of the stack
    VarIdentifier* counter
        = st_probe_environment(env, loop_info->name_of_counter)->attribute;
    ST_CODE_GEN("%siload %d\n", indentions, counter->local_number);
    const int true_branch = label_number++;
    const int false_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("ifgt", true_branch, false_branch);
    // 2. exit when expr
    ST_CODE_GEN("%sifne Lend%d\n", indentions, loop_info->end_branch);
  }
| ID
  {
    // Add id into the scope and marked as constant
    RunTimeExpression expr = { .expr_type = ST_RUN_TIME_EXPRESSION, .data_type = ST_INT_TYPE };
    RunTimeExpression* expr_p = &expr;  // resolve -Wstrict-aliasing
    ConstIdentifier* id = ST_CREATE_CONST_IDENTIFIER($1->name, expr_p, expr_p);
    Symbol* symbol = st_add_to_scope(env, $1->name);
    symbol->attribute = id;
    // Record the name and kind of the counter, so that we can increase it later.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    loop_info->name_of_counter = id->name;
    loop_info->for_loop_kind = INCREASING_LOOP;
  }
  ':' for_range
  {
    // Generate code for `exit when end < counter`.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    // 1. end < counter
    // `end` is already on the top of the stack
    VarIdentifier* counter
        = st_probe_environment(env, loop_info->name_of_counter)->attribute;
    ST_CODE_GEN("%siload %d\n", indentions, counter->local_number);
    const int true_branch = label_number++;
    const int false_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("iflt", true_branch, false_branch);
    // 2. exit when expr
    ST_CODE_GEN("%sifne Lend%d\n", indentions, loop_info->end_branch);
  }
| DECREASING ID
  {
    // Add id into the scope and marked as constant
    RunTimeExpression expr = { .expr_type = ST_RUN_TIME_EXPRESSION, .data_type = ST_INT_TYPE };
    RunTimeExpression* expr_p = &expr;  // resolve -Wstrict-aliasing
    ConstIdentifier* id = ST_CREATE_CONST_IDENTIFIER($2->name, expr_p, expr_p);
    Symbol* symbol = st_add_to_scope(env, $2->name);
    symbol->attribute = id;
    // Record the name and kind of the counter, so that we can decrease it later.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    loop_info->name_of_counter = id->name;
    loop_info->for_loop_kind = DECREASING_LOOP;
  }
  ':' for_range
  {
    // Generate code for `exit when end > counter`.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    // 1. end > counter
    // `end` is already on the top of the stack
    VarIdentifier* counter
        = st_probe_environment(env, loop_info->name_of_counter)->attribute;
    ST_CODE_GEN("%siload %d\n", indentions, counter->local_number);
    const int true_branch = label_number++;
    const int false_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("ifgt", true_branch, false_branch);
    // 2. exit when expr
    ST_CODE_GEN("%sifne Lend%d\n", indentions, loop_info->end_branch);
  }
;

for_range:
  {
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    ST_CODE_GEN("%s", indentions);
    ST_CODE_GEN_COMMENT("%s := begin", loop_info->name_of_counter);
  }
  expr
  {
    st_free_expression($2);
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    VarIdentifier* counter
        = st_probe_environment(env, loop_info->name_of_counter)->attribute;
    ST_CODE_GEN("%sistore %d\n", indentions, counter->local_number);
  }
  '.' '.'
  {
    // At this point, the counter is already initialized to the begin value,
    // so we can generate the label for begin.
    LoopInfo* loop_info = st_probe_environment(env, ST_LOOP_SCOPE_NAME)->attribute;
    loop_info->begin_branch = label_number++;
    ST_CODE_GEN("%sLbegin%d:\n", indentions, loop_info->begin_branch);
    ST_CODE_GEN("%s", indentions);
    switch (loop_info->for_loop_kind) {
      case INCREASING_LOOP:
        ST_CODE_GEN_COMMENT("exit when end < %s", loop_info->name_of_counter);
        break;
      case DECREASING_LOOP:
        ST_CODE_GEN_COMMENT("exit when end > %s", loop_info->name_of_counter);
        break;
      default:
        ST_UNREACHABLE();
    }
  }
  expr
  { st_free_expression($7); }
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
      st_free_reference(refs->val);
      refs = refs->rest;
    }
    list_delete($2);
    ST_UNSUPPORTED_FEATURE(@1, "get statement");
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
  put_expr_comma_list
  {
    List* exprs = $3;
    while (exprs) {
      st_free_expression(exprs->val);
      exprs = exprs->rest;
    }
    list_delete($3);
  }
  opt_dot_dot
  { /* no code gen */ }
;

opt_dot_dot:
  '.' '.'
  {
    ST_CODE_GEN("%s", indentions);
    ST_CODE_GEN_COMMENT(".., no newline");
  }
| /* empty */
  {
    ST_CODE_GEN("%s", indentions);
    ST_CODE_GEN_COMMENT("newline");
    ST_CODE_GEN("%sgetstatic java.io.PrintStream java.lang.System.out\n", indentions);
    ST_CODE_GEN("%sinvokevirtual void java.io.PrintStream.println()\n", indentions);
  }
;

 /*
  * Returns a List of Expression.
  * NOTE: same syntax as expr_comma_list, but separated for code gen purpose
  */
put_expr_comma_list:
  put_expr_comma_list ','
  { ST_CODE_GEN("%sgetstatic java.io.PrintStream java.lang.System.out\n", indentions); }
  expr
  {
    $$ = list_create($4, $1);
    ST_CODE_GEN("%sinvokevirtual void java.io.PrintStream.print(", indentions);
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
        ST_UNSUPPORTED_FEATURE(@4, "expr type");
    }
    ST_CODE_GEN(")\n");
  }
| { ST_CODE_GEN("%sgetstatic java.io.PrintStream java.lang.System.out\n", indentions); }
  expr
  {
    $$ = list_create($2, NULL);
    ST_CODE_GEN("%sinvokevirtual void java.io.PrintStream.print(", indentions);
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
        ST_UNSUPPORTED_FEATURE(@2, "expr type");
    }
    ST_CODE_GEN(")\n");
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
    CompileTimeExpression* compile_time_expr = (CompileTimeExpression*)$3;
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
    CompileTimeExpression* lower_bound = (CompileTimeExpression*)$2;
    $$ = malloc(sizeof(StDataTypeInfo));
    $$->data_type = ST_ARRAY_TYPE;
    if ($5->expr_type == ST_COMPILE_TIME_EXPRESSION) {
      CompileTimeExpression* upper_bound = (CompileTimeExpression*)$5;
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
    st_free_expression($2);
    st_free_expression($5);
    st_free_data_type_info($7);
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
    Identifier* id = symbol->attribute;
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
    Symbol* symbol = st_lookup_environment(env, $1->name);
    Identifier* id = symbol->attribute;
    const int num_of_sub = list_length($2);
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
    List* curr = $2;
    while (curr) {
      st_free_expression(curr->val);
      curr = curr->rest;
    }
    list_delete($2);
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
  { $$ = list_create($2, NULL); }
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
              ST_CODE_GEN("%s", indentions);
              switch (id->data_type) {
                case ST_INT_TYPE:
                  ST_CODE_GEN("sipush %d\n", compile_time_const_id->int_val);
                  break;
                case ST_BOOL_TYPE:
                  ST_CODE_GEN("iconst_%d\n", compile_time_const_id->bool_val);
                  break;
                case ST_STRING_TYPE:
                  ST_CODE_GEN("ldc \"%s\"\n", compile_time_const_id->string_val);
                  break;
                default:
                  ST_UNSUPPORTED_FEATURE(@1, "identifier type");
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
                  // run-time constant has its init expr a run-time expression,
                  // while we only support compile-time expressions
                  ST_UNSUPPORTED_FEATURE(@1, "run-time init expr");
                } else {
                  ST_CODE_GEN("%siload %d\n", indentions, id->local_number);
                }
                break;
              case ST_STRING_TYPE:
                // variable strings are not allowed
              default:
                ST_UNSUPPORTED_FEATURE(@1, "identifier type");
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
              ST_CODE_GEN("%s", indentions);
              if (st_is_global(id)) {
                ST_CODE_GEN("getstatic int %s.%s\n", code_gen_class_name, id->name);
              } else {
                ST_CODE_GEN("iload %d\n", id->local_number);
              }
              break;
            case ST_STRING_TYPE:
              // variable strings are not allowed
            default:
              ST_UNSUPPORTED_FEATURE(@1, "identifier type");
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
      ST_UNSUPPORTED_FEATURE(@1, "array");
    } else {
      ST_UNREACHABLE();
    }
  }
| explicit_const
  { $$ = (Expression*)$1; }
| subprog_call
  {
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
      ST_CODE_GEN("%ssipush %d\n", indentions, $1);
    }
  }
| REAL_CONST
  {
    $$ = malloc(sizeof(CompileTimeExpression));
    $$->expr_type = ST_COMPILE_TIME_EXPRESSION;
    $$->data_type = ST_REAL_TYPE;
    $$->real_val = $1;
    ST_UNSUPPORTED_FEATURE(@1, "real");
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
      ST_CODE_GEN("%sldc \"%s\"\n", indentions, $1);
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
      ST_CODE_GEN("%siconst_1\n", indentions);
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
      ST_CODE_GEN("%siconst_0\n", indentions);
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
      ST_UNSUPPORTED_FEATURE(@1, "run-time string");
    } else { // is arithmetic
      $$ = ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, +, $3);
      if ($1->data_type == ST_REAL_TYPE || $3->data_type == ST_REAL_TYPE) {
        ST_UNSUPPORTED_FEATURE(@1, "real");
      }
      // the two operands are already push onto the operand stack
      ST_CODE_GEN("%siadd\n", indentions);
    }
    st_free_expression($1);
    st_free_expression($3);
  }
| expr '-' expr
  {
    $$ = ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, -, $3);
    if ($1->data_type == ST_REAL_TYPE || $3->data_type == ST_REAL_TYPE) {
      ST_UNSUPPORTED_FEATURE(@1, "real");
    }
    ST_CODE_GEN("%sisub\n", indentions);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr '*' expr
  {
    $$ = ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, *, $3);
    if ($1->data_type == ST_REAL_TYPE || $3->data_type == ST_REAL_TYPE) {
      ST_UNSUPPORTED_FEATURE(@1, "real");
    }
    ST_CODE_GEN("%simul\n", indentions);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr '/' expr
  {
    $$ = ST_CREATE_BINARY_ARITHMETIC_EXPRESSION($1, /, $3);
    if ($1->data_type == ST_REAL_TYPE || $3->data_type == ST_REAL_TYPE) {
      ST_UNSUPPORTED_FEATURE(@1, "real");
    }
    ST_CODE_GEN("%sidiv\n", indentions);
    st_free_expression($1);
    st_free_expression($3);
  }
| expr MOD expr
  {
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
    ST_CODE_GEN("%sirem\n", indentions);
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
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, <, $3);
    st_free_expression($1);
    st_free_expression($3);

    const int true_branch = label_number++;
    const int end_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("iflt", true_branch, end_branch);
  }
| expr '>' expr
  {
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, >, $3);
    st_free_expression($1);
    st_free_expression($3);

    const int true_branch = label_number++;
    const int end_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("ifgt", true_branch, end_branch);
  }
| expr '=' expr
  {
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, ==, $3);
    st_free_expression($1);
    st_free_expression($3);

    const int true_branch = label_number++;
    const int end_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("ifeq", true_branch, end_branch);
  }
| expr LE expr
  {
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, <=, $3);
    st_free_expression($1);
    st_free_expression($3);

    const int true_branch = label_number++;
    const int end_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("ifle", true_branch, end_branch);
  }
| expr GE expr
  {
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, >=, $3);
    st_free_expression($1);
    st_free_expression($3);

    const int true_branch = label_number++;
    const int end_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("ifge", true_branch, end_branch);
  }
| expr NE expr
  {
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, !=, $3);
    st_free_expression($1);
    st_free_expression($3);

    const int true_branch = label_number++;
    const int end_branch = label_number++;
    ST_CODE_GEN_COMPARISON_EXPRESSION("ifne", true_branch, end_branch);
  }
;

boolean_operation:
  expr AND expr
  {
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, &&, $3);
    st_free_expression($1);
    st_free_expression($3);
    ST_CODE_GEN("%siand\n", indentions);
  }
| expr OR expr
  {
    $$ = ST_CREATE_BINARY_BOOLEAN_EXPRESSION($1, ||, $3);
    st_free_expression($1);
    st_free_expression($3);
    ST_CODE_GEN("%sior\n", indentions);
  }
| NOT expr
  {
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
    st_free_expression($2);
    ST_CODE_GEN("%ssipush 1\n", indentions);
    ST_CODE_GEN("%sixor\n", indentions);
  }
;

  /*
   * All of the sign operations are the same.
   * (1) the expression must have type int or real
   */
sign_operation:
  '+' expr
  {
    $$ = ST_CREATE_UNARY_SIGN_EXPRESSION(+, $2);
    // no code gen since has no effect
    st_free_expression($2);
  }
| '-' expr
  {
    $$ = ST_CREATE_UNARY_SIGN_EXPRESSION(-, $2);
    ST_CODE_GEN("%sineg\n", indentions);
    st_free_expression($2);
  }
;

%%
extern char* input_filename;

void yyerror(const char *msg) {
  fprintf(stderr, "%s:%d:%d: %s\n",
      input_filename, yylloc.first_line, yylloc.first_column, msg);
}
