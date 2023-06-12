# CodeGen

## About

The _CodeGen_ is generated using [Bison](https://www.gnu.org/software/bison/manual/). It assumes that the input file for code generation is syntactically and semantically correct. You can check it with the *[Parser](../parser/)*. \
While not all _sT_ features are supported, you can check the [unsupported feature](unsupported_features.md) for more information.

## Getting Started

### Prerequisites

To use _CodeGen_, you need the following dependencies installed:

- `gcc`
- `make`
- `cmake`
- `bison`
- `g++`: to compile *[javaa](../javaa/)*, the _Java_ Assembler, which is a third party tool.
- `openjdk-8-jre-headless` or another _Java 8_ environment.

> The _CodeGen_ generates _Java Assembly_ (`.jasm`), and _javaa_ converts it into _Java ByteCode_ (`.class`).
> The resulting _Java ByteCode_ can be executed under a _Java 8_ environment; other versions may not work.

### Build Steps

To compile _CodeGen_, navigate to `{root}/codegen/` and run the following command.

```
$ make
```

> **Note**
> Before compiling _CodeGen_, you need to generate the `st-lex.h` file of the lexer.
> ```
> $ make -C ../lexer
> ```

The executable will be located in the `build/` folder and named `CodeGen`.

## Running the tests

To test the _CodeGen_, you first need to compile the _Parser_.
```
$ make -C ../parser
```

The _Parser_ is required to perform syntax and semantic checks. _CodeGen_ assumes that everything is correct.

Then, you can run the tests. The _javaa_ tool will be compiled automatically.

```
$ make tests
```

## Usage

_CodeGen_ takes a file as input for code generation. \
If the file is a valid _sT_ program and no unsupported feature are used, it will exit silently and generate a `.jasm` assembly code file.

```
$ ./build/CodeGen
usage: ./build/CodeGen FILE

  FILE            The file to be compiled into .jasm code
                  NOTE: is assumed to be syntactically & semantically
                    correct, should already be checked by the Parser
```

### Example

Here's a piece of code written in _sT_, named `abs.t`. This piece of code consists of a `function` that returns the absolute value of an input integer and a `put` statement that calls the `function` to display the absolute value of `-1`.

```turing
function abs(n: int): int
  if n < 0 then
    result -n
  end if
    result n
end abs

put abs(-1)
```

To convert the _sT_ file into _Java Assembly_, use the following command.

```
$ ./build/CodeGen abs.st
```

You'll then see a file named `abs.jasm` in the currently directory.
The file content may be similar to the following (the content may vary between versions but should provide the same functionality).

```
class abs {

/* 1: function abs(n: int): int */
    method public static int abs(int)
    max_stack 15
    max_locals 15
    {
/* 2:   if n < 0 then */
      iload 0
      sipush 0
      isub
      iflt Ltrue0
      iconst_0
      goto Lend1
      Ltrue0:
      iconst_1
      Lend1:
      ifeq Lfalse2
/* 3:     result -n */
        iload 0
        ineg
        ireturn
/* 4:   end if */
      Lfalse2:
/* 5:     result n */
      iload 0
      ireturn
/* 6: end abs */
    }

  method public static void main(java.lang.String[])
  max_stack 15
  max_locals 15
  {
/* 8: put abs(-1) */
    getstatic java.io.PrintStream java.lang.System.out
    sipush -1
    invokestatic int abs.abs(int)
    invokevirtual void java.io.PrintStream.print(int)
    /* newline */
    getstatic java.io.PrintStream java.lang.System.out
    invokevirtual void java.io.PrintStream.println()
    return
  }
}
```

If you want to further convert it into _Java ByteCode_, pass the `.jasm` to _javaa_.

```
$ ../javaa/javaa abs.jasm
```

Additionally, there's a convenient compile script called `compile.sh` that calls the _Parser_, _CodeGen_, and _javaa_ together for you.

```
$ chmod +x compile.sh
$ compile.sh abs.jasm
```

> **Note**
> Make sure that _javaa_ is already compiled with `$ make -C ../javaa`.

You should then see a `abs.class` file, which is the executable _Java ByteCode_.

```
$ java abs
1
```

## Development

Run the _CodeGen_ with the symbols collected (`-g`) and fewer optimizations (`-O0`).

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

Memory checks can be done with `Valgrind`.

```
$ make valgrind
```

### Test Coverage

The _CodeGen_ ensures that all condition branches are executed by utilizing the code coverage tool [lcov](https://github.com/linux-test-project/lcov).

To generate the coverage report, run the following command:

```
$ make coverage
Open .coverage/index.html in your browser to view the coverage report.
```

The report will be displayed in HTML format and can be found in the `.coverage/` folder.
