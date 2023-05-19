#ifndef PARSER_SEMANT_H
#define PARSER_SEMANT_H

#include <stdbool.h>
#include <stddef.h>

#include "semant_macros.h"

/// @return An identical malloc'd string.
char* st_strdup(const char* s);

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

/// @brief The max length of a string is always determined at compile-time.
typedef struct StStringTypeInfo {
  size_t max_length;
} StStringTypeInfo;

typedef struct StArrayTypeInfo StArrayTypeInfo;

#ifndef ST_DATA_TYPE_INFO
/// @note Any struct that carries type information should use this.
#define ST_DATA_TYPE_INFO \
  StDataType data_type; \
  union { \
    /** @brief Only available when the data type is ST_ARRAY_TYPE. */ \
    StArrayTypeInfo* array_type_info; \
    /** @brief Only available when the data type is ST_STRING_TYPE. */ \
    StStringTypeInfo* string_type_info; \
  };
#endif

#ifndef ST_COMPILE_TIME_DATA_VALUE
/// @brief A union of scalar values.
/// @note Any structure that hold compile-time values should use this.
#define ST_COMPILE_TIME_DATA_VALUE \
  union { \
    int int_val; \
    double real_val; \
    bool bool_val; \
    char* string_val; \
  };
#endif

typedef enum StArrayType {
  ST_DYNAMIC_ARRAY,
  ST_STATIC_ARRAY,
} StArrayType;

#ifndef ST_ARRAY_TYPE_INFO_COMMON_DATA
#define ST_ARRAY_TYPE_INFO_COMMON_DATA \
  StArrayType array_type; \
  ST_DATA_TYPE_INFO \
  int lower_bound;
#endif

/// @brief The upper bound of a dynamic array is determined at run-time, so is
/// not recorded.
typedef struct StDynamicArrayTypeInfo {
  ST_ARRAY_TYPE_INFO_COMMON_DATA
} StDynamicArrayTypeInfo;

typedef struct StStaticArrayTypeInfo {
  ST_ARRAY_TYPE_INFO_COMMON_DATA
  int upper_bound;
} StStaticArrayTypeInfo;

struct StArrayTypeInfo {
  ST_ARRAY_TYPE_INFO_COMMON_DATA
};

/// @brief A data type structure which carries all necessary type information.
typedef struct StDataTypeInfo {
  ST_DATA_TYPE_INFO
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
  ST_DATA_TYPE_INFO
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
} VarIdentifier;

typedef enum StConstIdentifierType {
  ST_COMPILE_TIME_CONST_IDENTIFIER,
  ST_RUN_TIME_CONST_IDENTIFIER,
} StConstIdentifierType;

typedef struct CompileTimeConstIdentifier {
  ST_CONST_IDENTIFIER_COMMON_DATA
  ST_COMPILE_TIME_DATA_VALUE
} CompileTimeConstIdentifier;

/// @brief The value of a run-time constant identifier is, as its name, run-time
/// determined, so we don't record its value.
typedef struct RunTimeConstIdentifier {
  ST_CONST_IDENTIFIER_COMMON_DATA
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

#ifndef ST_EXPRESSION_COMMON_DATA
#define ST_EXPRESSION_COMMON_DATA \
  StExpressionType expr_type; \
  ST_DATA_TYPE_INFO
#endif

/// @brief The value of a compile-time expression is determined at compile-time.
typedef struct CompileTimeExpression {
  ST_EXPRESSION_COMMON_DATA
  ST_COMPILE_TIME_DATA_VALUE
} CompileTimeExpression;

/// @brief The value of a run-time expression is determined at run-time, so we
/// don't record its value.
typedef struct RunTimeExpression {
  ST_EXPRESSION_COMMON_DATA
} RunTimeExpression;

typedef struct Expression {
  ST_EXPRESSION_COMMON_DATA
} Expression;

/*
 * When a reference is used as lhs, we have to know
 *  (1) is const or var
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

#ifndef ST_REFERENCE_COMMON_DATA
#define ST_REFERENCE_COMMON_DATA \
  StReferenceType ref_type; \
  /* data type and constant-ness are forwarded */ \
  bool is_const; \
  ST_DATA_TYPE_INFO
#endif

typedef struct ArraySubscriptReference {
  ST_REFERENCE_COMMON_DATA
} ArraySubscriptReference;

typedef struct IdentifierReference {
  ST_REFERENCE_COMMON_DATA
  Identifier* id;
} IdentifierReference;

typedef struct Reference {
  ST_REFERENCE_COMMON_DATA
} Reference;

int st_dimension_of_array(const StArrayTypeInfo* arr);

/// @return Whether type b is assignable to a.
/// @note (1) int is considered as assignable to real. (2) strings with the
/// same max length are considered as assignable; strings without
// explicit max length has max length 255. (3) arrays with same lower and
// upper-bound and component type are assignable.
bool st_is_assignable_type(const StDataTypeInfo* a, const StDataTypeInfo* b);

#endif /* end of include guard: PARSER_SEMANT_H */
