#include "handle_flags.h"

#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

char* input_filename;

void handle_flags(int argc, char* argv[]) {
  struct option options[] = {
      {"debug", no_argument, 0, 'd'},
  };

  int arg;
  while ((arg = getopt_long(argc, argv, "d", options, NULL)) != -1) {
    switch (arg) {
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
  fprintf(stderr,
          "usage: %s [-d] FILE\n"
          "\n"
          "  FILE            The file to be lexically analyzed\n"
          "\n"
          "Options:\n"
          "  -d, --debug     Prints the shifts and reduces\n",
          prog);
}
