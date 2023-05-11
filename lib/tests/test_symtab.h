#ifndef TESTS_TEST_SYMTAB_H
#define TESTS_TEST_SYMTAB_H

#include <assert.h>
#include <stdbool.h>
#include <string.h>

#include "list.h"
#include "symtab.h"

void test_symtab_lookup_inserted_symbols() {
  SymbolTable* table = symtab_create();

  struct {
    char* name;
    int val;
  } symbols[] = {{"a", 1}, {"b", 2}, {"c", 3}};

  symtab_insert(table, symbols[0].name, &symbols[0].val);
  symtab_insert(table, symbols[1].name, &symbols[1].val);
  symtab_insert(table, symbols[2].name, &symbols[2].val);

  Entry* a = symtab_lookup(table, "a");
  Entry* b = symtab_lookup(table, "b");
  Entry* c = symtab_lookup(table, "c");

  assert(a);
  assert(b);
  assert(c);

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

  struct {
    char* name;
    int val;
  } symbols[] = {{"a", 1}, {"b", 2}, {"c", 3}};

  symtab_insert(table, symbols[0].name, &symbols[0].val);
  symtab_insert(table, symbols[1].name, &symbols[1].val);
  symtab_insert(table, symbols[2].name, &symbols[2].val);

  List* entry_dump = symtab_dump(table);

  // index 0, 1, and 2 corresponds to symbol[0], symbol[1], and symbol[2],
  // respectively
  bool found[3] = {0};
  List* curr = entry_dump;
  for (int i = 0; i < 3; i++) {
    assert(entry_dump);
    Entry* entry = curr->val;
    if (strcmp(entry->name, symbols[0].name) == 0) {
      assert(!found[0]);
      found[0] = true;
      assert(*((int*)entry->attribute) == symbols[0].val);
    } else if (strcmp(entry->name, symbols[1].name) == 0) {
      assert(!found[1]);
      found[1] = true;
      assert(*((int*)entry->attribute) == symbols[1].val);
    } else if (strcmp(entry->name, symbols[2].name) == 0) {
      assert(!found[2]);
      found[2] = true;
      assert(*((int*)entry->attribute) == symbols[2].val);
    } else {
      assert(false && "unknown symbol");
    }
    curr = curr->rest;
  }
  assert(curr == NULL);
  list_delete(entry_dump);

  symtab_delete(table);
}

#endif /* end of include guard: TESTS_TEST_SYMTAB_H */
