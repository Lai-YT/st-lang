#include <getopt.h>
#include <stdbool.h>
#include <stddef.h>  // NULL
#include <stdio.h>
#include <stdlib.h>

#include "list.h"
#include "symtab.h"

// the symbol table used in the lexer
SymbolTable* symtab;
// the flex scanning routine
extern int yylex();
// whenever `yylex` is called, it scans tokens from the global input file yyin
extern FILE* yyin;

void dump_symbols(SymbolTable*);
void usage(const char* prog);

int main(int argc, char* argv[]) {
  struct option options[] = {
      {"dump", no_argument, 0, 'd'},
  };

  bool symbol_dump = false;

  int arg;
  while ((arg = getopt_long(argc, argv, "d", options, NULL)) != -1) {
    switch (arg) {
      case 'd':
        symbol_dump = true;
        break;
      default:
        usage(argv[0]);
        exit(EXIT_FAILURE);
    }
  }

  if (optind + 1 != argc) {
    usage(argv[0]);
    exit(EXIT_FAILURE);
  }

  yyin = fopen(argv[optind], "r");
  if (!yyin) {
    fprintf(stderr, "error: could not open input file %s\n", argv[optind]);
    exit(EXIT_FAILURE);
  }

  // a new symbol table for the lexer to use
  symtab = symtab_create();

  // Since we're not using `return` after recognizing a token, `yylex` lexes the
  // entire file in a single call.
  yylex();

  if (symbol_dump) {
    putchar('\n');
    dump_symbols(symtab);
  }

  symtab_delete(symtab);
  fclose(yyin);

  return 0;
}

void usage(const char* prog) {
  fprintf(stderr,
          "usage: %s [-d] FILE\n"
          "\n"
          "  FILE            The file to be lexical analyzed\n"
          "\n"
          "Options:\n"
          "  -d, --dump      Dumps the identifiers and their attributes\n",
          prog);
}

void dump_symbols(SymbolTable* table) {
  puts("Symbol Table:");
  List* dump = symtab_dump(table);
  List* curr = dump;
  while (curr) {
    Entry* entry = curr->val;
    printf("%s: %s\n", entry->name, type_to_str(entry->type));
    curr = curr->rest;
  }
  list_delete(dump);
}
