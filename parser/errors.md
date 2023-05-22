# Errors

## Arrays

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| ARR01 | lower bound of an 'array' must be determined at compile-time | fatal | [arr01-1.st](tests/bad/arr01-1.st), [arr01-2.st](tests/bad/arr01-2.st) |
| ARR02 | lower/upper bound of an 'array' must have type 'int' | fatal | [arr02-1.st](tests/bad/arr02-1.st), [arr02-2.st](tests/bad/arr02-2.st), [arr02-3.st](tests/bad/arr02-3.st) |
| ARR03 | type of an 'array' must be a 'static array' | fatal | [arr03-1.st](tests/bad/arr03-1.st), [arr03-2.st](tests/bad/arr03-2.st) |
| ARR04 | lower bound of an 'array' must be positive | fatal | [arr04-1.st](tests/bad/arr04-1.st), [arr04-2.st](tests/bad/arr04-2.st) |
| ARR05 | upper bound of a 'static array' must be positive | fatal | [arr05.st](tests/bad/arr05.st) |
| ARR06 | upper bound of a 'static array' must be greater than its lower bound | fatal | [arr06.st](tests/bad/arr06.st) |

## Call of Subprograms

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| CALL01 | identifier 'x' is not a subprogram| fatal | [call01.st](tests/bad/call01.st) |
| CALL02 | mismatch number of formals, expect 'n' but get 'm' | non-fatal | [call02.st](tests/bad/call02.st) |
| CALL03 | type of the actual parameter cannot be assigned as type of the formal parameter | non-fatal | [call03.st](tests/bad/call03.st) |

## Constants

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| CONST01 | a constant identifier cannot be a 'dynamic array' | fatal | [const01-1.st](tests/bad/const01-1.st), [const01-2.st](tests/bad/const01-2.st) |
| CONST02 | re-assignment on constant reference | non-fatal | [const02-1.st](tests/bad/const02-1.st), [const02-2.st](tests/bad/const02-2.st), [const02-3.st](tests/bad/const02-3.st) |

## Declarations

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| DECL01 | re-declaration of identifier 'x' | non-fatal | [decl01-1.st](tests/bad/decl01-1.st), [decl01-2.st](tests/bad/decl01-2.st), [decl01-3.st](tests/bad/decl01-3.st), [decl01-4.st](tests/bad/decl01-4.st), [decl01-5.st](tests/bad/decl01-5.st) |

## Expressions

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| EXPR01 | 'procedure' call cannot be an expression | fatal | [expr01.st](tests/bad/expr01.st) |
| EXPR02 | operand of 'sign' operation must have type 'int' or 'real' | non-fatal | [expr02.st](tests/bad/expr02.st) |
| EXPR03 | operand of 'boolean' operation must have type 'bool' | non-fatal | [expr03.st](tests/bad/expr03.st) |
| EXPR04 | operand of 'comparison' operation must have type 'int', 'real', or 'string' | non-fatal | [expr04.st](tests/bad/expr04.st) |
| EXPR05 | operands of 'comparison' operation must have the same type | non-fatal | [expr05.st](tests/bad/expr05.st) |
| EXPR06 | operand of 'arithmetic' operation must have type 'int' or 'real' | non-fatal | [expr06.st](tests/bad/expr06.st) |
| EXPR07 | operand of 'mod' operation must have type 'int' | non-fatal | [expr07.st](tests/bad/expr07.st) |
| EXPR08 | 'boolean' expression must have type 'bool' | non-fatal | [expr08-1.st](tests/bad/expr08-1.st), [expr08-2.st](tests/bad/expr08-2.st) |

## For Statements

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| FOR01 | range of a 'for' statement must have type 'int' | non-fatal | [for01-1.st](tests/bad/for01-1.st), [for01-2.st](tests/bad/for01-2.st), [for01-2.st](tests/bad/for01-2.st) |

