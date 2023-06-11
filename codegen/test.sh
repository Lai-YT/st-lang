#!/usr/bin/env sh

status=0
for expected in tests/output/*.out; do
  filename=$(basename "$expected")
  filename=${filename%.*}
  if ! (./compile.sh "tests/$filename.st" >/dev/null &&
    java "$filename" |
    diff "$expected" -); then
    echo "Fail tests/$filename.st"
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "Passed"
fi
exit $status
