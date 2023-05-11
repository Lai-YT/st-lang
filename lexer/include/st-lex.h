/*
 * This file augments the generated header file with additionally defined
 * variables, which may be useful to the parser.
 */

#include "../src/st-lex.h"

/// @brief The content of the line which the lexer is scanning on.
extern char* st_cur_line;

#ifndef ST_TOKEN_COLUMN
#define ST_TOKEN_COLUMN
typedef struct StTokenColumn {
  int begin;
  int end;
} StTokenColumn;
#endif

/// @brief The current token locates at [begin, end]. Both 0 when no token is
/// held.
StTokenColumn st_cur_token_col;
