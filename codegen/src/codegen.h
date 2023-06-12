#ifndef CODEGEN_CODEGEN_H
#define CODEGEN_CODEGEN_H

#include <stddef.h>
#include <stdio.h>
#include <string.h>

#include "st-lex.h"

extern FILE* st_codegen_out;
/// @brief For generated code to be more readable.
char indentions[1000];

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

#ifndef INIT_INDENTION
#define INIT_INDENTION() indentions[0] = '\0'
#endif
#ifndef INDENT
/// @note Should call every time a new scope is entered.
#define INDENT() strcat(indentions, "  " /* 2-space */)
#endif
#ifndef DEDENT
/// @note Should call every time a scope is left.
#define DEDENT() indentions[strlen(indentions) - 2] = '\0'
#endif

#ifndef ST_UNIMPLEMENTED_ERROR
#define ST_UNIMPLEMENTED_ERROR() ST_UNREACHABLE()
#endif

#ifndef ST_CODE_GEN_COMPARISON_EXPRESSION
/// @param ifcond The condition instruction. Is a charater string.
/// @param true_branch The label number of the true branch.
/// @param end_branch The label number of the end branch.
#define ST_CODE_GEN_COMPARISON_EXPRESSION(ifcond, true_branch, end_branch) \
  ST_CODE_GEN("%sisub\n", indentions); \
  ST_CODE_GEN("%s%s Ltrue%d\n", indentions, (ifcond), (true_branch)); \
  ST_CODE_GEN("%siconst_0\n", indentions); \
  ST_CODE_GEN("%sgoto Lend%d\n", indentions, (end_branch)); \
  ST_CODE_GEN("%sLtrue%d:\n", indentions, (true_branch)); \
  ST_CODE_GEN("%siconst_1\n", indentions); \
  ST_CODE_GEN("%sLend%d:\n", indentions, (end_branch));
#endif

#endif /* end of include guard: CODEGEN_CODEGEN_H */
