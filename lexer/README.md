# Lexer

## About

The _Lexer_ is generated using [flex](https://github.com/westes/flex). The lexical patterns are defined according to the [lexical definition](./lexical-definition.md), located in [src/st.l](src/st.l).

## Getting Started

### Prerequisites

You need `gcc`, `make`, `cmake`, and `flex`.

### Build Steps

To compiler the _Lexer_, make sure you are under `{root}/lexer/`.

```shell
$ make
```

The executable will be located in the `build/` folder and named `Lexer`.

## Running the tests

The way we test the _Lexer_ is to compare its output, which is the tokens, to our expected output, and see whether they match.

```
$ make tests
```

## Usage

The _Lexer_ takes a file to parse. It prints out the tokens it recognized and optionally dumps the identifiers.

```
$ ./build/Lexer
usage: ./build/Lexer [-vd] FILE

  FILE            The file to be lexically analyzed

Options:
  -v, --verbose   Prints the tokens and their corresponding lines
  -d, --dump      Dumps the name of the identifiers
```

### Example

Assume we have a piece of code written in _sT_, named `triangle.t`. This piece of code prints a triangle with `*`.

```Turing
var s := "*"
loop
    put s
    exit when length(s) = 10
    s := s + "*"
end loop
```

Pass it to the _Lexer_ for lexical analysis. To see the tokens recognized, enable the verbose printing with `-v`.

```
$ ./build/Lexer -v triangle.t
<VAR>
<identifier:s>
<ASSIGN>
<string:*>
1: var s := "*" % implicitly declaring s to be of type string
<LOOP>
2: loop
<PUT>
<identifier:s>
3:     put s
4:     % by default, the maximum length of a string is 255 characters
<EXIT>
<WHEN>
<identifier:length>
<'('>
<identifier:s>
<')'>
<'='>
<integer:10>
5:     exit when length(s) = 10
<identifier:s>
<ASSIGN>
<identifier:s>
<'+'>
<string:*>
6:     s := s + "*"
<END>
<LOOP>
7: end loop
```

If the `-d` is set, extra dump messages follow the tokens.

```
$ ./build/Lexer -vd triangle.t
...

Symbol Table:
s
length
```

## Development

Run the _Lexer_ with the symbols collected (`-g`) and fewer optimizations (`-O0`).

```
$ make BUILD_TYPE=Debug
```

Similarly, run the tests,

```
$ make tests BUILD_TYPE=Debug
```

> The value of `BUILD_TYPE` is passed to `cmake` as `CMAKE_BUILD_TYPE` behind the scene, i.e., `cmake` is configured with `-DCMAKE_BUILD_TYPE=Debug`.

Additionally, you need `ClangFormat` and `Clang-Tidy` as code formatter and linter.

- Code formatting

```
$ make fmt
```

- Naming conventions & bug-proneness checking

```
$ make tidy
```
