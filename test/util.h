#ifndef TEST_UTIL_H
#define TEST_UTIL_H

#include <stddef.h>

/// @brief A test case should take no arguments and has no return value.
typedef void (*TestCase)();

/// @return 0 if all tests passed with out aborting error, 1 otherwise.
int run_all_tests(TestCase cases[], size_t num_of_cases);

#endif /* end of include guard: TEST_UTIL_H */
