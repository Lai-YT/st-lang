#ifndef CODEGEN_CODEGEN_H
#define CODEGEN_CODEGEN_H

#include <stdbool.h>
#include <stdio.h>

#include "semant.h"
#include "semant_macros.h"

extern bool gen_code;
extern FILE* st_codegen_out;

#ifndef ST_CODE_GEN
#define ST_CODE_GEN(...) \
  if (gen_code) { \
    fprintf(st_codegen_out, __VA_ARGS__); \
  }
#endif

#ifndef ST_UNIMPLEMENTED_ERROR
#define ST_UNIMPLEMENTED_ERROR() ST_UNREACHABLE()
#endif

void gen_identifier_code(Identifier*);
void gen_expression_code(Expression*);

#endif /* end of include guard: CODEGEN_CODEGEN_H */
