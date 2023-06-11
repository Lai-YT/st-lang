#!/usr/bin/env sh

CODEGEN=${CODEGEN:-./build/CodeGen}
if ! command -v "$CODEGEN" >/dev/null 2>&1; then
    echo "${CODEGEN}: not found"
    exit 1
fi

filename=$(basename "$1")
"$CODEGEN" "$1" && ../javaa/javaa "${filename%.*}.jasm"
