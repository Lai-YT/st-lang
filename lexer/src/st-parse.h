/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#include "symtab.h"

// NOLINTBEGIN(readability-identifier-naming)
// Not to report warnings on auto-generated enum.

/* Token kinds.  */
#ifndef YYTOKENTYPE
#define YYTOKENTYPE
enum yytokentype {
  YYEMPTY = -2,
  YYEOF = 0,        /* "end of file"  */
  YYerror = 256,    /* error  */
  YYUNDEF = 300,    /* "invalid token"  */
  ARRAY = 258,      /* ARRAY  */
  BEGIN_ = 259,     /* BEGIN_  */
  BOOL = 260,       /* BOOL  */
  CHAR = 261,       /* CHAR  */
  CONST = 262,      /* CONST  */
  DECREASING = 263, /* DECREASING  */
  DEFAULT = 264,    /* DEFAULT  */
  DO = 265,         /* DO  */
  ELSE = 266,       /* ELSE  */
  END = 267,        /* END  */
  EXIT = 268,       /* EXIT  */
  FALSE = 269,      /* FALSE  */
  FOR = 270,        /* FOR  */
  FUNCTION = 271,   /* FUNCTION  */
  GET = 272,        /* GET  */
  IF = 273,         /* IF  */
  INT = 274,        /* INT  */
  LOOP = 275,       /* LOOP  */
  OF = 276,         /* OF  */
  PUT = 277,        /* PUT  */
  PROCEDURE = 278,  /* PROCEDURE  */
  REAL = 279,       /* REAL  */
  RESULT = 280,     /* RESULT  */
  RETURN = 281,     /* RETURN  */
  SKIP = 282,       /* SKIP  */
  STRING = 283,     /* STRING  */
  THEN = 284,       /* THEN  */
  TRUE = 285,       /* TRUE  */
  VAR = 286,        /* VAR  */
  WHEN = 287,       /* WHEN  */
  ID = 288,         /* ID  */
  STR_CONST = 289,  /* STR_CONST  */
  INT_CONST = 290,  /* INT_CONST  */
  REAL_CONST = 291, /* REAL_CONST  */
  AND = 292,        /* AND  */
  OR = 293,         /* OR  */
  MOD = 294,        /* MOD  */
  LE = 295,         /* LE  */
  GE = 296,         /* GE  */
  NOT = 297,        /* NOT  */
  ASSIGN = 298,     /* ASSIGN  */
  NE = 299          /* NE  */
};
typedef enum yytokentype yytoken_kind_t;
#endif

// NOLINTEND(readability-identifier-naming)

/* Value type.  */
#if !defined YYSTYPE && !defined YYSTYPE_IS_DECLARED
union YYSTYPE {
  Symbol* symbol;
  char str_const[256];
  int int_const;
  double real_const;
};
typedef union YYSTYPE YYSTYPE;
#define YYSTYPE_IS_TRIVIAL 1
#define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if !defined YYLTYPE && !defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE {
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
#define YYLTYPE_IS_DECLARED 1
#define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;
extern YYLTYPE yylloc;
