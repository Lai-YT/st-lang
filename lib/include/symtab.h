#ifndef LIB_SYMTAB_H
#define LIB_SYMTAB_H

#include "list.h"

#define MAX_NAME_LENGTH 255

typedef struct Symbol {
  char name[MAX_NAME_LENGTH + 1];  // terminate character
  void* attribute;
} Symbol;

/// @brief A symbol table that supports insert and lookup.
typedef struct SymbolTable SymbolTable;

/// @return An empty symbol table.
SymbolTable* symtab_create();

/// @param free_val a deleter that is called on each of the symbols in the table
/// when the being deleted with symtab_delete.
/// @return An empty symbol table that has a custom deleter.
SymbolTable* symtab_create_with_deleter(void (*free_val)(void*));

/// @param name The name of the symbol to lookup.
/// @return The symbol with the specified name. NULL if not exist.
Symbol* symtab_lookup(SymbolTable*, const char* name);

/// @brief Inserts a new symbol with the attribute if the name isn't already
/// exist.
/// @note Behaves like the symtab_lookup function when a symbol with name
/// already exist.
/// @return The inserted symbol.
Symbol* symtab_insert(SymbolTable*, const char* name, void* attribute);

/// @return All the symbols in the table. The order is unspecified.
/// @note The ownership of the dumped list is taken by the caller, but the
/// symbols are not. Call list_delete after inspection.
List* symtab_dump(SymbolTable*);

/// @brief Deletes the symbol table and all the symbols in it.
void symtab_delete(SymbolTable*);

#endif /* end of include guard: LIB_SYMTAB_H */
