#include <stddef.h>

#include "test_symtab.h"

typedef void (*TestCase)();

int run_all_tests(TestCase cases[], size_t num_of_cases) {
  while (num_of_cases--) {
    cases[num_of_cases]();
  }
  return 0;
}

int main() {
  TestCase cases[] = {
      test_symtab_lookup_inserted_symbols,
      test_symtab_lookup_without_insert,
      test_symtab_dump_should_return_all_inserted_entries,
  };

  return run_all_tests(cases, sizeof cases / sizeof(TestCase));
}
