#!/usr/bin/env sh

run_valgrind() {
  valgrind \
    --track-origins=yes \
    --leak-check=full \
    --leak-resolution=high \
    --error-exitcode=1 \
    "$PARSER" --allow-semantic-errors "$1"
  return $?
}

for file in tests/good/*.st tests/bad/*.st; do
  echo "---"
  if ! run_valgrind "$file" >/dev/null 2>&1; then
    # rerun un-silently
    run_valgrind "$file"
    echo "Failed $file"
    exit 1
  else
    echo "Passed $file"
  fi
done

echo "---"
echo "All Passed!"
