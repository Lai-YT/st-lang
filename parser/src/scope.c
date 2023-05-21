#include "scope.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include "symtab.h"

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
  return env;
}

void st_delete_environment(StEnvironment* env) {
  while (in_scope(env)) {
    StEnvironment* rest = env->rest;
    st_exit_scope(&env);
    env = rest;
  }
  free(env);
}

void st_enter_scope(StEnvironment** env) {
  StEnvironment* scope = malloc(sizeof(StEnvironment));
  scope->scope = symtab_create();
  scope->rest = *env;
  *env = scope;
}

void st_exit_scope(StEnvironment** env) {
  if (!in_scope(*env)) {
    fputs("no more scope to exit\n", stderr);
    exit(EXIT_FAILURE);
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
  return symtab_insert(env->scope, name, NULL);
}

List* st_dump_scope(StEnvironment* env) {
  if (!in_scope(env)) {
    fputs("no scope to dump\n", stderr);
    exit(EXIT_FAILURE);
  }
  return symtab_dump(env->scope);
}
