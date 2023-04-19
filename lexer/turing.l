%option noyywrap

%{
#include <stdio.h>
#include <string.h>

#include "symtab.h"

#define MAX_LINE_LENG 256

extern SymbolTable* symtab;

int linenum = 1;

// records the line content along with the recognition
char line[MAX_LINE_LENG];
#define RECORD_LINE strcat(line, yytext)
#define CLEAR_LINE line[0] = '\0'
#define TOKEN(t) { RECORD_LINE; printf("<%s>\n", #t); }
#define TOKEN_INTEGER(i) { RECORD_LINE; printf("<integer:%d>\n", i); }
#define TOKEN_REAL(r) { RECORD_LINE; printf("<real:%f>\n", r); }
#define TOKEN_STRING(s) { RECORD_LINE; printf("<string:%s>\n", s); }
#define TOKEN_IDENTIFIER(i) { RECORD_LINE; printf("<identifier:%s>\n", i); }

// no longer than a single line
char string[MAX_LINE_LENG];

%}

%x STRING COMMENT BLOCK_COMMENT

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
  printf("%d: %s", linenum++, line);
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
{INT} TOKEN_INTEGER(atoi(yytext));
{REAL} TOKEN_REAL(atof(yytext));

  /*
   * Identifiers
   */
{ID} {
  TOKEN_IDENTIFIER(yytext);
  symtab_insert(symtab, yytext, 0 /* no type */);
}

  /*
   * String constants
   */
\" {
  BEGIN(STRING);
  RECORD_LINE;
}
<STRING>{ESCAPED_QUOTE} {
  RECORD_LINE;
  strcat(string, "\"");
}
<STRING>\" {
  TOKEN_STRING(string);
  string[0] = '\0';
  BEGIN(INITIAL);
}
<STRING>\n {
  RECORD_LINE;
  printf("%d: %s", linenum, line);
  puts("EOL in string");
  exit(-1);
}
<STRING>[^"\n]* {
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
  printf("%d: %s", linenum++, line);
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
  printf("%d: %s", linenum++, line);
  CLEAR_LINE;
}
<BLOCK_COMMENT>.* RECORD_LINE;

  /*
   * errors
   */
  /* a all-match pattern with the lowest priority, which catches all the errors */
. {
  RECORD_LINE;
  printf("%d:%s\n", linenum + 1, line);
  printf("bad character:'%s'\n", yytext);
  exit(-1);
}

%%
