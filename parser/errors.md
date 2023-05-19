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
| CONST01 | a constant identifier cannot be a 'dynamic array' | [const01-1.st](tests/bad/const01-1.st), [const01-2.st](tests/bad/const01-2.st) |
| CONST02 | re-assignment on constant reference | [const02-1.st](tests/bad/const02-1.st), [const02-2.st](tests/bad/const02-2.st) |

## Declarations

| code | description | example |
|:----:|:------------|:--------|
| DECL01 | re-declaration of identifier 'x' | [decl01-1.st](tests/bad/decl01-1.st), [decl01-2.st](tests/bad/decl01-2.st), [decl01-3.st](tests/bad/decl01-3.st) |
| DECL02 | identifier 'x' is not declared | [decl02.st](tests/bad/decl02.st) |

## For Statements

| code | description | example |
|:----:|:------------|:--------|
| FOR01 | range of a 'for' statement must have type 'int' | [for01-1.st](tests/bad/for01-1.st), [for01-2.st](tests/bad/for01-2.st), [for01-2.st](tests/bad/for01-2.st), [for01-4.st](tests/bad/for01-4.st), [for01-5.st](tests/bad/for01-5.st), [for01-6.st](tests/bad/for01-6.st), [for01-7.st](tests/bad/for01-7.st), [for01-8.st](tests/bad/for01-8.st) |

## References

| code | description | example |
|:----:|:------------|:--------|
| REF01 | identifier 'x' is not declared | [ref01-1.st](tests/bad/ref01-1.st), [ref01-2.st](tests/bad/ref01-2.st) |
| REF02 | identifier 'x' is a 'subprogram', cannot be used as reference | [ref02-1.st](tests/bad/ref02-1.st), [ref02-2.st](tests/bad/ref02-2.st) |
| REF03 | 'character' is unsubscriptable, for substrings, use 'x[n .. m]' instead | [ref03-1.st](tests/bad/ref03-1.st), [ref03-2.st](tests/bad/ref03-2.st) |
| REF04 | identifier 'x' has unsubscriptable type | [ref04-1.st](tests/bad/ref04-1.st), [ref04-2.st](tests/bad/ref04-2.st), [ref04-3.st](tests/bad/ref04-3.st) |
| REF05 | 'n'-dimensional 'array' cannot have 'm' subscripts | [ref05-1.st](tests/bad/ref05-1.st), [ref05-1.st](tests/bad/ref05-1.st) |
| REF06 | subscript must have type 'int' | [ref06.st](tests/bad/ref06.st) |

## Statements

| code | description | example |
|:----:|:------------|:--------|
| STMT01 | 'return' statement can only appear in the body of 'procedure's | [stmt01.st](tests/bad/stmt01.st) |
| STMT02 | 'result' statement can only appear in the body of 'function's | [stmt02.st](tests/bad/stmt02.st) |
| STMT03 | 'exit' statement can only appear in 'for' or 'loop' statements | [stmt03.st](tests/bad/stmt03.st) |

## Strings

| code | description | example |
|:----:|:------------|:--------|
| STR01 | max length of a 'string' must have type 'int' | [str01.st](tests/bad/str01.st) |
| STR02 | max length of a 'string' must be a compile-time expression | [str02.st](tests/bad/str02.st) |
| STR03 | max length of a 'string' must be in range 1 ~ 255 | [str03-1.st](tests/bad/str03-1.st), [str03-2.st](tests/bad/str03-2.st) |

## Subprograms

| code | description | example |
|:----:|:------------|:--------|
| SUB01 | the name after 'end' should be the name of the 'subprogram' | [sub01-1.st](tests/bad/sub01-1.st), [sub01-2.st](tests/bad/sub01-2.st) |

## Types

| code | description | example |
|:----:|:------------|:--------|
| TYPE01 | type of the expression cannot be assigned to the reference | [type01-1.st](tests/bad/type01-1.st), [type01-2.st](tests/bad/type01-2.st) |
| TYPE02 | type of the expression cannot be assigned as the declared type | [type02-1.st](tests/bad/type02-1.st), [type02-2.st](tests/bad/type02-2.st) |
