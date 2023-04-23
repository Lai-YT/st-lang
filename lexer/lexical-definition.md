# Lexical Definitions

## Table of Contents

- [Character Set](#character-set)
- [Tokens that Will be Passed to the Parser](#tokens-that-will-be-passed-to-the-parser)
  - [Delimiters](#delimiters)
  - [Arithmetic, Relational, and Logical Operators](#arithmetic-relational-and-logical-operators)
  - [Keywords](#keywords)
  - [Identifiers](#identifiers)
  - [Numerical Constants](#numerical-constants)
  - [String Constants](#string-constants)
- [Tokens that Will be Discarded](#tokens-that-will-be-discarded)
  - [Whitespace](#whitespace)
  - [Comments](#comments)

## Character Set

_sT_ programs are formed with _ASCII_ characters. Control characters such as `\t` and `\n` are not used in the definition of the language.

Tokens are divided into two classes: tokens that will be passed to the parser and tokens that will be discarded by the lexer (i.e. recognized but not passed to the parser).

## Tokens that Will be Passed to the Parser

The following tokens will be recognized by the lexer and will be eventually be passed to the parser:

### Delimiters

| Name | Lexeme |
|------|--------|
| Dot | `.` |
| Comma | `,` |
| Semicolon | `;` |
| Parentheses | `(` `)` |
| Brackets | `[` `]` |
| Braces | `{` `}` |

### Arithmetic, Relational, and Logical Operators

| Name | Lexeme |
|------|--------|
| Addition | `+` |
| Subtraction | `-` |
| Multiplication | `*` |
| Division | `/` |
| Remainder | `mod` |
| Assignment | `:=` |
| Relation | `<` `<=` `>=` `>` `=` `not=` |
| Logical | `and` `or` `not` |

### Keywords

Note that the keywords are case-sensitive and reserved.

`array`, `begin`, `bool`, `char`, `const`, `decreasing`, `default`, `do`, `else`, `end`, `exit`, `false`, `for`, `function`, `get`, `if`, `int`, `loop`, `of`, `put`, `procedure`, `real`, `result`, `return`, `skip`, `string`, `then`, `true`, `var`, `when`

### Identifiers

An identifier is a string of letters and digits beginning with a letter. For instance, `a1` is a valid identifier, while `1a` is not.
Case of letters is relevant, i.e. `ident`, `Ident`, and `IDENT` are different identifiers. Note that keywords are not identifiers.

### Numerical Constants

A numerical constant is a sequence of one or more digits and optionally followed by a dot and a sequence of one or more digits. Therefore, `.123` and `2.` are not valid numerical constants.

### String Constants

A string constant is a sequence of zero or more _ASCII_ characters appearing between double-quote (`"`) delimiters.
A double-quote appearing with a string must be written twice. For example, `"aa""bb"` denotes the string constant `aa"bb`.

## Tokens that Will be Discarded

The following tokens will be recognized by the lexer, but should be discarded rather than passed back to the parser:

### Whitespace

A sequence of blanks (spaces), tabs, and newlines.

### Comments

Comments can be denoted in two ways:
- Line comment: text following a `%` delimiter running up to the end of the line.
- Block comment: text surrounded by `{%` and `%}` delimiters, which may span more than one line.

Whichever comment style is encountered first remains in effect until the appropriate comment close is encountered. For example,
```
% a comment % line %} {% with {% delimiters %} before the end
```
and
```
{% this is a comment % line with some {% and
% delimiters %}
```
are both valid comments.
