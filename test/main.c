#include <stddef.h>

#include "test_symtab.h"

typedef void (*test_case_t)();

int run_all_tests(test_case_t cases[], size_t num_of_cases) {
  while (num_of_cases--) {
    cases[num_of_cases]();
  }
  return 0;
}

int main() {
  test_case_t cases[] = {
      test_symtab_lookup_inserted_symbols,
      test_symtab_lookup_without_insert,
      test_symtab_dump_should_return_all_inserted_entries,
  };

  return run_all_tests(cases, sizeof cases / sizeof(test_case_t));
}
