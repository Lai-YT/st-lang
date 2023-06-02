#ifndef CODEGEN_CODEGEN_H
#define CODEGEN_CODEGEN_H

#include <stdio.h>
#include <string.h>

#include "semant.h"
#include "semant_macros.h"
#include "st-lex.h"

extern FILE* st_codegen_out;

#ifndef ST_CODE_GEN
#define ST_CODE_GEN(...) fprintf(st_codegen_out, __VA_ARGS__);
#endif

#ifndef ST_CODE_GEN_COMMENT
/// @brief Surrounds by "/*" and "*/".
#define ST_CODE_GEN_COMMENT(...) \
  ST_CODE_GEN("/* "); \
  ST_CODE_GEN(__VA_ARGS__); \
  ST_CODE_GEN(" */\n");
#endif

#ifndef ST_CODE_GEN_SOURCE_COMMENT
#define ST_CODE_GEN_SOURCE_COMMENT(yylloc) \
  /* strip the '\n' from st_cur_line */ \
  const size_t len = strlen(st_cur_line); \
  st_cur_line[len - 1] = '\0'; \
  ST_CODE_GEN_COMMENT("%d: %s", (yylloc).first_line, st_cur_line); \
  /* restore the '\n', so it doesn't break the lexing */ \
  st_cur_line[len - 1] = '\n'; \
  st_cur_line[len] = '\0';
#endif

#ifndef ST_UNIMPLEMENTED_ERROR
#define ST_UNIMPLEMENTED_ERROR() ST_UNREACHABLE()
#endif

void gen_identifier_code(Identifier*);
void gen_expression_code(Expression*);

#endif /* end of include guard: CODEGEN_CODEGEN_H */
