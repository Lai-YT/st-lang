#ifndef PARSER_SEMANT_H
#define PARSER_SEMANT_H

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>

#include "semant_macros.h"

typedef enum StDataType {
  /*
   * scalar types
   */

  ST_INT_TYPE,
  ST_REAL_TYPE,
  ST_STRING_TYPE,
  ST_BOOL_TYPE,

  /*
   * array types
   */

  ST_ARRAY_TYPE,
} StDataType;

typedef enum StStringType {
  ST_VAR_STRING,
  ST_CONST_STRING,
} StStringType;

/// @brief The value of an variable string is determined at run-time, so we
/// don't record it.
typedef struct VarString {
  /* empty */
} VarString;

typedef struct ConstString {
  char* val;
} ConstString;

/// @brief The max length of a string is always determined at compile-time.
typedef struct String {
  StStringType string_type;
  size_t max_length;
  union {
    VarString* var_string;
    ConstString* const_string;
  };
} String;

typedef enum StArrayType {
  ST_DYNAMIC_ARRAY,
  ST_STATIC_ARRAY,
} StArrayType;

typedef struct Array Array;

/// @brief The upper bound of a dynamic array is determined at run-time, so is
/// not recorded.
typedef struct DynamicArray {
  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE. The type of
    /// the array should be ST_DYNAMIC_ARRAY since nested dynamic arrays are not
    /// allowed.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
  int lower_bound;
} DynamicArray;

typedef struct StaticArray {
  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE. The type of
    /// the array should be ST_DYNAMIC_ARRAY since nested dynamic arrays are not
    /// allowed.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
  int lower_bound;
  int upper_bound;
} StaticArray;

struct Array {
  StArrayType array_type;
  union {
    DynamicArray* dynamic_array;
    StaticArray* static_array;
  };
};

/// @brief Wraps the data type and its additional information together.
/// @note This structure is capable to hold all information of types, especially
/// useful for complex types, such as string and array. But if only int, real
/// and bool are needed, simple use a StDataType instead.
typedef struct StDataTypeInfo {
  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
} StDataTypeInfo;

typedef enum StIdentifierType {
  ST_CONST_IDENTIFIER,
  ST_VAR_IDENTIFIER,
  ST_SUBPROGRAM_IDENTIFIER,
} StIdentifierType;

#ifndef ST_IDENTIFIER_COMMON_DATA
#define ST_IDENTIFIER_COMMON_DATA \
  StIdentifierType id_type; \
  char* name; \
  StDataType data_type;
#endif

#ifndef ST_CONST_IDENTIFIER_COMMON_DATA
#define ST_CONST_IDENTIFIER_COMMON_DATA \
  ST_IDENTIFIER_COMMON_DATA \
  StConstIdentifierType const_id_type;
#endif

/// @brief Since the value of a variable identifier is determined at run-time,
/// we don't record its value here.
typedef struct VarIdentifier {
  ST_IDENTIFIER_COMMON_DATA
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
} VarIdentifier;

typedef enum StConstIdentifierType {
  ST_COMPILE_TIME_CONST_IDENTIFIER,
  ST_RUN_TIME_CONST_IDENTIFIER,
} StConstIdentifierType;

typedef struct CompileTimeConstIdentifier {
  ST_CONST_IDENTIFIER_COMMON_DATA
  union {
    int int_val;
    double real_val;
    bool bool_val;
    /// @brief The type of the string should be ST_CONST_STRING.
    String* string;
  };
} CompileTimeConstIdentifier;

/// @brief The value of a run-tie constant identifier is, as its name, run-time
/// determined, so we don't record its value.
typedef struct RunTimeConstIdentifier {
  ST_CONST_IDENTIFIER_COMMON_DATA
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE. The type of
    /// the string should be ST_VAR_STRING (otherwise this const identifier is a
    /// compile-time const identifier).
    String* string;
  };
} RunTimeConstIdentifier;

/// @brief The value of an const identifier may be run-time determined. In such
/// case, the identifier cannot represent a compile-time expression, and its
/// value isn't recorded.
typedef struct ConstIdentifier {
  ST_CONST_IDENTIFIER_COMMON_DATA
} ConstIdentifier;

/// @brief This is what symbol tables store as their data type.
typedef struct Identifier {
  ST_IDENTIFIER_COMMON_DATA
} Identifier;

typedef enum StExpressionType {
  ST_RUN_TIME_EXPRESSION,
  ST_COMPILE_TIME_EXPRESSION,
} StExpressionType;

typedef struct CompileTimeExpression {
  /// @brief Should always be a scalar type.
  StDataType data_type;
  union {
    int int_val;
    double real_val;
    bool bool_val;
    /// @brief The type of the string should be ST_CONST_STRING.
    String* string;
  };
} CompileTimeExpression;

/// @brief The value of a run-time expression is determined at run-time, so we
/// don't record its value.
typedef struct RunTimeExpression {
  /// @brief May be a scalar type or a array type that holds a static array.
  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE. The type of
    /// the string should be ST_VAR_STRING (otherwise this expression is a
    /// compile-time expression).
    String* string;
  };
} RunTimeExpression;

typedef struct Expression {
  StExpressionType expr_type;
  union {
    CompileTimeExpression* compile_time_expr;
    RunTimeExpression* run_time_expr;
  };
} Expression;

/*
 * When a reference is used as lhs, we have to know
 *  (1) its const or var
 *  (2) its type
 * When is used as rhs, we have to know
 *  (1) its type
 *  (2) is compile-time expression or not
 *  (3) if is compile-time expression, what's its value
 * The reference may be a subscript of an array.
 */

typedef enum StReferenceType {
  ST_IDENTIFIER_REFERENCE,
  ST_ARRAY_SUBSCRIPT_REFERENCE,
} StReferenceType;

typedef struct ArraySubscript {
  /// @brief May also be an array.
  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
  bool is_const;
} ArraySubscript;

typedef struct Reference {
  StReferenceType ref_type;
  union {
    /// @brief The type of the id can't be ST_SUBPROGRAM_IDENTIFIER.
    Identifier* id_ref;
    ArraySubscript* array_subscript_ref;
  };
} Reference;

/// @brief Gets the data type of the expression, no matter it's a compile-time
/// or run-time expression.
StDataType st_data_type_of_expr(Expression* expr) {
  if (expr->expr_type == ST_COMPILE_TIME_EXPRESSION) {
    return expr->compile_time_expr->data_type;
  } else if (expr->expr_type == ST_RUN_TIME_EXPRESSION) {
    return expr->run_time_expr->data_type;
  } else {
    ST_UNREACHABLE();
    return (StDataType)-1;  // to suppress -Wreturn-type
  }
}

int st_dimension_of_array(const Array* arr) {
  if (arr->array_type == ST_STATIC_ARRAY) {
    if (arr->static_array->data_type == ST_ARRAY_TYPE) {
      return 1 + st_dimension_of_array(arr->static_array->array);
    }
    return 1;
  } else if (arr->array_type == ST_DYNAMIC_ARRAY) {
    if (arr->dynamic_array->data_type == ST_ARRAY_TYPE) {
      return 1 + st_dimension_of_array(arr->dynamic_array->array);
    }
    return 1;
  } else {
    ST_UNREACHABLE();
    return -1;  // to suppress -Wreturn-type
  }
}

#endif /* end of include guard: PARSER_SEMANT_H */
