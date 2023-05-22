#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semant.h"

/// @brief The file being semantically checked.
extern char* input_filename;
extern int allow_semantic_errors;
extern int semantic_errors;

#ifndef ST_TRACE
#define ST_TRACE(...) fprintf(stderr, __VA_ARGS__)
#endif

#ifndef ST_FATAL_ERROR
/// @brief Prints the format message to stderr and exits as failure.
/// @note If allow_semantic_errors is a non-zero value, exits as success.
#define ST_FATAL_ERROR(yylloc, ...) \
  { \
    ST_NON_FATAL_ERROR(yyloc, __VA_ARGS__); \
    exit(allow_semantic_errors ? EXIT_SUCCESS : EXIT_FAILURE); \
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

#ifndef ST_UNREACHABLE
#define ST_UNREACHABLE() assert(false)
#endif

#ifndef ST_COPY_SCALAR_VALUE
/// @brief Copies the correspond scalar value of b to a.
/// @note (1) a and b should be pointers (2) their data_type should be scalar
/// type (3) they should both have a union of scalar values.
#define ST_COPY_SCALAR_VALUE(a, b) \
  { \
    switch ((b)->data_type) { \
      case ST_INT_TYPE: \
        (a)->int_val = (b)->int_val; \
        break; \
      case ST_REAL_TYPE: \
        (a)->real_val = (b)->real_val; \
        break; \
      case ST_BOOL_TYPE: \
        (a)->bool_val = (b)->bool_val; \
        break; \
      case ST_STRING_TYPE: \
        (a)->string_val = st_strdup((b)->string_val); \
        break; \
      default: \
        ST_UNREACHABLE(); \
    } \
  }
#endif

#ifndef ST_COPY_TYPE
/// @brief Copies the data type and the correspond type info of b to a.
/// @note (1) a and b should be pointers (2) they should both have a union of
/// string_type_info and array_type_info.
#define ST_COPY_TYPE(a, b) \
  { \
    (a)->data_type = (b)->data_type; \
    switch ((b)->data_type) { \
      case ST_STRING_TYPE: \
        (a)->string_type_info = (b)->string_type_info; \
        break; \
      case ST_ARRAY_TYPE: \
        (a)->array_type_info = (b)->array_type_info; \
        break; \
      default: \
        /* has no additional information to copy */ \
        break; \
    } \
  }
#endif

#ifndef ST_HAS_ONE_OF_DATA_TYPES
/// @return Whether x has one of the listed data types.
#define ST_HAS_ONE_OF_DATA_TYPES(x, ...) \
  is_one_of_data_types( \
      (x)->data_type, \
      sizeof((StDataType[]){__VA_ARGS__}) / sizeof(StDataType), __VA_ARGS__)
#endif

#ifndef ST_MAKE_DATA_TYPE_INFO
/// @brief Copies the data type info of x
/// @param x must necessarily carry all data in ST_DATA_TYPE_INFO
/// @note This macro uses "statement expression", which is a non-standard
/// feature. GCC and Clang are known to support this. See also
/// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html.
#define ST_MAKE_DATA_TYPE_INFO(x) \
  ({ \
    StDataTypeInfo data_type; \
    ST_COPY_TYPE(&data_type, x); \
    data_type; \
  })
#endif

#ifndef ST_MAKE_VAR_IDENTIFIER
/// @param id_name a char string
/// @param type a structure that carries all data in ST_DATA_TYPE_INFO
/// @note This macro uses "statement expression", which is a non-standard
/// feature. GCC and Clang are known to support this. See also
/// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html.
#define ST_MAKE_VAR_IDENTIFIER(id_name, type) \
  ({ \
    VarIdentifier* var_id = malloc(sizeof(VarIdentifier)); \
    var_id->id_type = ST_VAR_IDENTIFIER; \
    var_id->name = st_strdup((id_name)); \
    ST_COPY_TYPE(var_id, (type)); \
    var_id; \
  })
#endif

#ifndef ST_MAKE_CONST_IDENTIFIER
/// @param id_name a char string
/// @param type a structure that carries all data in ST_DATA_TYPE_INFO
/// @param expr an Expression
/// @note type may be the same pointer with expr if no implicit type conversion
/// is desired.
/// @note This macro uses "statement expression", which is a non-standard
/// feature. GCC and Clang are known to support this. See also
/// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html.
/// @details If expr is a compile-time expression, the result id can represent a
/// compile-time expression, and so the value are recorded.
#define ST_MAKE_CONST_IDENTIFIER(id_name, type, expr) \
  ({ \
    ConstIdentifier* result = NULL; \
    if ((expr)->expr_type == ST_COMPILE_TIME_EXPRESSION) { \
      result = (ConstIdentifier*)malloc(sizeof(CompileTimeConstIdentifier)); \
      result->const_id_type = ST_COMPILE_TIME_CONST_IDENTIFIER; \
      ST_COPY_TYPE(result, (type)); \
      ST_COPY_SCALAR_VALUE((CompileTimeConstIdentifier*)result, \
                           (CompileTimeExpression*)(expr)); \
    } else if ((expr)->expr_type == ST_RUN_TIME_EXPRESSION) { \
      result = (ConstIdentifier*)malloc(sizeof(RunTimeConstIdentifier)); \
      result->const_id_type = ST_RUN_TIME_CONST_IDENTIFIER; \
      ST_COPY_TYPE(result, (expr)); \
    } else { \
      ST_UNREACHABLE(); \
    } \
    result->id_type = ST_CONST_IDENTIFIER; \
    result->name = st_strdup((id_name)); \
    result; \
  })
#endif

#ifndef ST_MAKE_BINARY_BOOLEAN_EXPRESSION
/// @note If both expressions are compile-time expressions, the operation is
/// also a compile-time operation.
/// @note This macro uses "statement expression", which is a non-standard
/// feature. GCC and Clang are known to support this. See also
/// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html.
#define ST_MAKE_BINARY_BOOLEAN_EXPRESSION(a, bin_op, b) \
  ({ \
    Expression* result = NULL; \
    if ((a)->expr_type == ST_COMPILE_TIME_EXPRESSION \
        && (b)->expr_type == ST_COMPILE_TIME_EXPRESSION) { \
      result = (Expression*)malloc(sizeof(CompileTimeExpression)); \
      result->expr_type = ST_COMPILE_TIME_EXPRESSION; \
      result->data_type = ST_BOOL_TYPE; \
      ((CompileTimeExpression*)result)->bool_val \
          = ((CompileTimeExpression*)(a)) \
                ->bool_val bin_op((CompileTimeExpression*)(b)) \
                ->bool_val; \
    } else { \
      result = (Expression*)malloc(sizeof(RunTimeExpression)); \
      result->expr_type = ST_RUN_TIME_EXPRESSION; \
      result->data_type = ST_BOOL_TYPE; \
    } \
    result; \
  })
#endif

#ifndef ST_MAKE_BINARY_COMPARISON_EXPRESSION
/// @note If both expressions are compile-time expressions, the operation is
/// also a compile-time operation.
/// @note This macro uses "statement expression", which is a non-standard
/// feature. GCC and Clang are known to support this. See also
/// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html.
#define ST_MAKE_BINARY_COMPARISON_EXPRESSION(a, bin_op, b) \
  ({ \
    Expression* result = NULL; \
    if ((a)->expr_type == ST_COMPILE_TIME_EXPRESSION \
        && (b)->expr_type == ST_COMPILE_TIME_EXPRESSION) { \
      result = (Expression*)malloc(sizeof(CompileTimeExpression)); \
      CompileTimeExpression* lhs = (CompileTimeExpression*)(a); \
      CompileTimeExpression* rhs = (CompileTimeExpression*)(b); \
      result->data_type = ST_BOOL_TYPE; \
      switch ((a)->data_type) { \
        case ST_INT_TYPE: \
          ((CompileTimeExpression*)result)->bool_val \
              = lhs->int_val bin_op rhs->int_val; \
          break; \
        case ST_REAL_TYPE: \
          ((CompileTimeExpression*)result)->bool_val \
              = lhs->real_val bin_op rhs->real_val; \
          break; \
        case ST_STRING_TYPE: \
          ((CompileTimeExpression*)result)->bool_val \
              = strcmp(lhs->string_val, rhs->string_val) bin_op 0; \
          break; \
        default: \
          ST_UNREACHABLE(); \
      } \
    } \
    result; \
  })
#endif

#ifndef ST_MAKE_UNARY_SIGN_EXPRESSION
/// @note If the expression is a compile-time expressions, the operation is also
/// a compile-time operation.
/// @note This macro uses "statement expression", which is a non-standard
/// feature. GCC and Clang are known to support this. See also
/// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html.
#define ST_MAKE_UNARY_SIGN_EXPRESSION(un_op, a) \
  ({ \
    Expression* result = NULL; \
    if ((a)->expr_type == ST_COMPILE_TIME_EXPRESSION) { \
      result = (Expression*)malloc(sizeof(CompileTimeExpression)); \
      result->expr_type = ST_COMPILE_TIME_EXPRESSION; \
      ST_COPY_TYPE(result, (a)); \
      if ((a)->data_type == ST_INT_TYPE) { \
        ((CompileTimeExpression*)result)->int_val \
            = un_op abs(((CompileTimeExpression*)(a))->int_val); \
      } else if ((a)->data_type == ST_REAL_TYPE) { \
        ((CompileTimeExpression*)result)->real_val \
            = un_op fabs(((CompileTimeExpression*)(a))->real_val); \
      } else { \
        ST_UNREACHABLE(); \
      } \
    } else if ((a)->expr_type == ST_RUN_TIME_EXPRESSION) { \
      result = (Expression*)malloc(sizeof(RunTimeExpression)); \
      result->expr_type = ST_RUN_TIME_EXPRESSION; \
      ST_COPY_TYPE(result, (a)); \
    } else { \
      ST_UNREACHABLE(); \
    } \
    result; \
  })
#endif

#ifndef ST_MAKE_BINARY_ARITHMETIC_EXPRESSION
/// @note If both of the expression have type int, the result type is int,
/// otherwise the result type is real. If both expressions are compile-time
/// expressions, the operation is also a compile-time operation.
/// @note This macro uses "statement expression", which is a non-standard
/// feature. GCC and Clang are known to support this. See also
/// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html.
#define ST_MAKE_BINARY_ARITHMETIC_EXPRESSION(a, bin_op, b) \
  ({ \
    Expression* result = NULL; \
    if ((a)->expr_type == ST_COMPILE_TIME_EXPRESSION \
        && (b)->expr_type == ST_COMPILE_TIME_EXPRESSION) { \
      result = (Expression*)malloc(sizeof(CompileTimeExpression)); \
      CompileTimeExpression* lhs = (CompileTimeExpression*)(a); \
      CompileTimeExpression* rhs = (CompileTimeExpression*)(b); \
      if ((a)->data_type == ST_INT_TYPE && (b)->data_type == ST_INT_TYPE) { \
        result->data_type = ST_INT_TYPE; \
        ((CompileTimeExpression*)result)->int_val \
            = lhs->int_val bin_op rhs->int_val; \
      } else { \
        result->data_type = ST_REAL_TYPE; \
        ((CompileTimeExpression*)result)->real_val \
            = (lhs->data_type == ST_INT_TYPE ? lhs->int_val : lhs->real_val) \
                bin_op(rhs->data_type == ST_INT_TYPE ? rhs->int_val \
                                                     : rhs->real_val); \
      } \
    } else { \
      result = (Expression*)malloc(sizeof(RunTimeExpression)); \
      if ((a)->data_type == ST_INT_TYPE && (b)->data_type == ST_INT_TYPE) { \
        result->data_type = ST_INT_TYPE; \
      } else { \
        result->data_type = ST_REAL_TYPE; \
      } \
    } \
    result; \
  })
#endif
