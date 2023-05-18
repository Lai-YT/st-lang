#include "scope.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include "symtab.h"

struct Environment {
  SymbolTable* scope;
  struct Environment* rest;
};

static Environment* create_scope(Environment* rest) {
  Environment* scope = malloc(sizeof(Environment));
  scope->scope = symtab_create();
  scope->rest = rest;
  return scope;
}

static void delete_scope(Environment* env) {
  symtab_delete(env->scope);
  env->rest = NULL;
  free(env);
}

static bool in_scope(Environment* env) {
  return env->scope;
}

Environment* create_environment() {
  Environment* env = malloc(sizeof(Environment));
  env->scope = NULL;
  env->rest = NULL;
  return env;
}

void delete_environment(Environment* env) {
  while (in_scope(env)) {
    Environment* rest = env->rest;
    exit_scope(&env);
    env = rest;
  }
  free(env);
}

void enter_scope(Environment** env) {
  *env = create_scope(*env);
}

void exit_scope(Environment** env) {
  if (!in_scope(*env)) {
    fputs("no more scope to exit\n", stderr);
    exit(EXIT_FAILURE);
  }
  Environment* tmp = *env;
  *env = (*env)->rest;
  delete_scope(tmp);
}

Symbol* lookup_environment(Environment* env, const char* name) {
  if (!in_scope(env)) {
    fputs("enter a scope before looking up\n", stderr);
    exit(EXIT_FAILURE);
  }
  while (in_scope(env)) {
    Symbol* e = probe_environment(env, name);
    if (e) {
      return e;
    }
    env = env->rest;
  }
  return NULL;
}

Symbol* probe_environment(Environment* env, const char* name) {
  if (!in_scope(env)) {
    fputs("enter a scope before probing\n", stderr);
    exit(EXIT_FAILURE);
  }
  return symtab_lookup(env->scope, name) ?: NULL;
}

Symbol* insert_scope(Environment* env, const char* name) {
  if (!in_scope(env)) {
    fputs("enter a scope to insert symbol\n", stderr);
    exit(EXIT_FAILURE);
  }
  return symtab_insert(env->scope, name, NULL);
}

List* dump_scope(Environment* env) {
  if (!in_scope(env)) {
    fputs("no scope to dump\n", stderr);
    exit(EXIT_FAILURE);
  }
  return symtab_dump(env->scope);
}
