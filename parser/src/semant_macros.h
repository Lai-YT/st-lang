#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "semant.h"

#ifndef ST_TRACE
#define ST_TRACE(...) fprintf(stderr, __VA_ARGS__)
#endif

#ifndef ST_FATAL_ERROR
/// @brief Prints the format message to stderr and exits as failure.
#define ST_FATAL_ERROR(...) \
  { \
    fprintf(stderr, "error: "); \
    fprintf(stderr, __VA_ARGS__); \
    exit(EXIT_FAILURE); \
  }
#endif

#ifndef ST_UNREACHABLE
#define ST_UNREACHABLE() assert(false)
#endif

#ifndef ST_COPY_SCALAR_VALUE
/// @brief Copies the data type and the correspond scalar value of b to a.
/// @note (1) a and b should be pointers (2) their data_type should be scalar
/// type (3) they should both have a union of scalar values.
#define ST_COPY_SCALAR_VALUE(a, b) \
  { \
    (a)->data_type = (b)->data_type; \
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
        (a)->string = (b)->string; \
        break; \
      default: \
        ST_UNREACHABLE(); \
    } \
  }
#endif

#ifndef ST_COPY_TYPE
/// @brief Copies the data type and the correspond additional information of b
/// to a.
/// @note (1) a and b should be pointers (2) they should both have a union of
/// additional information.
#define ST_COPY_TYPE(a, b) \
  { \
    (a)->data_type = (b)->data_type; \
    switch ((b)->data_type) { \
      case ST_STRING_TYPE: \
        (a)->string = (b)->string; \
        break; \
      case ST_ARRAY_TYPE: \
        (a)->array = (b)->array; \
        break; \
      default: \
        /* has no additional information to copy */ \
        break; \
    } \
  }
#endif
