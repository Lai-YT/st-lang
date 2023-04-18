#ifndef TEST_UTIL_H
#define TEST_UTIL_H

#include <stddef.h>

typedef void (*TestCase)();

int run_all_tests(TestCase cases[], size_t num_of_cases);

#endif /* end of include guard: TEST_UTIL_H */
