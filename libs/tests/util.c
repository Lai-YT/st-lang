#define _GNU_SOURCE  // NOLINT: for action handling with sigaction

#include "util.h"

#include <setjmp.h>
#include <signal.h>
#include <stddef.h>
#include <stdio.h>

static jmp_buf env;

static void signal_handler(int signum) {
  if (signum == SIGABRT) {
    // resume from the abort signal
    longjmp(env, SIGABRT);
  }
}

int run_all_tests(TestCase cases[], size_t num_of_cases) {
  struct sigaction act = {.sa_handler = signal_handler, .sa_flags = 0};
  sigemptyset(&act.sa_mask);  // block other signals when one is handling
  sigaction(SIGABRT, &act, NULL);

  int num_of_errors = 0;
  for (size_t i = 0; i < num_of_cases; i++) {
    cases[i]();  // execute the test case
    if (setjmp(env) == SIGABRT) {
      num_of_errors++;
    }
  }

  // restore to default handler
  act.sa_handler = SIG_DFL;
  sigaction(SIGABRT, &act, NULL);

  printf("%ld tests ran.\n", num_of_cases);
  printf("%d tests failed.\n", num_of_errors);
  return num_of_errors ? 1 : 0;
}
