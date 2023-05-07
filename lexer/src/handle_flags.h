#ifndef LEXER_HANDLE_FLAGS_H
#define LEXER_HANDLE_FLAGS_H

#include <stdbool.h>

extern bool verbose;
extern bool symbol_dump;
extern char* input_filename;

void handle_flags(int argc, char* argv[]);
void usage(const char* prog);

#endif /* end of include guard: LEXER_HANDLE_FLAGS_H */
