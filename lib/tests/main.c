#undef NDEBUG  // since our tests rely on assert, always turn it on

#include "test_list.h"
#include "test_scope.h"
#include "test_symtab.h"
#include "util.h"

int main() {
  TestCase cases[] = {
      test_list_length,
      test_list_length_on_empty_list,
      test_symtab_lookup_inserted_symbols,
      test_symtab_lookup_without_insert,
      test_symtab_dump_should_return_all_inserted_symbols,
      test_scope_insert_and_lookup,
      test_scope_lookup_from_inner_scope,
      test_scope_probe,
      test_scope_lookup_not_found,
      test_delete_environment_should_delete_all_scopes,
  };

  return run_all_tests(cases, sizeof cases / sizeof(TestCase));
}
