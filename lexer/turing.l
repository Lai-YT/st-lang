%option noyywrap

%{
#include <stdio.h>
#include <string.h>

#include "symtab.h"

#define MAX_LINE_LENG 256

SymbolTable* symtab;

int linenum = 1;

// records the line content along with the recognition
char line[MAX_LINE_LENG];
#define RECORD_LINE strcat(line, yytext)
#define CLEAR_LINE line[0] = '\0'
#define token(t) { RECORD_LINE; printf("<%s>\n", #t); }
#define tokenInteger(i) { RECORD_LINE; printf("<integer:%d>\n", i); }
#define tokenReal(r) { RECORD_LINE; printf("<real:%f>\n", r); }
#define tokenString(t, s) { RECORD_LINE; printf("<%s:%s>\n", #t, s); }

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
  token(NE);
}
{AND}     token(AND);
{OR}      token(OR);
{MOD}     token(MOD);
{LE}      token(LE);
{GE}      token(GE);
{NOT}     token(NOT);
{ASSIGN}  token(ASSIGN);

  /*
   * Delimiters
   */
"."  token('.');
","  token(',');
":"  token(':');
";"  token(';');
"("  token('(');
")"  token(')');
"["  token('[');
"]"  token(']');
"{"  token('{');
"}"  token('}');

  /*
   * Single-character operators
   */
"+"  token('+');
"-"  token('-');
"*"  token('*');
"/"  token('/');
"<"  token('<');
">"  token('>');
"="  token('=');

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
array       token(ARRAY);
begin       token(BEGIN_);
bool        token(BOOL);
char        token(CHAR);
const       token(CONST);
decreasing  token(DECREASING);
default     token(DEFAULT);
do          token(DO);
else        token(ELSE);
end         token(END);
exit        token(EXIT);
false       token(FALSE);
for         token(FOR);
function    token(FUNCTION);
get         token(GET);
if          token(IF);
int         token(INT);
loop        token(LOOP);
of          token(OF);
put         token(PUT);
procedure   token(PROCEDURE);
real        token(REAL);
result      token(RESULT);
return      token(RETURN);
skip        token(SKIP);
string      token(STRING);
then        token(THEN);
true        token(TRUE);
var         token(VAR);
when        token(WHEN);

  /*
   * Numerical constants
   */
{INT} tokenInteger(atoi(yytext));
{REAL} tokenReal(atof(yytext));

  /*
   * Identifiers
   */
{ID} tokenString(identifier, yytext); symtab_insert(symtab, yytext, 0 /* no type */);

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
  // XXX: what is the token name of string literals?
  tokenString(string, string);
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

#include "list.h"

int main() {
  symtab = symtab_create();

  yylex();

  puts("");
  puts("Symbol Table:");
  List* dump = symtab_dump(symtab);
  List* curr = dump;
  while (curr) {
    Entry* entry = curr->val;
    printf("%s: %s\n", entry->name, type_to_str(entry->type));
    curr = curr->rest;
  }
  list_delete(dump);

  symtab_delete(symtab);

  return 0;
}
