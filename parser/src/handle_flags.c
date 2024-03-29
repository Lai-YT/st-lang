#include "handle_flags.h"

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>

char* input_filename;
int allow_semantic_errors;
int scope_dump;

void handle_flags(int argc, char* argv[]) {
  struct option options[] = {
      {"debug", no_argument, 0, 'd'},
      {"dump", no_argument, &scope_dump, 1},
      {"allow-semantic-errors", no_argument, &allow_semantic_errors, 1},
  };

  int arg;
  while ((arg = getopt_long(argc, argv, "d", options, NULL)) != -1) {
    switch (arg) {
      case 0:
        /* this option set a flag */
        break;
      case 'd':
        yydebug = 1;
        break;
      default:
        usage(argv[0]);
        exit(EXIT_FAILURE);
    }
  }

  if (optind + 1 != argc) {
    usage(argv[0]);
    exit(EXIT_FAILURE);
  }

  input_filename = argv[optind];
}

void usage(const char* prog) {
  fprintf(
      stderr,
      "usage: %s [-d] FILE\n"
      "\n"
      "  FILE            The file to be syntactically and semantically "
      "analyzed\n"
      "\n"
      "Options:\n"
      "  -d, --debug     Prints the shifts and reduces\n"
      "  --dump          Prints the name of the identifiers when adding to\n"
      "                  and exiting from scope\n"
      "  --allow-semantic-errors\n"
      "                  Exits with 0 even has semantic errors\n"
      "                  (for collecting test coverage)\n",
      prog);
}
