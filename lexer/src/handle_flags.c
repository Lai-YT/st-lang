#include "handle_flags.h"

#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

bool verbose;
bool symbol_dump;
char* input_filename;

void handle_flags(int argc, char* argv[]) {
  struct option options[] = {
      {"dump", no_argument, 0, 'd'},
      {"verbose", no_argument, 0, 'v'},
  };

  int arg;
  while ((arg = getopt_long(argc, argv, "vd", options, NULL)) != -1) {
    switch (arg) {
      case 'v':
        verbose = true;
        break;
      case 'd':
        symbol_dump = true;
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
  fprintf(stderr,
          "usage: %s [-vd] FILE\n"
          "\n"
          "  FILE            The file to be lexically analyzed\n"
          "\n"
          "Options:\n"
          "  -v, --verbose   Prints the tokens and their corresponding lines\n"
          "  -d, --dump      Dumps the name of the identifiers\n",
          prog);
}
