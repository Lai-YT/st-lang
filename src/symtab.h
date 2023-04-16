#ifndef SRC_SYMTAB_H
#define SRC_SYMTAB_H

#include "list.h"

#define MAX_NAME_LENGTH 255

enum type {
  INT = 1,
  STRING = 2,
  BOOLEAN = 3,
};

typedef struct entry {
  char name[MAX_NAME_LENGTH + 1];  // terminate character
  enum type type;
} entry_t;

/// @brief A symbol table that supports insert and lookup.
typedef struct symtab symtab_t;

/// @return An empty symbol table.
symtab_t *symtab_create();

/// @param name The name of the entry to lookup.
/// @return The entry with the specified name. NULL is not exist.
entry_t *symtab_lookup(symtab_t *, const char *name);

/// @brief Inserts a new entry with name and type if the name isn't already
/// exist.
/// @note Behaves like the symtab_lookup function when an entry with name
/// already exist.
/// @return The inserted entry.
entry_t *symtab_insert(symtab_t *, const char *name, enum type);

/// @return All the entries in the table. The order is unspecified.
list_t *symtab_dump(symtab_t *);

/// @brief Deletes the symbol table and all the entries in it.
void symtab_delete(symtab_t *);

#endif /* end of include guard: SRC_SYMTAB_H */
