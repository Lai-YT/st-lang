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

#ifndef ST_CODE_GEN_COMPARISON_EXPRESSION
/// @param ifcond The condition instruction. Is a charater string.
/// @param true_branch The label number of the true branch.
/// @param end_branch The label number of the end branch.
#define ST_CODE_GEN_COMPARISON_EXPRESSION(ifcond, true_branch, end_branch) \
  ST_CODE_GEN("isub\n"); \
  ST_CODE_GEN("%s L%d\n", (ifcond), (true_branch)); \
  ST_CODE_GEN("iconst_0\n"); \
  ST_CODE_GEN("goto L%d\n", (end_branch)); \
  ST_CODE_GEN("L%d:\n", (true_branch)); \
  ST_CODE_GEN("iconst_1\n"); \
  ST_CODE_GEN("L%d:\n", (end_branch));
#endif

void gen_identifier_code(Identifier*);
void gen_expression_code(Expression*);

#endif /* end of include guard: CODEGEN_CODEGEN_H */
