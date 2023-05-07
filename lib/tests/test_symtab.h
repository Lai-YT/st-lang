#ifndef TEST_TEST_SYMTAB_H
#define TEST_TEST_SYMTAB_H

#include <assert.h>
#include <stdbool.h>
#include <string.h>

#include "list.h"
#include "symtab.h"

void test_symtab_lookup_inserted_symbols() {
  SymbolTable* table = symtab_create();

  symtab_insert(table, "a", INT_TYPE);
  symtab_insert(table, "b", STRING_TYPE);
  symtab_insert(table, "c", BOOLEAN_TYPE);

  Entry* a = symtab_lookup(table, "a");
  Entry* b = symtab_lookup(table, "b");
  Entry* c = symtab_lookup(table, "c");

  assert(a);
  assert(a->type == INT_TYPE);
  assert(b);
  assert(b->type == STRING_TYPE);
  assert(c);
  assert(c->type == BOOLEAN_TYPE);

  symtab_delete(table);
}

void test_symtab_lookup_without_insert() {
  SymbolTable* table = symtab_create();

  Entry* unknown = symtab_lookup(table, "an unknown symbol");

  assert(unknown == NULL);

  symtab_delete(table);
}

void test_symtab_dump_should_return_all_inserted_entries() {
  SymbolTable* table = symtab_create();

  symtab_insert(table, "a", INT_TYPE);
  symtab_insert(table, "b", STRING_TYPE);
  symtab_insert(table, "c", BOOLEAN_TYPE);

  List* entry_dump = symtab_dump(table);

  // index 0, 1, and 2 corresponds to a, b, and c, respectively
  bool found[3] = {0};
  List* curr = entry_dump;
  for (int i = 0; i < 3; i++) {
    assert(entry_dump);
    Entry* entry = curr->val;
    if (strcmp(entry->name, "a") == 0) {
      assert(!found[0]);
      found[0] = true;
      entry->type = INT_TYPE;
    } else if (strcmp(entry->name, "b") == 0) {
      assert(!found[1]);
      found[1] = true;
      entry->type = STRING_TYPE;
    } else if (strcmp(entry->name, "c") == 0) {
      assert(!found[2]);
      found[2] = true;
      entry->type = BOOLEAN_TYPE;
    } else {
      // unknown symbol
      assert(false);
    }
    curr = curr->rest;
  }
  assert(curr == NULL);
  list_delete(entry_dump);

  symtab_delete(table);
}

#endif /* end of include guard: TEST_TEST_SYMTAB_H */