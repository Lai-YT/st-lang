#include <getopt.h>
#include <stdbool.h>
#include <stddef.h>  // NULL
#include <stdio.h>
#include <stdlib.h>

#include "handle_flags.h"
#include "list.h"
#include "st-parse.h"
#include "symtab.h"

// the symbol table used in the lexer
SymbolTable* symtab;
// the semantic value of the token
// defined here since it not compiled with the bison parser
YYSTYPE yylval;

// the flex scanning routine
extern int yylex();
// whenever `yylex` is called, it scans tokens from the global input file yyin
extern FILE* yyin;

void dump_symbols(SymbolTable*);

int main(int argc, char* argv[]) {
  handle_flags(argc, argv);

  yyin = fopen(input_filename, "r");
  if (!yyin) {
    fprintf(stderr, "error: could not open input file %s\n", input_filename);
    exit(EXIT_FAILURE);
  }

  // a new symbol table for the lexer to use
  symtab = symtab_create();

  int token;
  while ((token = yylex()) != YYEOF) {
    ;
  }

  if (symbol_dump) {
    putchar('\n');
    dump_symbols(symtab);
  }

  symtab_delete(symtab);
  fclose(yyin);

  return 0;
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
