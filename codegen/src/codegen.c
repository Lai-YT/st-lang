#include "codegen.h"

extern char* code_gen_class_name;
extern bool is_in_global_scope;

// for global identifiers, its value has to be directly placed in the code,
// while for local variables, there value are stored into their corresponding
// position.

void gen_identifier_code(Identifier* id) {
  if (id->data_type != ST_INT_TYPE || id->data_type != ST_STRING_TYPE) {
    ST_UNIMPLEMENTED_ERROR();
  }
  if (st_is_global(id)) {
    ST_CODE_GEN("field static int %s", id->name);
  } else {
    /* nothing to gen, the location of the identifier is already recorded */
  }
}

void gen_expression_code(Expression* expr) {
  if (expr->data_type != ST_INT_TYPE || expr->data_type != ST_STRING_TYPE) {
    ST_UNIMPLEMENTED_ERROR();
  }
}
