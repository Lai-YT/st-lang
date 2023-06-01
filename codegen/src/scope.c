#include "scope.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include "semant.h"
#include "symtab.h"

extern int scope_dump;

/// @brief For pretty printing the dumped identifiers with indentions.
static char* indentions = NULL;
static const int MAX_INDENTION_DEPTH = 1000;

struct StEnvironment {
  SymbolTable* scope;
  struct StEnvironment* rest;
};

static void delete_scope(StEnvironment* env) {
  symtab_delete(env->scope);
  env->rest = NULL;
  free(env);
}

static bool in_scope(StEnvironment* env) {
  return env->scope;
}

StEnvironment* st_create_environment() {
  StEnvironment* env = malloc(sizeof(StEnvironment));
  env->scope = NULL;
  env->rest = NULL;
  if (scope_dump) {
    indentions = malloc(sizeof(char) * (MAX_INDENTION_DEPTH + 1));
    indentions[0] = '\0';
  }
  return env;
}

void st_delete_environment(StEnvironment* env) {
  while (in_scope(env)) {
    StEnvironment* rest = env->rest;
    st_exit_scope(&env);
    env = rest;
  }
  free(env);

  if (scope_dump) {
    free(indentions);
    indentions = NULL;
  }
}

void st_enter_scope(StEnvironment** env) {
  StEnvironment* scope = malloc(sizeof(StEnvironment));
  scope->scope
      = symtab_create_with_deleter((void (*)(void*))st_free_identifier);
  scope->rest = *env;
  *env = scope;
  if (scope_dump) {
    strcat(indentions, "  " /* 2-space */);
  }
}

void st_exit_scope(StEnvironment** env) {
  if (!in_scope(*env)) {
    fputs("no more scope to exit\n", stderr);
    exit(EXIT_FAILURE);
  }
  if (scope_dump) {
    List* dumps = st_dump_scope(*env);
    List* curr = dumps;
    while (curr) {
      if (curr->val) {
        Symbol* symbol = curr->val;
        fprintf(stderr, "%s-: %s\n", indentions, symbol->name);
      }
      curr = curr->rest;
    }
    list_delete(dumps);
    if (scope_dump) {
      indentions[strlen(indentions) - 2] = '\0';
    }
  }
  StEnvironment* tmp = *env;
  *env = (*env)->rest;
  delete_scope(tmp);
}

Symbol* st_lookup_environment(StEnvironment* env, const char* name) {
  if (!in_scope(env)) {
    fputs("enter a scope before looking up\n", stderr);
    exit(EXIT_FAILURE);
  }
  while (in_scope(env)) {
    Symbol* e = st_probe_environment(env, name);
    if (e) {
      return e;
    }
    env = env->rest;
  }
  return NULL;
}

Symbol* st_probe_environment(StEnvironment* env, const char* name) {
  if (!in_scope(env)) {
    fputs("enter a scope before probing\n", stderr);
    exit(EXIT_FAILURE);
  }
  return symtab_lookup(env->scope, name) ?: NULL;
}

Symbol* st_add_to_scope(StEnvironment* env, const char* name) {
  if (!in_scope(env)) {
    fputs("enter a scope to add symbol\n", stderr);
    exit(EXIT_FAILURE);
  }
  if (scope_dump) {
    fprintf(stderr, "%s+: %s\n", indentions, name);
  }
  return symtab_insert(env->scope, name, NULL);
}

List* st_dump_scope(StEnvironment* env) {
  if (!in_scope(env)) {
    fputs("no scope to dump\n", stderr);
    exit(EXIT_FAILURE);
  }
  return symtab_dump(env->scope);
}
