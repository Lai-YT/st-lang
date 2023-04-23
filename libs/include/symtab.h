#ifndef SRC_SYMTAB_H
#define SRC_SYMTAB_H

#include "list.h"

#define MAX_NAME_LENGTH 255

typedef enum Type {
  NO_TYPE = 0,  // not yet determined
  INT = 1,
  STRING = 2,
  BOOLEAN = 3,
} Type;

const char* type_to_str(Type);

typedef struct Entry {
  char name[MAX_NAME_LENGTH + 1];  // terminate character
  Type type;
} Entry;

/// @brief A symbol table that supports insert and lookup.
typedef struct SymbolTable SymbolTable;

/// @return An empty symbol table.
SymbolTable* symtab_create();

/// @param name The name of the entry to lookup.
/// @return The entry with the specified name. NULL is not exist.
Entry* symtab_lookup(SymbolTable*, const char* name);

/// @brief Inserts a new entry with name and type if the name isn't already
/// exist.
/// @note Behaves like the symtab_lookup function when an entry with name
/// already exist.
/// @return The inserted entry.
Entry* symtab_insert(SymbolTable*, const char* name, Type);

/// @return All the entries in the table. The order is unspecified.
/// @note The ownership of the dumped list is taken by the caller, but the
/// entries are not. Call list_delete after inspection.
List* symtab_dump(SymbolTable*);

/// @brief Deletes the symbol table and all the entries in it.
void symtab_delete(SymbolTable*);

#endif /* end of include guard: SRC_SYMTAB_H */
