# Syntactic and Semantic Definitions

In the remainder of this definition, the following syntactic notation is used:

- [ item ] means that the item is optional
- { item } means zero or more of the item

Terminals are given in **boldface**. Non-terminals are given in _italics_.

## Table of Contents

- [Programs](#programs)
  - [Subprogram Declarations](#subprogram-declarations)
- [Declarations](#declarations)
  - [Constant Declarations](#constant-declarations)
  - [Variable Declarations](#variable-declarations)
- [Types](#types)
  - [Scalar Types](#scalar-types)
  - [Array Types](#array-types)
- [Statements](#statements)
  - [Variable References](#variable-references)
  - [Subprogram Calls](#subprogram-calls)
  - [`if` Statements](#if-statements)
  - [`loop` Statements](#loop-statements)
  - [`for` Statements](#for-statements)
  - [Blocks](#blocks)
  - [`get` Statements](#get-statements)
  - [`put` Statements](#put-statements)
- [Expressions](#expressions)
  - [Boolean Expressions](#boolean-expressions)
  - [Explicit Constants](#explicit-constants)
  - [Numeric Operators](#numeric-operators)
  - [Comparison Operators](#comparison-operators)
  - [Boolean Operators](#boolean-operators)
  - [String Operators](#string-operators)
  - [Substrings](#substrings)
  - [Compile-Time Expressions](#compile-time-expressions)
- [Predefined Functions](#predefined-functions)

## Programs

A _program_ consists of a sequence of declarations and statements.

- { [ _[declaration](#declarations)_ ] [ _[statement](#statements)_ ] [ *[subprogram_decl](#subprogram-declarations)* ] }

> **Note**
> 1. An empty program is a valid program.
> 2. Subprograms can only be declared on the program level. This is why it's not one of the _declaration_.

### Subprogram Declarations

A _subprogram_ is a procedure or a function.

A *subprogram_declaration* is:

- *subprogram_header* \
*subprogram_body* \
**end** **id**

A *subprogram_header* is one of:

- **procedure** **id** [ **(** *parameter_declaration* { **,** *parameter_declaration* } **)** ]
- **function** **id** [ **(** *parameter_declaration* { **,** *parameter_declaration* } **)** ] **:** _type_

The **id**s appear in the *subprogram_header* and after **end** must be identical, which are the name of the subprogram.

A procedure is invoked by a *[procedure_call](#subprogram-calls)* statement, with actual parameters if required. A function is invoked by using its name, with actual parameters if required, in an expression.
If a subprogram `p` has no parameters, a call to it does not have any parentheses, i.e., the call is of the form `p` and not `p()`.

Subprograms may optionally take parameters, the types of which are defined in the header.
The names of the parameters, as well as the name of the subprogram, are visible inside the subprogram.
Parameters to a subprogram may be declared using **var**, which means the parameter is considered to be a variable inside the subprogram, while any modifications to the formal parameter doesn't affect the actual parameter. Parameters declared without using **var** are considered to be constants.

The identifiers declared in a parameter list must be distinct from each other and from the subprogram name. However, they need not be distinct from other identifiers visible outside of the subprogram.

A *parameter_declaration* is:

- [ **var** ] **id** **:** *parameter_type*

An actual parameter that is passed to a formal must be a variable whose type is equivalent to the formal's type.

A *parameter_type* is one of:

1. _[type](#types)_
2. **string** **(** __*__ **)**
3. **array** _[expr](#expressions)_ **..** __*__ **of** _type_
4. **array** _expr_ **..** __*__ **of** **string** **(** __*__ **)**

In form (2), the maximum length of a dynamic string is declared as `*`, it inherits the size of its actual parameter.
In form (3) and (4), the _expr_ at the lower bound must be a [compile-time expression](#compile-time-expressions); the upper bound of a dynamic array are declared as `*`, in which case any array whose lower bound are equivalent to the parameter's can be passed to the parameter.

> **Note**
> For a multi-dimensional array, only the upper bound of the first dimension may be declared as `*`.

For example, the followings are valid function or procedure *subprogram_header*s:

```turing
function power(var base: real, exp: int): real
function sum(arr: array 0 .. * of int): int
procedure increaseGlobalCount
```

A *subprogram_body* is:

- { [ _[declaration](#declarations)_ ] [ _[statement](#statements)_ ] }

A procedure may return explicitly by executing a **return** statement or implicitly by reaching the end of the procedure body. Execution of a function must conclude by executing a **result** statement and not by reaching the end of the function.

## Declarations

A _declaration_ is one of the following:

- *[constant_declaration](#constant-declarations)*
- *[variable_declaration](#variable-declarations)*

Each of these declarations, including *[subprogram_declaration](#subprogram-declarations)*, creates a new identifier; each new identifier must be distinct from other visible identifiers. That is, re-declaration of visible identifiers is not allowed.

The effect of the declaration (its scope) lasts to the end of the construct in which the declaration occurs.
This will be the end of the _program_, the end of a _[subprogram](#subprogram-declarations)_, the end of a _[block](#blocks)_, the end of a *[loop_statement](#loop-statements)* or *[for_statement](#for-statements)*, or the end of a **then**, **else** clause of an *[if_statement](#if-statements)*.

### Constant Declarations

A *constant_declaration* is:

- **const** **id** [ **:** *[scalar_type](#scalar-types)* ] **:=** _[expr](#expressions)_

Examples:

```turing
const c := 3           % The type of c is int
const s := "Hello"     % The type of s is string
const x := sin(y) * 2  % The type of x is real
```

A *constant_declaration* introduces a name whose value is constant throughout the scope of the declaration. \
If the *[scalar_type](#scalar-types)* is omitted, the type of the constant is taken to be the type of the expression, which must not be a dynamic array.
An initializing _[expr](#expressions)_ may be a compile-time or run-time expression (but not a dynamic array), and must be equivalent to the constant's type.
Named non-scalar values are always considered to be run-time values.

### Variable Declarations

A **variable_declaration** is one of:

1. **var** **id** **:=** _[expr](#expressions)_
2. **var** **id** **:** *[array_type](#array-types)*
3. **var** **id** **:** *[scalar_type](#scalar-types)* [ **:=** _expr_ ]

Examples:

```turing
var i: int := 1          % i is assigned with initial value 1
var s := "sample output" % The type of s is string
```

A **variable_declaration** creates a new variable. \
In form (1), the variable's type is taken to be the type of the _expr_; this type must not be a dynamic array.
Form (2) allows the declaration of dynamic arrays, whose upper bounds are run-time expressions. However, the lower bounds are constrained to be compile-time expressions.
Given that `n` is a variable, here is an example of the declaration of a dynamic array:

```turing
var w: array 1..n, 1..n of real
```

Run-time bounds are only allowed as illustrated in this example, i.e., as the upper bounds of an array declared using form (2).
Each upper bound must be at least as large as its corresponding lower bound. A array cannot be initialized in its declaration.

## Types

A _type_ is one of the following:

- *[scalar_type](#scalar-types)*
- *[array_type](#array-types)*

### Scalar Types

A *scalar_type* is one of:

- **int**
- **real**
- **bool**
- **string** [ **(** _[expr](#expressions)_ **)** ]

The optional _expr_ in a `string` type must be a [compile-time expression](#compile-time-expressions), and is a strictly positive `int` value giving the string's maximum length. If the string's maximum length is omitted, the string is considered to have length 255.

### Array Types

An *array_type* is:

- **array** _[expr](#expressions)_ **..** _expr_ **of** _[type](#types)_

Variables and parameters can be declared to be dynamic arrays, with runtime upper bounds.

The two *expr*s give the lower and upper bounds of the range of values of the type. The two *expr*s must be both `int`s.
The lower bound must be less than or equal to the upper bound. The first _expr_ must be a [compile-time expression](#compile-time-expressions). The second _expr_ must be a compile-time expression as also except when it gives the upper bound of a dynamic array being defined in a *[variable_declaration](#variable-declarations)*.

To have a multi-dimensional array, declare an array with *array_type*, but only the upper bound of the first dimension may be a run-time expression. \
Examples:

```turing
var j: int
get j
var validArr: array 1..j of array 1..4 of int    % ok
var invalidArr: array 1..4 of array 1..j of int  % error
```

## Statements

A _statement_ is one of:

1. *[variable_reference](#variable-references)* **:=** _[expr](#expressions)_
2. *[subprogram_call](#subprogram-calls)*
3. **return**
4. **result** _expr_
5. *[if_statement](#if-statements)*
6. **exit** [ **when** *bool_expr* ]
7. *[loop_statement](#loop-statements)*
8. *[for_statement](#for-statements)*
9. *[block](#blocks)*
10. *[get_statement](#get-statements)*
11. *[put_statement](#put-statements)*
12. **skip**

Form (3) is a **return** statement, which causes immediate return from a procedure.

Form (4) is a **result** statement, which can only appear in a function and causes immediate return from the function giving the function's value. The result expression must have type equivalent to the result type of the function given in the function's header.

Form (6) is a loop exit. When executed, it causes an immediate exit from the nearest enclosing *loop_statement* or *for_statement*.
The optional *bool_expr* makes the **exit** conditional. If the expression evaluates to `true` then the exit is executed, otherwise execution of the loop continues.
An **exit** statement can appear only inside *loop_statement* and *for_statement*.

Form (12) is a **skip** statement, which immediately outputs a newline to the standard output stream. It's equivalent to `put ""`.

### Variable References

A *variable_reference* is one of:

1. **id**
2. **id** **[** _expr_ **]** { **[** _expr_ **]** }

Form (2) allows subscripting of arrays. The value of array subscript expression must be in the declared range.

For example, `arr[1][4]` is a variable reference of the array `arr` with type `array 1..2 of array 1..4 of int`.

### Subprogram Calls

A *subprogram_call* is:

- **id** [ **(** _expr_ { **,** _expr_ } **)** ]

The number of expressions must be the same as the number of declared parameters of the [subprogram](#subprogram-declarations).
Each _expr_ must have type equivalent to the corresponding formal parameter of the subprogram.

### `if` Statements

An *if_statement* is:

- **if** *[bool_expr](#boolean-expressions)* **then** \
{ [ _[declaration](#declarations)_ ] [ _statement_ ] } \
[ **else** { [ _declaration_ ] [ _statement_ ] } ] \
**end** **if**

> **Note**
> `if true then else end if` is a valid *if_statement*.

### `loop` Statements

A *loop_statement* is:

- **loop** \
{ [ _[declaration](#declarations)_ ] [ _statement_ ] } \
**end** **loop**

The statements within the loop are repeated until terminated by one of its **exit** statements or an enclosed **return** or **result** statement.

### `for` Statements

A *for_statement* is:

- **for** [ **decreasing** ] [ **id** ] **:** _expr_ **..** _expr_ \
{ [ _[declaration](#declarations)_ ] [ _statement_ ] } \
**end** **for**

The statements enclosed in the *for_statement* are repeated for the specified range, or until the for loop is terminated by one of its **exit** statements or an enclosed **return** or **result** statement.

The range is given by the value of the two _[expr](#expressions)_ when the *for_statement* is executed.
The types of the two values must be both of type `int`.
For the first iteration, **id** has the left *expr*'s value; for successive iterations, **id** is increased by one (or decreased by one if **decreasing** is present), until in the last iteration **id** equals the right value. If the left value exceeds the right (or is less than the right when **decreasing**), there are no iterations.

For each iteration, **id** is set to a new value in the range; these are contiguous values that are increasing, unless **decreasing** is specified in which case they are decreasing.
The *for_statement* is a declaration for **id**, which must be distinct from other visible identifiers. It's a constant and its value cannot be changed.
The scope of **id** is from the beginning to the end of the *for_statement*.
If the **id** is not present, the *for_statement* behaves the same way, except that the value corresponding to the **id** cannot be accessed.

For example, the following program prints `1 2 3`:

```turing
for i : 1..3
    put i, " " ..  % no new line
end for
```

### Blocks

A _block_ is:

- **begin** \
{ [ _[declaration](#declarations)_ ] [ _statement_ ] } \
**end**

It can be used to limit the scope of declarations.

### `get` Statements

A *get_statement* is:

- **get** *variable_reference* { **,** *variable_reference* }

The *get_statement* gets tokens from the standard input stream.

The *[variable_reference](#variable-references)* cannot have type other than *[scalar_type](#scalar-types)*.

The *get_statement* first skips whitespace (defined as the characters blank, tab, form feed, new line, and carriage return); then it reads the sequence of non-whitespace characters as a token.
A token consists of either (a) one or more non-whitespace characters, up to but not including either a whitespace character or end of file, or else (b) if the token's first character is a quote (`"`), then an explicit string constant.
When the *variable_reference* is a string, the value of the explicit string constant or the characters of the token are assigned to the variable. If it is an integer, the the token is converted to an integer before assigning to the variable. Analogously for reals.
It is an error if no token remains in the stream.

### `put` Statements

A *put_statement* is:

- **put** *_expr_* { **,** *_expr_* } [ **..** ]

The *put_statement* outputs tokens to the standard output stream.

From left to right in a *put_statement*, the *[expr](#expressions)*'s value is appended as text to the output stream.
A new line is started at the end of the list of *expr*s, unless the list is followed by **..**, in which case this new line is not started. This allows the next *put_statement* to continue the current output line.

## Expressions

An _expr_ (expression) represents a calculation that returns a value.

An _expr_ is one of the following:

1. *[variable_reference](#variable-references)*
2. *[explicit_const](#explicit-constants)*
3. *[subprogram_call](#subprogram-calls)*
4. _[substring](#substrings)_
5. _expr_ *binary_op* _expr_
6. *unary_op* _expr_
7. **(** _expr_ **)**

Form (2) includes explicit `bool`, `int`, `real` and `string` constants; form (3) only allows function calls, which have result values.

In form (5), a *binary_op* is one of:

1. **+** (`int` and `real` addition; `string` concatenation)
2. **-** (`int` and `real` subtraction)
3. __*__ (`int` and `real` multiplication)
4. **/** (`int` and `real` division)
5. **mod** (remainder)
6. **<** (less than)
7. **>** (greater than)
8. **=** (equal)
9. **<=** (less than or equal)
10. **>=** (greater than or equal)
11. **not=** (not equal)
12. **and** (`bool` conjunction)
13. **or** (`bool` inclusive or)

(1) ~ (5) are [numeric operators](#numeric-operators); (1) can also be a [string operator](#string-operators); (6) ~ (11) are [comparison operators](#comparison-operators); (12) ~ (13) are [boolean operators](#boolean-operators).

In form (5), an *unary_op* is one of:

- **+** (`int` and `real` identity)
- **-** (`int` and `real` negation)
- **not** (`bool` negation)

The order of precedence is among the following classes of the operators, in decreasing order of precedence:

1. `+`, `-` (unary)
2. `*`, `/`, `mod`
3. `+`, `-` (binary)
4. `<`, `>`, `=`, `<=` `>=`, `not=`
5. `not`
6. `and`
7. `or`

All *binary_op*s are left associative, and all *unary_op*s are right associative. Parentheses may be used to group _expr_ to dictate a different precedence.

### Boolean Expressions

A *bool_expr* is an _expr_ whose value is `true` or `false`.

1. *[var_ref](#variable-references)*
2. **bool_const**
3. *expr* *binary_op* *expr*
4. **not** *bool_expr*
5. **(** *bool_expr* **)**

In form (1), such reference must be `bool` type.
In form (3) *binary_op* can only be one of the [comparison operators](#comparison-operators) or [boolean operators](#boolean-operators).

### Explicit Constants

An *explicit_const* is one of:

- **int_const**
- **real_const**
- **bool_const**
- **string_const**

For example, `1`, `1.0`, `true` and `"1"` are *explicit_const*s.

### Numeric Operators

The numeric (`int` and `real`) operators are `+`, `-`, `*`, `/` and `mod` (remainder).

The `mod` operator is defined by `x mod y = x — (y * trunc(x / y))`, where `/` means exact mathematical division and `trunc` truncates to the nearest integer in the direction of zero.
If `x` and `y` are both of type `int`, the result type is `int`, otherwise the result is `real`.

The `/` operator requires `real` or `int` operands and produces a result of type `real`. Its right operand must not be zero.

Whenever a `real` value is required, an `int` value is allowed and is converted to `real` implicitly.
> **Note**
> This rule implies that the `/` operator can accept two `int` operands, but both will be converted to `real`.
> The operators `+`, `-` (binary and unary) and `*` require `int` or `real` operands; if one or both operands are `real`, the result is `real`, otherwise the result is `int`.

### Comparison Operators

The comparison operators are `<`, `>`, `=`, `<=`, `>=`, and `not=`.
These operators yield a `bool` result.
Both operands of a comparison operator must have the same type. Only *scalar_type*s can be compared.

The ordering of `string`s is determined by left to right comparison of pairs of corresponding characters until an end of string or a mismatch is found. The string with the greater of the mismatched characters is considered greater. If no mismatch is found and one string is longer than the other, the longer string is considered greater.

### Boolean Operators

The boolean operators are `and` (conjunction), `or` (inclusive or) and `not`.
These require `bool` operands and return a `bool` result.
The boolean operators are conditional; that is, if the result of the operation is determined by the value of the left operand then the right operand is not evaluated.

### String Operators

The only string operator is `+` (concatenation); it requires `string` operands and returns a `string` result. Note that the result string cannot exceed 255.

### Substrings

A *substring* is:

- **id** **[** _expr_ [ **..** _expr_ ] **]**

The **id** must have type `string` and the *expr*s must be positive `int`s.

A *substring* selects a contiguous sequence of the characters in a `string`. For example, if `L := 3`, `R := 5` and `s := "string"`, then the substring of `s` from position `L` to position `R`, written `s[L .. R]`, is `"rin"`. A single character can also be selected, for example, `s[L]` is `"r"`, and in general, for any
integer expression `e`, `s[e]` is equivalent to `s[e .. e]`. \
The following restrictions apply to `L` and `R`:

- `L >= 1 and R <= length(s) and R - L + 1 >= 0`

> **Note**
> A _substring_ is an _expr_ (not a *variable_reference*), and it so cannot be assigned to.

### Compile-Time Expressions

A compile-time expression is an _expr_ whose value can, in principle, be computed at compile time. The following are compile-time expressions:

1. *[explicit_const](#explicit-constants)*
2. **id**: a named constants that name scalar compile-time expressions
3. _expr_ *binary_op* _expr_: the _expr_ on the both sides are also compile-time expressions
4. *unary_op* _expr_: the _expr_ is also a compile-time expression

> **Note** A compile-time expression can be invalid, for example, `1/0`, and is still considered to be a compile-time expression.
> Expressions that do not satisfy this definition are called run-time expressions.

## Predefined Functions

- `eof: bool` \
Returns `true` if and only if there are no more characters in the standard input stream.

- `length(s: string): int` \
Returns the number of characters in the `string`. The `string` must be initialized.
