#ifndef TESTS_TEST_SYMTAB_H
#define TESTS_TEST_SYMTAB_H

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
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

  Symbol* a = symtab_lookup(table, "a");
  Symbol* b = symtab_lookup(table, "b");
  Symbol* c = symtab_lookup(table, "c");

  assert(a);
  assert(b);
  assert(c);

  symtab_delete(table);
}

void test_symtab_lookup_without_insert() {
  SymbolTable* table = symtab_create();

  Symbol* unknown = symtab_lookup(table, "an unknown symbol");

  assert(unknown == NULL);

  symtab_delete(table);
}

void test_symtab_dump_should_return_all_inserted_symbols() {
  SymbolTable* table = symtab_create();

  struct {
    char* name;
    int val;
  } symbols[] = {{"a", 1}, {"b", 2}, {"c", 3}};

  symtab_insert(table, symbols[0].name, &symbols[0].val);
  symtab_insert(table, symbols[1].name, &symbols[1].val);
  symtab_insert(table, symbols[2].name, &symbols[2].val);

  List* symbol_dump = symtab_dump(table);

  // index 0, 1, and 2 corresponds to symbol[0], symbol[1], and symbol[2],
  // respectively
  bool found[3] = {0};
  List* curr = symbol_dump;
  for (int i = 0; i < 3; i++) {
    assert(symbol_dump);
    Symbol* symbol = curr->val;
    if (strcmp(symbol->name, symbols[0].name) == 0) {
      assert(!found[0]);
      found[0] = true;
      assert(*((int*)symbol->attribute) == symbols[0].val);
    } else if (strcmp(symbol->name, symbols[1].name) == 0) {
      assert(!found[1]);
      found[1] = true;
      assert(*((int*)symbol->attribute) == symbols[1].val);
    } else if (strcmp(symbol->name, symbols[2].name) == 0) {
      assert(!found[2]);
      found[2] = true;
      assert(*((int*)symbol->attribute) == symbols[2].val);
    } else {
      assert(false && "unknown symbol");
    }
    curr = curr->rest;
  }
  assert(curr == NULL);
  list_delete(symbol_dump);

  symtab_delete(table);
}

void deleter_test_delete_int(void* integer) {
  free((int*)integer);
}

/// @brief This is a test on memory leak, has to turn on valgrind or other
/// memory inspector.
void test_symtab_create_with_deleter_has_no_memory_leak() {
  SymbolTable* table = symtab_create_with_deleter(deleter_test_delete_int);

  struct {
    char* name;
    int* i;
  } symbols[3] = {{"a", NULL}, {"b", NULL}, {"c", NULL}};
  for (int i = 0; i < 3; ++i) {
    symbols[i].i = malloc(sizeof(int));
    *symbols[i].i = i;
  }

  for (int i = 0; i < 3; ++i) {
    symtab_insert(table, symbols[i].name, symbols[i].i);
  }

  symtab_delete(table);
}

#endif /* end of include guard: TESTS_TEST_SYMTAB_H */