## References

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| REF01 | identifier 'x' is not declared | fatal | [ref01-1.st](tests/bad/ref01-1.st), [ref01-2.st](tests/bad/ref01-2.st), [ref01-3.st](tests/bad/ref01-3.st) |
| REF02 | identifier 'x' is a 'subprogram', cannot be used as reference | fatal | [ref02-1.st](tests/bad/ref02-1.st), [ref02-2.st](tests/bad/ref02-2.st) |
| REF03 | 'character' is unsubscriptable, for substrings, use 'x[n .. m]' instead | fatal | [ref03.st](tests/bad/ref03.st) |
| REF04 | identifier 'x' has unsubscriptable type | fatal | [ref04.st](tests/bad/ref04.st) |
| REF05 | 'n'-dimensional 'array' cannot have 'm' subscripts | fatal | [ref05.st](tests/bad/ref05.st) |
| REF06 | subscript must have type 'int' | non-fatal | [ref06.st](tests/bad/ref06.st) |

## Statements

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| STMT01 | 'return' statement can only appear in the body of 'procedure's | non-fatal |[stmt01.st](tests/bad/stmt01.st) |
| STMT02 | 'result' statement can only appear in the body of 'function's | non-fatal | [stmt02.st](tests/bad/stmt02.st) |
| STMT03 | 'exit' statement can only appear in 'for' or 'loop' statements | non-fatal | [stmt03.st](tests/bad/stmt03.st) |
| STMT04 | 'function' call cannot be a statement | fatal | [stmt04.st](tests/bad/stmt04.st) |
| STMT05 | type of the 'result' expression cannot be assigned as the result type of the 'function' | non-fatal | [stmt05.st](tests/bad/stmt05.st) |
| STMT06 | expressions in 'put' statement cannot have type 'array' | non-fatal | [stmt06.st](tests/bad/stmt06.st) |
| STMT07 | references in 'get' statement cannot be constant | non-fatal | [stmt07.st](tests/bad/stmt07.st) |
| STMT08 | references in 'get' statement cannot have type 'array' | non-fatal | [stmt08.st](tests/bad/stmt08.st) |

## Strings

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| STR01 | max length of a 'string' must have type 'int' | non-fatal | [str01.st](tests/bad/str01.st) |
| STR02 | max length of a 'string' must be a compile-time expression | non-fatal | [str02.st](tests/bad/str02.st) |
| STR03 | max length of a 'string' must be in range 1 ~ 255 | non-fatal | [str03-1.st](tests/bad/str03-1.st), [str03-2.st](tests/bad/str03-2.st) |
| STR04 | operands of 'string' concatenation must both have type 'string' | fatal | [str04.st](tests/bad/str04.st) |
| STR05 | in compile-time 'string' concatenation, length of the result 'string' must not exceed 255 | fatal | [str05.st](tests/bad/str05.st) |

## Subprograms

| code | description | kind | example |
|:----:|:------------|:----:|:--------|
| SUB01 | the name after 'end' should be the name of the 'subprogram' | non-fatal | [sub01-1.st](tests/bad/sub01-1.st), [sub01-2.st](tests/bad/sub01-2.st) |
| SUB02 | 'function' must ends with a 'result' statement | non-fatal | [sub02-1.st](tests/bad/sub02-1.st), [sub02-2.st](tests/bad/sub02-2.st), [sub02-3.st](tests/bad/sub02-3.st) |
| SUB03 | type of formal parameter cannot be a 'dynamic array' | fatal | [sub03.st](tests/bad/sub03.st) |

## Types

| code | description | example |
|:----:|:------------|:--------|
| TYPE01 | type of the expression cannot be assigned to the reference | non-fatal | [type01-1.st](tests/bad/type01-1.st), [type01-2.st](tests/bad/type01-2.st) |
| TYPE02 | type of the expression cannot be assigned as the declared type | non-fatal | [type02-1.st](tests/bad/type02-1.st), [type02-2.st](tests/bad/type02-2.st) |
