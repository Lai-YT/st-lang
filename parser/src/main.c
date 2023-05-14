#include <stdio.h>

#include "handle_flags.h"
#include "symtab.h"

// the symbol table used in the lexer
SymbolTable* symtab;

/// @brief The scope environment used in the parser.
/// @note Start with a single scope.
SymbolTable* scope;

extern FILE* yyin;
extern int yyparse();

int main(int argc, char* argv[]) {
  handle_flags(argc, argv);

  /* open the source program file */
  yyin = fopen(input_filename, "r"); /* open input file */
  if (!yyin) {
    fprintf(stderr, "error: could not open input file %s\n", argv[1]);
    return 1;
  }

  symtab = symtab_create();
  scope = symtab_create();

  /* perform parsing */
  if (yyparse() != 0) {                 /* parsing */
    fprintf(stderr, "Parsing error !"); /* syntax error */
    return 1;
  }
  symtab_delete(symtab);
  fclose(yyin);
  return 0;
}
