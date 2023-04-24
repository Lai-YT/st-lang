# _sT_ : A Simple _Turing_ Programming Language

## About

This project aims to implement a compiler for a simplified version of the _[Turing](https://en.wikipedia.org/wiki/Turing_(programming_language))_ programming language, which is [not fully compatible](#known-incompatibility).

It's split into 3 phases:
1. [Lexer](./lexer/)
2. Parser
3. Code generation: to _Java Bytecode_

## Getting Started

The tools and dependencies required for each phase are described in detail in their corresponding `README`s.

The common tools required across the phases include `gcc`, as the _sT_ compiler is written in _C_, as well as `make` and `cmake`, which generate the executables.
All tools required by the _sT_ compiler are packed into containers, which you can use to build or develop the compiler.

### Non-dev Container

We provide a Docker image that contains only the necessary tools for compiling the _sT_ compiler. "Non-Dev" indicates that the image doesn't include test tools, format tools, or other utilities.

The image can be built locally with the `Dockerfile`.

```
$ docker build --name st-lang .
```

Then, run a new container in interactive mode with a pseudo-TTY allocated. We've already specified the `/bin/sh` command in the image, so you can omit the command argument.

```
$ docker run -it st-lang
```
> Alternatively, use `docker run -it st-lang /bin/bash` to use the _Bourne again shell_ (_Bash_) instead of _Bourne shell_ (_sh_).

You're now inside the container. You should see a hashtag (`#`) waiting for your commands. Go play around!

### Dev Container

The dev container contains all the tools you'll need during the development, such as [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html), [Clang-Tidy](https://clang.llvm.org/extra/clang-tidy/) and [Valgrind](https://valgrind.org/).

The dev container works with [VSCode](https://code.visualstudio.com/). You'll need to install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.

After the installation, click the green status bar item at the far left and select `Reopen in container`. This will start building the image and then run a container for you.
> **Note**
> You'll need to click `Reopen in container` every time you want to enter the dev container. It will start the same container you previously ran.

You will then be taken into the container. Here you have all the tools you need, including some useful _VSCode_ extensions. Enjoy your journey!
> Learn more about [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers).

## Known Incompatibilities

> The definition of _incompatibility_ here is that the code using the syntax mentioned below compiled with the _sT_ compiler but does not compiled with the [tpc](https://txl.ca/txl-tplusdownload.html) compiler.

| syntax | _sT_ | _Turing_ |
|:-------|:----:|:--------:|
| block comment | `{% ... %}` | `/* ... */`
| escaped quote | `""` | `\"` |

## Resources

- [The lexical definition of sT](./lexer/lexical-definition.md)
- [The Turing Language Report](https://txl.ca/tplus/Turing_Report.pdf)

## License

The _sT_ compiler is licensed under the [MIT License](LICENSE).
