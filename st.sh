#!/usr/bin/env sh

set -e

usage() {
  echo "Usage: ${0} [-h] FILE"
  echo ""
  echo "Description:"
  echo "  runs the FILE, which is a sT program,"
  echo "  and outputs Java Assembly to .jasm and ByteCode to .class"
  echo ""
  echo "Options:"
  echo "  -h, --help     show this help message and exit"
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

in_file=
while [ $# -ne 0 ]; do
  case $1 in
  -h | --help)
    usage
    exit 0
    ;;
  -*)
    echo "unknown option: $1"
    usage
    exit 1
    ;;
  *)
    # multiple file is not allowed
    if [ -n "$in_file" ]; then
      usage
      exit 1
    fi
    in_file=$1
    ;;
  esac
  shift
done

# Syntax & Semantic checks
parser/build/Parser "$in_file"
# Generate assembly code
codegen/build/CodeGen "$in_file"

filename=$(basename "$in_file")
# Convert to bytecode
javaa/javaa "${filename%.*}.jasm" 1>/dev/null
# Run the program
java "${filename%.*}"
