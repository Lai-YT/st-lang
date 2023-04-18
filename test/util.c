#define _GNU_SOURCE  // NOLINT: for action handling with sigaction

#include "util.h"

#include <setjmp.h>
#include <signal.h>
#include <stdbool.h>
#include <stddef.h>

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

  bool has_error = false;
  while (num_of_cases--) {
    cases[num_of_cases]();  // execute the test case
    if (setjmp(env) == SIGABRT) {
      has_error = true;
    }
  }

  // restore to default handler
  act.sa_handler = SIG_DFL;
  sigaction(SIGABRT, &act, NULL);

  return has_error ? 1 : 0;
}
