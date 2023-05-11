# Lib

## About

This folder contains the library codes used across the phases of the _sT_ compiler.

- [linked list](include/list.h)
- [hash table](include/hashtab.h)
- [symbol table](include/symtab.h)
- [scoped environment](include/scope.h)

## Running the tests

```
$ make tests
```

## Development

Run the tests with the symbols collected (`-g`) and fewer optimizations (`-O0`).

```
$ make tests BUILD_TYPE=Debug
```

Additionally, you need `ClangFormat` and `Clang-Tidy` as code formatter and linter.

- Code formatting

```
$ make fmt
```

- Naming conventions & bug-proneness checking

```
$ make tidy
```
