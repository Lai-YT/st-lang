#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semant.h"

/// @brief The file being semantically checked.
extern char* input_filename;
extern int allow_semantic_errors;

#ifndef ST_TRACE
#define ST_TRACE(...) fprintf(stderr, __VA_ARGS__)
#endif

#ifndef ST_FATAL_ERROR
/// @brief Prints the format message to stderr and exits as failure.
#define ST_FATAL_ERROR(yylloc, ...) \
  { \
    fprintf(stderr, "%s:%d:%d: error: ", input_filename, (yylloc).first_line, \
            (yylloc).first_column); \
    fprintf(stderr, __VA_ARGS__); \
    exit(allow_semantic_errors ? EXIT_SUCCESS : EXIT_FAILURE); \
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
