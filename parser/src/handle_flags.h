#ifndef PARSER_HANDLE_FLAGS_H
#define PARSER_HANDLE_FLAGS_H

#include <stdbool.h>

/// @brief Each step taken by the parser when yydebug is nonzero produces a line
/// or two of trace information, written on stderr.
extern int yydebug;
extern char* input_filename;

void handle_flags(int argc, char* argv[]);
void usage(const char* prog);

#endif /* end of include guard: PARSER_HANDLE_FLAGS_H */
