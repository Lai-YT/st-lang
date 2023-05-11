#ifndef TESTS_TEST_SCOPE_H
#define TESTS_TEST_SCOPE_H

#include <assert.h>

#include "scope.h"

void test_scope_insert_and_lookup() {
  Environment* env = create_environment();
  enter_scope(&env);

  insert_scope(env, "a");

  assert(lookup_environment(env, "a"));

  exit_scope(&env);
  delete_environment(env);
}

void test_scope_lookup_from_inner_scope() {
  Environment* env = create_environment();
  enter_scope(&env);
  insert_scope(env, "a");

  enter_scope(&env);  // enters an inner scope

  assert(lookup_environment(env, "a"));

  enter_scope(&env);
  exit_scope(&env);
  delete_environment(env);
}

void test_scope_probe() {
  Environment* env = create_environment();

  {
    enter_scope(&env);
    insert_scope(env, "a");

    assert(probe_environment(env, "a"));

    {
      enter_scope(&env);

      assert(!probe_environment(env, "a"));

      exit_scope(&env);
    }
    exit_scope(&env);
  }

  delete_environment(env);
}

void test_scope_lookup_not_found() {
  Environment* env = create_environment();
  enter_scope(&env);
  enter_scope(&env);

  assert(!lookup_environment(env, "a"));

  exit_scope(&env);
  enter_scope(&env);
  delete_environment(env);
}

/// @note This test needs memory check, run with Valgrind.
void test_delete_environment_should_delete_all_scopes() {
  Environment* env = create_environment();
  enter_scope(&env);
  enter_scope(&env);

  // Should rewind and delete scopes.
  delete_environment(env);
}

#endif /* end of include guard: TESTS_TEST_SCOPE_H */
