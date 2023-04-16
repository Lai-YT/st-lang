#include "symtab.h"

#include <stdlib.h>
#include <string.h>

#include "list.h"

struct symtab {
  list_t *entries;
};

static entry_t *entry_create(const char *name, enum type type) {
  entry_t *entry = malloc(sizeof(entry_t));
  strncpy(entry->name, name, MAX_NAME_LENGTH);
  entry->type = type;
  return entry;
}

static inline void entry_delete(entry_t *entry) {
  free(entry);
}

symtab_t *symtab_create() {
  symtab_t *table = malloc(sizeof(symtab_t));
  table->entries = NULL;
  return table;
}

entry_t *symtab_lookup(symtab_t *table, const char *name) {
  list_t *curr = table->entries;
  while (curr) {
    entry_t *entry = curr->val;
    if (strcmp(entry->name, name) == 0) {
      return entry;
    }
    curr = curr->rest;
  }
  return NULL;
}

entry_t *symtab_insert(symtab_t *table, const char *name, enum type type) {
  entry_t *entry;
  if ((entry = symtab_lookup(table, name))) {
    return entry;
  }
  entry = entry_create(name, type);
  table->entries = list_create(entry, table->entries);
  return entry;
}

list_t *symtab_dump(symtab_t *table) {
  return table->entries;
}

void symtab_delete(symtab_t *table) {
  list_t *curr = table->entries;
  while (curr) {
    list_t *tmp = curr;
    curr = curr->rest;
    entry_delete(tmp->val);
    free(tmp);
  }
}
