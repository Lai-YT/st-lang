#!/usr/bin/env sh

status=0

# Bad tests, should exit with error message.
for file in tests/bad/*.st; do
  # Get the error message.
  ./build/Parser "${file}" 2>tmp
  # Every error message ends with it error code inside a pair of parenthsis,
  # so here we extract the string inside the parenthesis.
  sed <tmp -n 's/.*(\(.*\))$/\1/p' >code
  # Every bad test has the expected error code as the prefix of its name, extract it.
  echo "${file}" | sed -n 's/.*\/\(.*\)\..*$/\1/p' |
    # Some error code has several tests file, only get the error code itself, no test number ("-").
    # Muliple errors can be encoded into the filename with "_" as the separater.
    awk '{
      split($0, errs, "_");
      for (i in errs) {  # get errors
        split(errs[i], e, "-");
        print e[1];  # ignore test number
      }
    }' >expcode

  # Compare the actual error message and the expected error message.
  # Case of the letters are irrelevant.
  if ! diff -i code expcode; then
    echo "Fail ${file}"
    status=1
  fi
done
rm -f tmp code expcode

# Good tests, should exit without error
for file in tests/good/*.st; do
  if ! ./build/Parser "${file}"; then
    echo "Fail ${file}"
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "Passed"
fi
exit $status
