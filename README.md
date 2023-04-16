# _sT_ : A Simple _Turing_ Programming Language

## About

This project is to implement a compiler for a simplified _[Turing](https://en.wikipedia.org/wiki/Turing_(programming_language))_ programming language, which is [not fully compatible](#known-incompatibility).

It's split into 3 phases:
1. [Lexer & The symbol table](./lexer/)
2. Parser & Type checking
3. Code generation (to _Java_ Bytecode)

## Known incompatibilities

> The definition of _incompatibility_ here is that the code using the syntax mentioned below compiled with the _sT_ compiler but does not compiled with the [tpc](https://txl.ca/txl-tplusdownload.html) compiler.

| syntax | _sT_ | _Turing_ |
|:-------|:----:|:--------:|
| block comment | `{% ... %}` | `/* ... */`
| escaped quote | `""` | `\"` |

## Resources

- [The lexical definition of sT](./lexer/st-lexical-definition.pdf)
- [The Turing Language Report](https://txl.ca/tplus/Turing_Report.pdf)
