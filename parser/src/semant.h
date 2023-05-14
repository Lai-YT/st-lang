#ifndef PARSER_SEMANT_H
#define PARSER_SEMANT_H

#include <stdbool.h>
#include <stddef.h>

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
  int lower_bound;

  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE. The type of
    /// the array should be ST_DYNAMIC_ARRAY since nested dynamic arrays are not
    /// allowed.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
} DynamicArray;

typedef struct StaticArray {
  int lower_bound;
  int upper_bound;

  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE. The type of
    /// the array should be ST_DYNAMIC_ARRAY since nested dynamic arrays are not
    /// allowed.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
} StaticArray;

struct Array {
  StArrayType array_type;
  union {
    DynamicArray* dynamic_array;
    StaticArray* static_array;
  };
};

typedef enum StIdentifierType {
  ST_CONST_IDENTIFIER,
  ST_VAR_IDENTIFIER,
  ST_SUBPROGRAM_IDENTIFIER,
} StIdentifierType;

/// @brief Since the value of a variable identifier is determined at run-time,
/// we don't record its value here.
typedef struct VarIdentifier {
  char* name;
  StDataType data_type;
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
  /// @brief Should always be a scalar type to meet the constraint of a
  /// compile-time expression.
  StDataType data_type;
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
  StDataType data_type;
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
  char* name;
  StConstIdentifierType const_id_type;
  union {
    CompileTimeConstIdentifier* compile_time_const_id;
    RunTimeConstIdentifier* run_time_const_id;
  };
} ConstIdentifier;

/// @brief This is what symbol tables store as their data type.
typedef struct Identifier {
  StIdentifierType id_type;
  union {
    VarIdentifier* var_id;
    ConstIdentifier* const_id;
    // TODO: subprograms
  };
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
  bool is_const;
  /// @brief May also be an array.
  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    Array* array;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    String* string;
  };
} ArraySubscript;

typedef struct Reference {
  StReferenceType ref_type;
  union {
    /// @brief The type of the id can't be ST_SUBPROGRAM_IDENTIFIER.
    Identifier* id_ref;
    ArraySubscript* array_subscript_ref;
  };
} Reference;

#endif /* end of include guard: PARSER_SEMANT_H */
