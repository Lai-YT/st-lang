/*
 * This file augments the generated header file with additionally defined
 * variables, which may be useful to the parser.
 */

#include "../src/st-lex.h"
#include "lex_macros.h"

/// @brief The content of the line which the lexer is scanning on.
extern char st_cur_line[255 + 1];
