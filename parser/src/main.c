#include <stdio.h>

#include "symtab.h"

// the symbol table used in the lexer
SymbolTable* symtab;

extern FILE* yyin;
extern int yyparse();

int main(int argc, char* argv[]) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s FILE\n", argv[0]);
    return 1;
  }

  /* open the source program file */
  yyin = fopen(argv[1], "r"); /* open input file */
  if (!yyin) {
    fprintf(stderr, "error: could not open input file %s\n", argv[1]);
    return 1;
  }

  symtab = symtab_create();

  /* perform parsing */
  if (yyparse() != 0) {                 /* parsing */
    fprintf(stderr, "Parsing error !"); /* syntax error */
    return 1;
  }
  symtab_delete(symtab);
  fclose(yyin);
  return 0;
}
