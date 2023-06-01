#include <libgen.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "handle_flags.h"
#include "scope.h"
#include "st-lex.h"
#include "symtab.h"

// the symbol table used in the lexer
SymbolTable* symtab;

/// @brief The scoping environment used in the parser.
StEnvironment* env;

/*
 * These flags are used by the parser, disable when generating code.
 */
int allow_semantic_errors = 0;
int scope_dump = 0;

/// @brief Where the generated jasm code goes to.
FILE* st_codegen_out;
/// @brief The name of the generated jasm code.
char* output_filename;
char* input_filename_stem;
/// @brief Tells the parser that we should now generate code along with the
/// parsing.
bool gen_code = true;

extern FILE* yyin;
extern int yyparse();

static char* get_stem(const char* filename);

int main(int argc, char* argv[]) {
  handle_flags(argc, argv);

  /* open the source program file */
  yyin = fopen(input_filename, "r");
  if (!yyin) {
    fprintf(stderr, "error: could not open input file %s\n", argv[1]);
    return 1;
  }

  input_filename_stem = get_stem(basename(input_filename));
  const char* jasm_ext = ".jasm";
  output_filename
      = malloc(sizeof(char) * (strlen(input_filename) + strlen(jasm_ext) + 1));
  strcpy(output_filename, input_filename_stem);
  strcat(output_filename, jasm_ext);
  if (gen_code) {
    st_codegen_out = fopen(output_filename, "w");
    if (!st_codegen_out) {
      fprintf(stderr, "error: could not open output file %s\n",
              output_filename);
      return 1;
    }
  }

  symtab = symtab_create();
  env = st_create_environment();

  /* perform parsing */
  int parse_status = yyparse();

  st_delete_environment(env);
  symtab_delete(symtab);
  fclose(yyin);
  if (gen_code) {
    fclose(st_codegen_out);
  }
  free(output_filename);
  free(input_filename_stem);

  /* free resource of lexer */
  yylex_destroy();
  return parse_status;
}

static char* get_stem(const char* filename) {
  int stem_len = (int)strlen(filename);
  while (stem_len >= 0 && filename[stem_len] != '.') {
    --stem_len;
  }
  if (filename[stem_len] != '.') {
    // no extension, restore the length
    stem_len = (int)strlen(filename);
  }
  char* stem = malloc(sizeof(char) * (stem_len + 1));
  strncpy(stem, filename, stem_len);
  stem[stem_len] = '\0';
  return stem;
}
