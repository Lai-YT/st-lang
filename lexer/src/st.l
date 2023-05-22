  /* terminates after a file reaches the end */
%option noyywrap
  /* we're no using input & yyunput, don't generate code for them to avoid compiler warnings */
%option noinput
%option nounput
  /* automatically record line number */
%option yylineno

%{
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

#include "st-parse.h"
#include "symtab.h"

#define MAX_LINE_LENG 256

// The content of the line which the lexer is scanning on.
char st_cur_line[MAX_LINE_LENG];

extern SymbolTable* symtab;
extern bool verbose;

// use this instead of yylineno in action of patterns that matches newline
// since yylineno is already advanced when referenced
#define YYLINENO (yylineno - 1)

/* handle locations */
static int yycolumn = 1;
#define YY_USER_ACTION \
  yylloc.first_line = yylloc.last_line = yylineno; \
  yylloc.first_column = yycolumn; \
  yylloc.last_column = yycolumn + yyleng - 1; \
  yycolumn += yyleng;

// Get an entire line at a time.
#define YY_INPUT(buf, result, max_size) \
  { \
    int c = '*'; \
    int n; \
    for (n = 0; n < max_size \
        && (c = getc(yyin)) != EOF && c != '\n'; ++n) { \
      buf[n] = (char)c; \
    } \
    if (c == '\n') { \
      buf[n++] = (char)c; \
      yycolumn = 1; \
    } \
    if (c == EOF && ferror(yyin)) { \
      YY_FATAL_ERROR("input in flex scanner failed"); \
    } \
    strncpy(st_cur_line, buf, n); \
    st_cur_line[n] = '\0'; \
    result = n; \
  }

// records the line content along with the recognition
char line[MAX_LINE_LENG];
#define RECORD_LINE strcat(line, yytext)
#define CLEAR_LINE line[0] = '\0'
#define VERBOSE_PRINTF(...) { if (verbose) printf(__VA_ARGS__); }
#define TOKEN(t) { RECORD_LINE; VERBOSE_PRINTF("<%s>\n", #t); return t; }
#define TOKEN_INTEGER() { RECORD_LINE; VERBOSE_PRINTF("<integer:%d>\n", yylval.int_const); return INT_CONST; }
#define TOKEN_REAL() { RECORD_LINE; VERBOSE_PRINTF("<real:%f>\n", yylval.real_const); return REAL_CONST; }
#define TOKEN_STRING() { RECORD_LINE; VERBOSE_PRINTF("<string:%s>\n", yylval.str_const); return STR_CONST; }
#define TOKEN_IDENTIFIER() { RECORD_LINE; VERBOSE_PRINTF("<identifier:%s>\n", yylval.symbol->name); return ID; }

// no longer than a single line
char string[MAX_LINE_LENG];

%}

%x STRING_ COMMENT BLOCK_COMMENT

  /* operators that have multiple characters */
AND and
OR or
NOT not
MOD mod
LE <=
GE >=
NE not=
ASSIGN :=

ID [a-zA-Z][a-zA-Z0-9]*

INT [0-9][0-9]*
  /* not supporting optional integer / fractional part */
REAL  [0-9]+\.[0-9]+

ESCAPED_QUOTE \"\"

%%

  /*
   * Multiple-character operators
   */
{NE} {
  /* NE has common prefix with NOT but has higher priority */
  TOKEN(NE);
}
{AND}     TOKEN(AND);
{OR}      TOKEN(OR);
{MOD}     TOKEN(MOD);
{LE}      TOKEN(LE);
{GE}      TOKEN(GE);
{NOT}     TOKEN(NOT);
{ASSIGN}  TOKEN(ASSIGN);

  /*
   * Delimiters
   */
"."  TOKEN('.');
","  TOKEN(',');
":"  TOKEN(':');
";"  TOKEN(';');
"("  TOKEN('(');
")"  TOKEN(')');
"["  TOKEN('[');
"]"  TOKEN(']');
"{"  TOKEN('{');
"}"  TOKEN('}');

  /*
   * Single-character operators
   */
