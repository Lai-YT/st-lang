# Parser

## About

The _Parser_ is generated using [Bison](https://www.gnu.org/software/bison/manual/). The syntax and semantic constraints are defined and implemented according to the [syntactic and semantic definition](syntactic_and_semantic_definition.md), located in [src/st.y](src/st.y).

## Getting Started

### Prerequisites

You need `gcc`, `make`, `cmake`, and `bison`.

### Build Steps

To compiler the _Parser_, make sure you are under `{root}/parser/`.

```shell
$ make
```

The executable will be located in the `build/` folder and named `Parser`.

## Running the tests

To test the _Parser_, we input programs that contain various errors, each accompanied by an error code that appears alongside the error message.
Our objective is to verify the parser's accuracy in identifying and reporting errors. Additionally, we ensure that well-formed programs are parsed without encountering any errors.

```
$ make tests
```

## Usage

The _Parser_ takes a file to parse. It exits silently if the file is a valid _sT_ program.

```
$ ./build/Parser
usage: ./build/Parser [-d] FILE

  FILE            The file to be syntactically and semantically analyzed

Options:
  -d, --debug     Prints the shifts and reduces
  --allow-semantic-errors
                  Exits with 0 even has semantic errors
                  (for collecting test coverage)
```

### Example

Here's a piece of code written in _sT_, named `abs.t`. This piece of code consists of a `function` that returns the absolute value of an input integer and a `put` statement that calls the `function` to display the absolute value of `1.0`.

```Turing
function abs(n: int): int
  if n < 0 then
    result -n
  else
    result n
  end if
end abs

put abs(1.0)
```

This code contains two errors:
1. As per the syntax definition, a function must always end with a result statement.
2. The function abs expects an `int` as a parameter, but a `real` value is provided.

When running the parser with this code, the following error messages are generated:

```shell
$ ./build/Parser abs.t
abs.st:2:3: error: 'function' must ends with a 'result' statement (SUB02)
abs.st:9:9: error: type of the actual parameter cannot be assigned as type of the formal parameter (CALL03)
```

Each error message includes the location of the error, a description of the error, and its corresponding error code.
You can find a comprehensive list of all error codes in [errors.md](errors.md).

## Development

Run the _Parser_ with the symbols collected (`-g`) and fewer optimizations (`-O0`).

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

### Test Coverage

The _Parser_ ensures that all condition branches are executed by utilizing the code coverage tool [lcov](https://github.com/linux-test-project/lcov).

To generate the coverage report, run the following command:

```shell
$ make coverage
Open .coverage/index.html in your browser to view the coverage report.
```

The report will be displayed in HTML format and can be found in the `.coverage/` folder.
