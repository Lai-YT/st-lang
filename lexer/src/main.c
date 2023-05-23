#include <getopt.h>
#include <stdbool.h>
#include <stddef.h>  // NULL
#include <stdio.h>
#include <stdlib.h>

#include "handle_flags.h"
#include "list.h"
#include "st-lex.h"
#include "st-parse.h"
#include "symtab.h"

// the symbol table used in the lexer
SymbolTable* symtab;

/*
 * defined the followings variables here since the lexer is now not compiled
 * with the bison parser
 */
// the semantic value of the token
YYSTYPE yylval;
// the location data of the token, initialize to the beginning of the file
YYLTYPE yylloc = {1, 1, 1, 1};

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
  // free resource of lexer
  yylex_destroy();
  return 0;
}

void dump_symbols(SymbolTable* table) {
  puts("Symbol Table:");
  List* dump = symtab_dump(table);
  List* curr = dump;
  while (curr) {
    Symbol* symbol = curr->val;
    printf("%s\n", symbol->name);
    curr = curr->rest;
  }
  list_delete(dump);
}
