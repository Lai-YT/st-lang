# Errors

## Arrays

| code | description | example |
|:----:|:------------|:--------|
| ARR01 | lower bound of an 'array' must be determined at compile-time | [arr01.st](tests/bad/arr01.st) |
| ARR02 | lower/upper bound of an 'array' must have type 'int' | [arr02-1.st](tests/bad/arr02-1.st), [arr02-2.st](tests/bad/arr02-2.st) |
| ARR03 | type of an 'array' must be a 'static array' | [arr03.st](tests/bad/arr03.st) |
| ARR04 | lower bound of an 'array' must be positive | [arr04.st](tests/bad/arr04.st) |
| ARR05 | upper bound of a 'static array' must be positive | [arr05.st](tests/bad/arr05.st) |
| ARR06 | upper bound of a 'static array' must be greater than its lower bound | [arr06.st](tests/bad/arr06.st) |

## Constants

| code | description | example |
|:----:|:------------|:--------|
| CONST01 | a constant identifier cannot be a 'dynamic array' | [const01.st](tests/bad/const01.st) |
