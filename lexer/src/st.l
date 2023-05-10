  /* terminates after a file reaches the end */
%option noyywrap
  /* we're no using input & yyunput, don't generate code for them to avoid compiler warnings */
%option noinput
%option nounput
  /* automatically record line number */
%option yylineno

%{
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "st-parse.h"
#include "symtab.h"

#define MAX_LINE_LENG 256

// The content of the line which the lexer is scanning on.
char* cur_line;
// The current token locates at [begin, end). Starts from 0.
typedef struct TokenLocation {
  int begin;
  int end;
} TokenLocation;
TokenLocation cur_token_loc;

extern SymbolTable* symtab;
extern bool verbose;

// use this instead of yylineno in action of patterns that matches newline
// since yylineno is already advanced when referenced
#define YYLINENO (yylineno - 1)

#define YY_INPUT(buf, result, max_size) \
  { \
    cur_line = (buf); \
    size_t len = 0; \
    (result) = getline(&cur_line, &len, yyin); \
    if (len > (size_t)max_size) { \
      free(cur_line); \
      YY_FATAL_ERROR("length of line exceed buffer size"); \
    } \
    if ((result) == -1) { \
      free(cur_line); \
      if (feof(yyin)) { \
        (result) = YY_NULL; \
      } else { \
        YY_FATAL_ERROR("input in flex scanner failed"); \
      } \
    } \
    strncpy((buf), cur_line, len); \
    cur_token_loc.begin = 0; \
    cur_token_loc.end = 0; \
  }

#define YY_USER_ACTION \
  { \
    cur_token_loc.begin = cur_token_loc.end; \
    cur_token_loc.end += yyleng; \
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
  yylval.symbol = symtab_insert(symtab, yytext);
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
  strncpy(yylval.str_const, string, MAX_LINE_LENG - strlen(string) - 1);
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
