#include <stdio.h>

#include "handle_flags.h"
#include "scope.h"
#include "symtab.h"

// the symbol table used in the lexer
SymbolTable* symtab;

/// @brief The scoping environment used in the parser.
StEnvironment* env;

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
  env = st_create_environment();

  /* perform parsing */
  int parse_status = yyparse();

  st_delete_environment(env);
  symtab_delete(symtab);
  fclose(yyin);
  return parse_status;
}
