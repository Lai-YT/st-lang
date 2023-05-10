/*
 * This file augments the generated header file with additionally defined
 * variables, which may be useful to the parser.
 */

#include "../src/st-lex.h"

/// @brief The content of the line which the lexer is scanning on.
extern char* cur_line;

#ifndef ST_TOKEN_LOCATION
#define ST_TOKEN_LOCATION
typedef struct TokenLocation {
  int begin;
  int end;
} TokenLocation;
#endif

/// @brief The current token locates at [begin, end). Starts from 0.
extern TokenLocation cur_token_loc;
