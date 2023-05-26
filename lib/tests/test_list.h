#ifndef TESTS_TEST_LIST_H
#define TESTS_TEST_LIST_H

#include <assert.h>
#include <stddef.h>

#include "list.h"

void test_list_length_on_empty_list() {
  List* list = NULL;

  int length = list_length(list);

  assert(length == 0);

  list_delete(list);
}

void test_list_length() {
  int expect_length = 3;
  int values[3] = {0, 0, 0};

  List* list = list_create(&values[0], NULL);
  list = list_create(&values[1], list);
  list = list_create(&values[2], list);

  int length = list_length(list);

  assert(length == expect_length);

  list_delete(list);
}

#endif /* end of include guard: TESTS_TEST_LIST_H */
