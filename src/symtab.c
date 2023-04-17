#include "symtab.h"

#include <stdlib.h>
#include <string.h>

#include "list.h"

struct SymbolTable {
  List *entries;
};

static Entry *entry_create(const char *name, Type type) {
  Entry *entry = malloc(sizeof(Entry));
  strncpy(entry->name, name, MAX_NAME_LENGTH);
  entry->type = type;
  return entry;
}

static inline void entry_delete(Entry *entry) {
  free(entry);
}

SymbolTable *symtab_create() {
  SymbolTable *table = malloc(sizeof(SymbolTable));
  table->entries = NULL;
  return table;
}

Entry *symtab_lookup(SymbolTable *table, const char *name) {
  List *curr = table->entries;
  while (curr) {
    Entry *entry = curr->val;
    if (strcmp(entry->name, name) == 0) {
      return entry;
    }
    curr = curr->rest;
  }
  return NULL;
}

Entry *symtab_insert(SymbolTable *table, const char *name, Type type) {
  Entry *entry;
  if ((entry = symtab_lookup(table, name))) {
    return entry;
  }
  entry = entry_create(name, type);
  table->entries = list_create(entry, table->entries);
  return entry;
}

List *symtab_dump(SymbolTable *table) {
  return table->entries;
}

void symtab_delete(SymbolTable *table) {
  List *curr = table->entries;
  while (curr) {
    List *tmp = curr;
    curr = curr->rest;
    entry_delete(tmp->val);
    free(tmp);
  }
}
