#include "symtab.h"

#include <stdlib.h>
#include <string.h>  // strcpy

#include "hashtab.h"
#include "list.h"

struct SymbolTable {
  HashTable* entries;
};

static Entry* entry_create(const char* name, Type type) {
  Entry* entry = malloc(sizeof(Entry));
  strncpy(entry->name, name, MAX_NAME_LENGTH);
  entry->type = type;
  return entry;
}

static inline void entry_delete(Entry* entry) {
  free(entry);
}

SymbolTable* symtab_create() {
  SymbolTable* table = malloc(sizeof(SymbolTable));
  table->entries = hashtab_create();
  return table;
}

Entry* symtab_lookup(SymbolTable* table, const char* name) {
  return hashtab_search(table->entries, name);
}

Entry* symtab_insert(SymbolTable* table, const char* name, Type type) {
  Entry* entry;
  if ((entry = symtab_lookup(table, name))) {
    return entry;
  }
  entry = entry_create(name, type);
  hashtab_insert(table->entries, name, entry);
  return entry;
}

List* symtab_dump(SymbolTable* table) {
  // shallow copying the list
  List* dump = NULL;
  HASHTAB_ITR_FOR_EACH(table->entries, itr,
                       { dump = list_create(hashtab_itr_value(itr), dump); });
  return dump;
}

void symtab_delete(SymbolTable* table) {
  HASHTAB_ITR_FOR_EACH(table->entries, itr, {
    Entry* entry = hashtab_itr_value(itr);
    entry_delete(entry);
  });
  hashtab_delete(table->entries);
  free(table);
}

const char* type_to_str(Type type) {
  switch (type) {
    case NO_TYPE:
      return "NO_TYPE";
    case INT:
      return "INT";
    case STRING:
      return "STRING";
    case BOOLEAN:
      return "BOOLEAN";
    default:
      return "";
  }
}
