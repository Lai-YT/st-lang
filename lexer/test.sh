#!/usr/bin/env sh

LEXER=./lexer
if ! command -v "$LEXER" >/dev/null 2>&1; then
    echo "${LEXER}: not found"
    exit 1
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

status=0
find tests/ -name '*.t' >tmp
while IFS= read -r file; do
    echo "--------Test using" "$file" "--------"
    filename=$(basename "$file" .t)
    ./lexer "$file" >out
    if diff "tests/expect_${filename}.txt" out -y --width=60 --suppress-common-lines; then
        echo "${GREEN}PASSED${NO_COLOR}"
    else
        echo "${RED}FAILED${NO_COLOR}"
        status=1
    fi
done <tmp
rm tmp out

echo "--------SUMMARIZE--------"
if [ "$status" -eq 0 ]; then
    echo "${GREEN}ALL TESTS PASSED${NO_COLOR}"
else
    echo "${RED}SOME TESTS FAILED${NO_COLOR}"
fi

exit $status
