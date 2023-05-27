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

StArrayTypeInfo* st_dup_array_type_info(StArrayTypeInfo* array_type_info) {
  StArrayTypeInfo* result = NULL;
  if (array_type_info->array_type == ST_STATIC_ARRAY) {
    result = (StArrayTypeInfo*)malloc(sizeof(StStaticArrayTypeInfo));
    ((StStaticArrayTypeInfo*)result)->upper_bound
        = ((StStaticArrayTypeInfo*)array_type_info)->upper_bound;
  } else if (array_type_info->array_type == ST_DYNAMIC_ARRAY) {
    result = (StArrayTypeInfo*)malloc(sizeof(StDynamicArrayTypeInfo));
  }
  result->lower_bound = array_type_info->lower_bound;
  result->array_type = array_type_info->array_type;
  result->data_type = array_type_info->data_type;
  if (array_type_info->data_type == ST_STRING_TYPE) {
    result->string_type_info = malloc(sizeof(StStringTypeInfo));
    result->string_type_info->max_length
        = array_type_info->string_type_info->max_length;
  } else if (array_type_info->data_type == ST_ARRAY_TYPE) {
    result->array_type_info
        = st_dup_array_type_info(array_type_info->array_type_info);
  }
  return result;
}

#ifndef ST_FREE_DATA_TYPE_INFO
/// @param x must necessarily carry all data in ST_DATA_TYPE_INFO
/// @note x itself is not freed since we don't know its type here
#define ST_FREE_DATA_TYPE_INFO(x) \
  { \
    if ((x)->data_type == ST_STRING_TYPE) { \
      free((x)->string_type_info); \
    } else if ((x)->data_type == ST_ARRAY_TYPE) { \
      st_free_array_type_info((x)->array_type_info); \
    } \
    /* other scalar types have no type info to be freed */ \
  }
#endif

void st_free_array_type_info(StArrayTypeInfo* array_type_info) {
  /* free underlying type */
  if (array_type_info->data_type == ST_STRING_TYPE) {
    free(array_type_info->string_type_info);
  } else if (array_type_info->data_type == ST_ARRAY_TYPE) {
    // multi-dimensional arrays are recursively defined, so free them
    // recursively
    st_free_array_type_info(array_type_info->array_type_info);
  }
  // other scalar types have no type info to be freed

  /* free the array info itself */
  if (array_type_info->array_type == ST_DYNAMIC_ARRAY) {
    free((StDynamicArrayTypeInfo*)array_type_info);
  } else if (array_type_info->array_type == ST_STATIC_ARRAY) {
    free((StStaticArrayTypeInfo*)array_type_info);
  } else {
    ST_UNREACHABLE();
  }
}

void st_free_data_type_info(StDataTypeInfo* data_type_info) {
  ST_FREE_DATA_TYPE_INFO(data_type_info);
  free(data_type_info);
}

static void st_free_formals(List* formals);

void st_free_identifier(Identifier* id) {
  ST_FREE_DATA_TYPE_INFO(id);
  free(id->name);
  if (id->id_type == ST_CONST_IDENTIFIER) {
    ConstIdentifier* const_id = (ConstIdentifier*)id;
    if (const_id->const_id_type == ST_COMPILE_TIME_CONST_IDENTIFIER) {
      if (const_id->data_type == ST_STRING_TYPE) {
        free(((CompileTimeConstIdentifier*)const_id)->string_val);
      }
      free((CompileTimeConstIdentifier*)const_id);
    } else if (const_id->const_id_type == ST_RUN_TIME_CONST_IDENTIFIER) {
      free((RunTimeConstIdentifier*)const_id);
    } else {
      ST_UNREACHABLE();
    }
  } else if (id->id_type == ST_VAR_IDENTIFIER) {
    free((VarIdentifier*)id);
  } else if (id->id_type == ST_SUBPROGRAM_IDENTIFIER) {
    Subprogram* subprogram = (Subprogram*)id;
    if (subprogram->subprogram_type == ST_PROCEDURE_SUBPROGRAM) {
      st_free_formals(subprogram->formals);
      free((ProcedureSubprogram*)subprogram);
    } else if (subprogram->subprogram_type == ST_FUNCTION_SUBPROGRAM) {
      st_free_formals(subprogram->formals);
      st_free_data_type_info(((FunctionSubprogram*)subprogram)->result_type);
      free((FunctionSubprogram*)subprogram);
    } else {
      ST_UNREACHABLE();
    }
  } else {
    ST_UNREACHABLE();
  }
}

static void st_free_formals(List* formals) {
  List* curr = formals;
  while (curr) {
    st_free_data_type_info((StDataTypeInfo*)curr->val);
    curr = curr->rest;
  }
  list_delete(formals);
}

void st_free_reference(Reference* ref) {
  ST_FREE_DATA_TYPE_INFO(ref);
  if (ref->ref_type == ST_ARRAY_SUBSCRIPT_REFERENCE) {
    free((ArraySubscriptReference*)ref);
  } else if (ref->ref_type == ST_IDENTIFIER_REFERENCE) {
    // the data type is forwarded by deep copy, so has to be freed separately
    free((IdentifierReference*)ref);
  } else {
    ST_UNREACHABLE();
  }
}

void st_free_expression(Expression* expr) {
  ST_FREE_DATA_TYPE_INFO(expr);

  if (expr->expr_type == ST_COMPILE_TIME_EXPRESSION) {
    if (expr->data_type == ST_STRING_TYPE) {
      free(((CompileTimeExpression*)expr)->string_val);
    }
    free((CompileTimeExpression*)expr);
  } else if (expr->expr_type == ST_RUN_TIME_EXPRESSION) {
    free((RunTimeExpression*)expr);
  } else {
    ST_UNREACHABLE();
  }
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
