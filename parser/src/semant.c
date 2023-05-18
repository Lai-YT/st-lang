#include "semant.h"

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "semant_macros.h"

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

static bool st_is_assignable_array_type(const StArrayTypeInfo*,
                                        const StArrayTypeInfo*);
static bool st_is_assignable_string_type(const StStringTypeInfo*,
                                         const StStringTypeInfo*);

bool st_is_assignable_type(const StDataTypeInfo* a, const StDataTypeInfo* b) {
  if (b->data_type == ST_INT_TYPE && a->data_type == ST_REAL_TYPE) {
    return true;
  }
  if (a->data_type != b->data_type) {
    return false;
  }
  if (a->data_type == ST_STRING_TYPE) {
    return st_is_assignable_string_type(a->string_type_info,
                                        b->string_type_info);
  }
  if (a->data_type == ST_ARRAY_TYPE) {
    return st_is_assignable_array_type(a->array_type_info, b->array_type_info);
  }
  // simple scalar types
  return true;
}

static bool st_is_assignable_array_type(const StArrayTypeInfo* a,
                                        const StArrayTypeInfo* b) {
  // have to always be the same but upper bound of dynamic arrays may vary
  if (a->array_type == ST_DYNAMIC_ARRAY || b->array_type == ST_DYNAMIC_ARRAY) {
    return false;
  }
  if (a->lower_bound != b->lower_bound
      || ((StStaticArrayTypeInfo*)a)->upper_bound
             != ((StStaticArrayTypeInfo*)b)->upper_bound) {
    return false;
  }

  StDataTypeInfo a_type = ST_MAKE_DATA_TYPE_INFO(a);
  StDataTypeInfo b_type = ST_MAKE_DATA_TYPE_INFO(b);
  return st_is_assignable_type(&a_type, &b_type);
}

static bool st_is_assignable_string_type(const StStringTypeInfo* a,
                                         const StStringTypeInfo* b) {
  return a->max_length == b->max_length;
}
