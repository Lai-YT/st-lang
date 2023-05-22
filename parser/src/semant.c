#include "semant.h"

#include <stdarg.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "semant_macros.h"

// User-defined lengths are never allowed to be non-positive, so negative
// values can be used as special meanings.

const int ST_STAR_STRING_LENGTH = -1;
const int ST_STAR_ARRAY_UPPER_BOUND = -1;

char* st_strdup(const char* s) {
  char* dup_s = malloc(sizeof(char) * (strlen(s) + 1));
  strcpy(dup_s, s);
  return dup_s;
}

int st_dimension_of_array(const StArrayTypeInfo* arr) {
  if (arr->data_type == ST_ARRAY_TYPE) {
    return 1 + st_dimension_of_array(arr->array_type_info);
  }
  return 1;
}

Expression* st_create_recovery_expression(StDataType type) {
  Expression* result = (Expression*)malloc(sizeof(RunTimeExpression));
  result->expr_type = ST_RUN_TIME_EXPRESSION;
  result->data_type = type;
  return result;
}

bool is_one_of_data_types(const StDataType type, int num_of_types, ...) {
  va_list types;
  va_start(types, num_of_types);
  while (num_of_types--) {
    if (type == va_arg(types, StDataType)) {
      va_end(types);
      return true;
    }
  }
  va_end(types);
  return false;
}

static bool st_is_assignable_array_type(const StArrayTypeInfo*,
                                        const StArrayTypeInfo*);
static bool st_is_assignable_string_type(const StStringTypeInfo*,
                                         const StStringTypeInfo*);

bool st_is_assignable_type(const StDataTypeInfo* lhs,
                           const StDataTypeInfo* rhs) {
  if (rhs->data_type == ST_INT_TYPE && lhs->data_type == ST_REAL_TYPE) {
    return true;
  }
  if (lhs->data_type != rhs->data_type) {
    return false;
  }
  if (lhs->data_type == ST_STRING_TYPE) {
    return st_is_assignable_string_type(lhs->string_type_info,
                                        rhs->string_type_info);
  }
  if (lhs->data_type == ST_ARRAY_TYPE) {
    return st_is_assignable_array_type(lhs->array_type_info,
                                       rhs->array_type_info);
  }
  // simple scalar types
  return true;
}

static bool is_star_array(const StArrayTypeInfo* array_type_info) {
  return array_type_info->array_type == ST_STATIC_ARRAY
         && ((StStaticArrayTypeInfo*)array_type_info)->upper_bound
                == ST_STAR_ARRAY_UPPER_BOUND;
}

static bool has_same_bounds(const StStaticArrayTypeInfo* a,
                            const StStaticArrayTypeInfo* b) {
  return a->lower_bound == b->lower_bound && a->upper_bound == b->upper_bound;
}

static bool st_is_assignable_array_type(const StArrayTypeInfo* lhs,
                                        const StArrayTypeInfo* rhs) {
  // for a formal star array, any array with the same lower bound is assignable
  if (is_star_array(lhs) && rhs->lower_bound == lhs->lower_bound) {
    StDataTypeInfo lhs_type = ST_MAKE_DATA_TYPE_INFO(lhs);
    StDataTypeInfo rhs_type = ST_MAKE_DATA_TYPE_INFO(rhs);
    return st_is_assignable_type(&lhs_type, &rhs_type);
  }

  // a dynamic array doesn't even have a upper-bound
  if (lhs->array_type == ST_DYNAMIC_ARRAY
      || rhs->array_type == ST_DYNAMIC_ARRAY) {
    return false;
  }
  if (!has_same_bounds((StStaticArrayTypeInfo*)lhs,
                       (StStaticArrayTypeInfo*)rhs)) {
    return false;
  }

  StDataTypeInfo lhs_type = ST_MAKE_DATA_TYPE_INFO(lhs);
  StDataTypeInfo rhs_type = ST_MAKE_DATA_TYPE_INFO(rhs);
  return st_is_assignable_type(&lhs_type, &rhs_type);
}

static bool st_is_assignable_string_type(const StStringTypeInfo* lhs,
                                         const StStringTypeInfo* rhs) {
  return rhs->max_length <= lhs->max_length
         || lhs->max_length == ST_STAR_STRING_LENGTH;
}
