#include "test_symtab.h"
#include "util.h"

int main() {
  TestCase cases[] = {
      test_symtab_lookup_inserted_symbols,
      test_symtab_lookup_without_insert,
      test_symtab_dump_should_return_all_inserted_entries,
  };

  return run_all_tests(cases, sizeof cases / sizeof(TestCase));
}
