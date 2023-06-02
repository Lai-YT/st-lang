#!/usr/bin/env sh

# Exits 2 when there are memory errors.
run_valgrind() {
  # the lexer exit with 1 when there are lexical errors,
  # so we'll use another error code to distinguish them
  valgrind \
    --track-origins=yes \
    --leak-check=full \
    --leak-resolution=high \
    --error-exitcode=2 \
    "$LEXER" "$1"
  return $?
}

for file in tests/*.st; do
  echo "---"
  run_valgrind "$file" >/dev/null 2>&1
  if [ $? -eq 2 ]; then
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
