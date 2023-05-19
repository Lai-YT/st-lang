#ifndef PARSER_SCOPE_H
#define PARSER_SCOPE_H

#include "list.h"
#include "symtab.h"

/// @brief An environment holds stack of scopes. Providing operations for
/// entering and exiting new scopes, or adding and looking up symbols from
/// scopes.
typedef struct StEnvironment StEnvironment;

/// @return An empty environment which does not enter any scope.
StEnvironment* st_create_environment();

/// @brief Exits all of the scopes and deletes the environment.
void st_delete_environment(StEnvironment*);

/// @brief Enters a new current scope.
void st_enter_scope(StEnvironment**);

/// @brief Exits and deletes all the symbols from the current scope.
void st_exit_scope(StEnvironment**);

/// @brief Looks for the symbol with name. Starting at the current scope and
/// proceeding through the entire environment until either the symbol is
/// found, or the end of the root scope is reached.
/// @return The symbol if such name exists in the environment, or NULL if not.
Symbol* st_lookup_environment(StEnvironment*, const char* name);

/// @brief Looks for the symbol with name from the current scope.
/// @return The symbol if such name exists, or NULL if not.
Symbol* st_probe_environment(StEnvironment*, const char* name);

/// @brief Adds an symbol with name to the current scope of the environment.
/// @return The inserted symbol.
/// @note Shadows the symbol with the same name in parent scopes.
Symbol* st_add_to_scope(StEnvironment*, const char* name);

/// @return All the symbols in the current scope. The order is unspecified.
/// @note The ownership of the dumped list is taken by the caller, but the
/// symbols are not. Call list_delete after inspection.
List* st_dump_scope(StEnvironment*);

#endif /* end of include guard: PARSER_SCOPE_H */
