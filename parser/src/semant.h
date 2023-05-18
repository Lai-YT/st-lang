#ifndef PARSER_SEMANT_H
#define PARSER_SEMANT_H

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

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

/// @brief The max length of a string is always determined at compile-time.
typedef struct StStringTypeInfo {
  size_t max_length;
} StStringTypeInfo;

typedef enum StArrayType {
  ST_DYNAMIC_ARRAY,
  ST_STATIC_ARRAY,
} StArrayType;

typedef struct StArrayTypeInfo StArrayTypeInfo;

#ifndef ST_ARRAY_TYPE_INFO_COMMON_DATA
#define ST_ARRAY_TYPE_INFO_COMMON_DATA \
  StArrayType array_type; \
  StDataType data_type; \
  union { \
    StArrayTypeInfo* array_type_info; \
    StStringTypeInfo* string_type_info; \
  }; \
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

/// @brief Wraps the data type and its additional information together.
/// @note This structure is capable to hold all information of types, especially
/// useful for complex types, such as string and array. But if only int, real
/// and bool are needed, simple use a StDataType instead.
typedef struct StDataTypeInfo {
  StDataType data_type;
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    StArrayTypeInfo* array_type_info;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    StStringTypeInfo* string_type_info;
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
    StArrayTypeInfo* array_type_info;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    StStringTypeInfo* string_type_info;
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
    char* string_val;
  };
} CompileTimeConstIdentifier;

/// @brief The value of a run-tie constant identifier is, as its name, run-time
/// determined, so we don't record its value.
typedef struct RunTimeConstIdentifier {
  ST_CONST_IDENTIFIER_COMMON_DATA
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    StArrayTypeInfo* array_type_info;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    StStringTypeInfo* string_type_info;
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

#ifndef ST_EXPRESSION_COMMON_DATA
#define ST_EXPRESSION_COMMON_DATA \
  StExpressionType expr_type; \
  StDataType data_type;
#endif

/// @brief The value of a compile-time expression is determined at compile-time.
typedef struct CompileTimeExpression {
  ST_EXPRESSION_COMMON_DATA
  union {
    int int_val;
    double real_val;
    bool bool_val;
    char* string_val;
  };
} CompileTimeExpression;

/// @brief The value of a run-time expression is determined at run-time, so we
/// don't record its value.
typedef struct RunTimeExpression {
  ST_EXPRESSION_COMMON_DATA
  union {
    /// @brief Only available when the data type is ST_ARRAY_TYPE.
    StArrayTypeInfo* array_type_info;
    /// @brief Only available when the data type is ST_STRING_TYPE.
    StStringTypeInfo* string_type_info;
  };
} RunTimeExpression;

typedef struct Expression {
  ST_EXPRESSION_COMMON_DATA
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

#ifndef ST_REFERENCE_COMMON_DATA
#define ST_REFERENCE_COMMON_DATA \
  StReferenceType ref_type; \
  /* data type and constant-ness are forwarded */ \
  bool is_const; \
  StDataType data_type; \
  union { \
    StArrayTypeInfo* array_type_info; \
    StStringTypeInfo* string_type_info; \
  };
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

/// @return An IdentifierReference with id as its underlying identifier.
IdentifierReference* make_identifier_reference(Identifier* id) {
  IdentifierReference* id_ref = malloc(sizeof(IdentifierReference));
  id_ref->ref_type = ST_IDENTIFIER_REFERENCE;
  id_ref->id = id;
  switch (id->id_type) {
    case ST_CONST_IDENTIFIER:
      id_ref->is_const = false;
      switch (((ConstIdentifier*)id)->const_id_type) {
        case ST_COMPILE_TIME_CONST_IDENTIFIER: {
          CompileTimeConstIdentifier* compile_time_const_id
              = (CompileTimeConstIdentifier*)id;
          id_ref->data_type = compile_time_const_id->data_type;
          if (compile_time_const_id->data_type == ST_STRING_TYPE) {
            // a compile-time identifier records the value of the string instead
            // of its type info, so have to make one
            id_ref->string_type_info = malloc(sizeof(StStringTypeInfo));
            id_ref->string_type_info->max_length
                = strlen(compile_time_const_id->string_val);
          }
        } break;
        case ST_RUN_TIME_CONST_IDENTIFIER:
          ST_COPY_TYPE(id_ref, (RunTimeConstIdentifier*)id);
          break;
        default:
          ST_UNREACHABLE();
      }
      break;
    case ST_VAR_IDENTIFIER:
      id_ref->is_const = false;
      ST_COPY_TYPE(id_ref, (VarIdentifier*)id);
      break;
    default:
      ST_UNREACHABLE();
  }
  return id_ref;
}

int st_dimension_of_array(const StArrayTypeInfo* arr) {
  if (arr->data_type == ST_ARRAY_TYPE) {
    return 1 + st_dimension_of_array(arr->array_type_info);
  }
  return 1;
}

#endif /* end of include guard: PARSER_SEMANT_H */
