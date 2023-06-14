#include "symtab.h"

#include <stdlib.h>
#include <string.h>  // strcpy

#include "hashtab.h"
#include "list.h"

struct SymbolTable {
  HashTable* symbols;
  ///@brief a customize deleter for the values of the symbol
  void (*free_val)(void*);
};

static Symbol* symbol_create(const char* name, void* attribute) {
  Symbol* symbol = malloc(sizeof(Symbol));
  strncpy(symbol->name, name, MAX_NAME_LENGTH);
  symbol->attribute = attribute;
  return symbol;
}

SymbolTable* symtab_create() {
  SymbolTable* table = malloc(sizeof(SymbolTable));
  table->symbols = hashtab_create();
  table->free_val = NULL;
  return table;
}

SymbolTable* symtab_create_with_deleter(void (*free_val)(void*)) {
  SymbolTable* table = symtab_create();
  table->free_val = free_val;
  return table;
}

Symbol* symtab_lookup(SymbolTable* table, const char* name) {
  return hashtab_search(table->symbols, name);
}

Symbol* symtab_insert(SymbolTable* table, const char* name, void* attribute) {
  Symbol* symbol;
  if ((symbol = symtab_lookup(table, name))) {
    return symbol;
  }
  symbol = symbol_create(name, attribute);
  hashtab_insert(table->symbols, name, symbol);
  return symbol;
}

List* symtab_dump(SymbolTable* table) {
  // shallow copying the list
  List* dump = NULL;
  HASHTAB_ITR_FOR_EACH(table->symbols, itr,
                       { dump = list_create(hashtab_itr_value(itr), dump); });
  return dump;
}

void symtab_delete(SymbolTable* table) {
  HASHTAB_ITR_FOR_EACH(table->symbols, itr, {
    Symbol* symbol = hashtab_itr_value(itr);
    if (table->free_val && symbol->attribute) {
      table->free_val(symbol->attribute);
    }
    free(symbol);
  });
  hashtab_delete(table->symbols);
  free(table);
}
