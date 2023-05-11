#ifndef LIB_SCOPE_H
#define LIB_SCOPE_H

#include "symtab.h"

/// @brief An environment holds stack of scopes. Providing operations for
/// entering and exiting new scopes, or adding and looking up symbols from
/// scopes.
typedef struct Environment Environment;

/// @return An empty environment which does not enter any scope.
Environment* create_environment();

/// @brief Deletes the environment and all of the scopes.
void delete_environment(Environment*);

/// @brief Enters a new current scope.
void enter_scope(Environment**);

/// @brief Exits and deletes all the symbols from the current scope.
void exit_scope(Environment**);

/// @brief Looks for the symbol with name. Starting at the current scope and
/// proceeding through the entire environment until either the symbol is
/// found, or the end of the root scope is reached.
/// @return The symbol if such name exists in the environment, or NULL if not.
Symbol* lookup_environment(Environment*, const char* name);

/// @brief Looks for the symbol with name from the current scope.
/// @return The symbol if such name exists, or NULL if not.
Symbol* probe_environment(Environment*, const char* name);

/// @brief Adds an symbol with name to the current scope of the environment.
/// @return The inserted symbol.
/// @note Shadows the symbol with the same name in parent scopes.
Symbol* insert_scope(Environment*, const char* name);

#endif /* end of include guard: LIB_SCOPE_H */