"+"  TOKEN('+');
"-"  TOKEN('-');
"*"  TOKEN('*');
"/"  TOKEN('/');
"<"  TOKEN('<');
">"  TOKEN('>');
"="  TOKEN('=');

  /*
   * White spaces
   */
[ \t]+  RECORD_LINE;
\n  {
  RECORD_LINE;
  VERBOSE_PRINTF("%d: %s", YYLINENO, line);
  CLEAR_LINE;
}

  /*
   * Keywords
   */
array       TOKEN(ARRAY);
begin       TOKEN(BEGIN_);
bool        TOKEN(BOOL);
char        TOKEN(CHAR);
const       TOKEN(CONST);
decreasing  TOKEN(DECREASING);
default     TOKEN(DEFAULT);
do          TOKEN(DO);
else        TOKEN(ELSE);
end         TOKEN(END);
exit        TOKEN(EXIT);
false       TOKEN(FALSE);
for         TOKEN(FOR);
function    TOKEN(FUNCTION);
get         TOKEN(GET);
if          TOKEN(IF);
int         TOKEN(INT);
loop        TOKEN(LOOP);
of          TOKEN(OF);
put         TOKEN(PUT);
procedure   TOKEN(PROCEDURE);
real        TOKEN(REAL);
result      TOKEN(RESULT);
return      TOKEN(RETURN);
skip        TOKEN(SKIP);
string      TOKEN(STRING);
then        TOKEN(THEN);
true        TOKEN(TRUE);
var         TOKEN(VAR);
when        TOKEN(WHEN);

  /*
   * Numerical constants
   */
{INT} {
  yylval.int_const = atoi(yytext);
  TOKEN_INTEGER();
}
{REAL} {
  yylval.real_const = atof(yytext);
  TOKEN_REAL();
}

  /*
   * Identifiers
   */
{ID} {
  yylval.symbol = symtab_insert(symtab, yytext, NULL);
  TOKEN_IDENTIFIER();
}

  /*
   * String constants
   */
\" {
  BEGIN(STRING_);
  RECORD_LINE;
}
<STRING_>{ESCAPED_QUOTE} {
  RECORD_LINE;
  strcat(string, "\"");
}
<STRING_>\" {
  strncpy(yylval.str_const, string, MAX_LINE_LENG);
  string[0] = '\0';
  BEGIN(INITIAL);
  TOKEN_STRING();
}
<STRING_>\n {
  RECORD_LINE;
  printf("%d: %s", YYLINENO, line);
  puts("EOL in string");
  exit(-1);
}
<STRING_>[^"\n]* {
  RECORD_LINE;
  strcat(string, yytext);
}

  /*
   * Single-line comment
   */
% {
  BEGIN(COMMENT);
  RECORD_LINE;
}
<COMMENT>\n {
  RECORD_LINE;
  VERBOSE_PRINTF("%d: %s", YYLINENO, line);
  CLEAR_LINE;
  BEGIN(INITIAL);
}
<COMMENT>.* RECORD_LINE;

  /*
   * Block comment
   */
\{% {
  BEGIN(BLOCK_COMMENT);
  RECORD_LINE;
}
<BLOCK_COMMENT>%\}  {
  RECORD_LINE;
  BEGIN(INITIAL);
}
<BLOCK_COMMENT>\n {
  RECORD_LINE;
  VERBOSE_PRINTF("%d: %s", YYLINENO, line);
  CLEAR_LINE;
}
<BLOCK_COMMENT>. RECORD_LINE;

  /*
   * errors
   */
  /* a all-match pattern with the lowest priority, which catches all the errors */
. {
  RECORD_LINE;
  printf("%d:%s\n", yylineno, line);
  printf("bad character:'%s'\n", yytext);
  exit(-1);
}

%%
