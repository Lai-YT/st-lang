#include "handle_flags.h"

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>

char* input_filename;

void handle_flags(int argc, char* argv[]) {
  struct option options[] = {};

  int arg;
  while ((arg = getopt_long(argc, argv, "", options, NULL)) != -1) {
    switch (arg) {
      case 0:
        /* this option set a flag */
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
      "usage: %s FILE\n"
      "\n"
      "  FILE            The file to be compiled into .jasm code\n"
      "                  NOTE: is assumed to be syntactically & semantically\n"
      "                    correct, should already be checked by the Parser\n",
      prog);
}
