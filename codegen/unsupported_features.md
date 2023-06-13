# Unsupported Features

- No declaration or use of `array`s
- No declaration or use of `real`s
- No `string` variables. Only compile-time constants and string literals, which are provided for use in `put` statements
- No `get` statements
- No run-time initial expression on global declarations. \
For instance,
  ```turing
  var a := 0
  var b := a  % unsupported

  put b
  ```
