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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "src/st.y"

  #include <stdio.h>
  #include <string.h>
  #include "symtab.h"

  typedef Entry* Symbol;

  #define TRACE(...)  fprintf(stderr, __VA_ARGS__)

  void yyerror(const char *s);  /*  defined below; called for each parse error */
  extern int yylex();           /*  the entry point to the lexer  */
  extern int yylineno;
  extern char yytext[];

#line 86 "src/st-parse.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif


/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 300,                 /* "invalid token"  */
    ARRAY = 258,                   /* ARRAY  */
    BEGIN_ = 259,                  /* BEGIN_  */
    BOOL = 260,                    /* BOOL  */
    CHAR = 261,                    /* CHAR  */
    CONST = 262,                   /* CONST  */
    DECREASING = 263,              /* DECREASING  */
    DEFAULT = 264,                 /* DEFAULT  */
    DO = 265,                      /* DO  */
    ELSE = 266,                    /* ELSE  */
    END = 267,                     /* END  */
    EXIT = 268,                    /* EXIT  */
    FALSE = 269,                   /* FALSE  */
    FOR = 270,                     /* FOR  */
    FUNCTION = 271,                /* FUNCTION  */
    GET = 272,                     /* GET  */
    IF = 273,                      /* IF  */
    INT = 274,                     /* INT  */
    LOOP = 275,                    /* LOOP  */
    OF = 276,                      /* OF  */
    PUT = 277,                     /* PUT  */
    PROCEDURE = 278,               /* PROCEDURE  */
    REAL = 279,                    /* REAL  */
    RESULT = 280,                  /* RESULT  */
    RETURN = 281,                  /* RETURN  */
    SKIP = 282,                    /* SKIP  */
    STRING = 283,                  /* STRING  */
    THEN = 284,                    /* THEN  */
    TRUE = 285,                    /* TRUE  */
    VAR = 286,                     /* VAR  */
    WHEN = 287,                    /* WHEN  */
    ID = 288,                      /* ID  */
    STR_CONST = 289,               /* STR_CONST  */
    INT_CONST = 290,               /* INT_CONST  */
    REAL_CONST = 291,              /* REAL_CONST  */
    AND = 292,                     /* AND  */
    OR = 293,                      /* OR  */
    MOD = 294,                     /* MOD  */
    LE = 295,                      /* LE  */
    GE = 296,                      /* GE  */
    NOT = 297,                     /* NOT  */
    ASSIGN = 298,                  /* ASSIGN  */
    NE = 299,                      /* NE  */
    BOOLEAN_OP = 301,              /* BOOLEAN_OP  */
    COMPARISON_OP = 302,           /* COMPARISON_OP  */
    NUMERIC_OP = 303,              /* NUMERIC_OP  */
    SIGN_OP = 304                  /* SIGN_OP  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 16 "src/st.y"

  Symbol symbol;
  char str_const[256];
  int int_const;
  double real_const;

#line 188 "src/st-parse.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);



/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_ARRAY = 3,                      /* ARRAY  */
  YYSYMBOL_BEGIN_ = 4,                     /* BEGIN_  */
  YYSYMBOL_BOOL = 5,                       /* BOOL  */
  YYSYMBOL_CHAR = 6,                       /* CHAR  */
  YYSYMBOL_CONST = 7,                      /* CONST  */
  YYSYMBOL_DECREASING = 8,                 /* DECREASING  */
  YYSYMBOL_DEFAULT = 9,                    /* DEFAULT  */
  YYSYMBOL_DO = 10,                        /* DO  */
  YYSYMBOL_ELSE = 11,                      /* ELSE  */
  YYSYMBOL_END = 12,                       /* END  */
  YYSYMBOL_EXIT = 13,                      /* EXIT  */
  YYSYMBOL_FALSE = 14,                     /* FALSE  */
  YYSYMBOL_FOR = 15,                       /* FOR  */
  YYSYMBOL_FUNCTION = 16,                  /* FUNCTION  */
  YYSYMBOL_GET = 17,                       /* GET  */
  YYSYMBOL_IF = 18,                        /* IF  */
  YYSYMBOL_INT = 19,                       /* INT  */
  YYSYMBOL_LOOP = 20,                      /* LOOP  */
  YYSYMBOL_OF = 21,                        /* OF  */
  YYSYMBOL_PUT = 22,                       /* PUT  */
  YYSYMBOL_PROCEDURE = 23,                 /* PROCEDURE  */
  YYSYMBOL_REAL = 24,                      /* REAL  */
  YYSYMBOL_RESULT = 25,                    /* RESULT  */
  YYSYMBOL_RETURN = 26,                    /* RETURN  */
  YYSYMBOL_SKIP = 27,                      /* SKIP  */
  YYSYMBOL_STRING = 28,                    /* STRING  */
  YYSYMBOL_THEN = 29,                      /* THEN  */
  YYSYMBOL_TRUE = 30,                      /* TRUE  */
  YYSYMBOL_VAR = 31,                       /* VAR  */
  YYSYMBOL_WHEN = 32,                      /* WHEN  */
  YYSYMBOL_ID = 33,                        /* ID  */
  YYSYMBOL_STR_CONST = 34,                 /* STR_CONST  */
  YYSYMBOL_INT_CONST = 35,                 /* INT_CONST  */
  YYSYMBOL_REAL_CONST = 36,                /* REAL_CONST  */
  YYSYMBOL_AND = 37,                       /* AND  */
  YYSYMBOL_OR = 38,                        /* OR  */
  YYSYMBOL_MOD = 39,                       /* MOD  */
  YYSYMBOL_LE = 40,                        /* LE  */
  YYSYMBOL_GE = 41,                        /* GE  */
  YYSYMBOL_NOT = 42,                       /* NOT  */
  YYSYMBOL_ASSIGN = 43,                    /* ASSIGN  */
  YYSYMBOL_NE = 44,                        /* NE  */
  YYSYMBOL_BOOLEAN_OP = 45,                /* BOOLEAN_OP  */
  YYSYMBOL_46_ = 46,                       /* '<'  */
  YYSYMBOL_47_ = 47,                       /* '>'  */
  YYSYMBOL_48_ = 48,                       /* '='  */
  YYSYMBOL_COMPARISON_OP = 49,             /* COMPARISON_OP  */
  YYSYMBOL_50_ = 50,                       /* '+'  */
  YYSYMBOL_51_ = 51,                       /* '-'  */
  YYSYMBOL_52_ = 52,                       /* '*'  */
  YYSYMBOL_53_ = 53,                       /* '/'  */
  YYSYMBOL_NUMERIC_OP = 54,                /* NUMERIC_OP  */
  YYSYMBOL_SIGN_OP = 55,                   /* SIGN_OP  */
  YYSYMBOL_56_ = 56,                       /* ':'  */
  YYSYMBOL_57_ = 57,                       /* '('  */
  YYSYMBOL_58_ = 58,                       /* ')'  */
  YYSYMBOL_59_ = 59,                       /* ','  */
  YYSYMBOL_60_ = 60,                       /* '.'  */
  YYSYMBOL_61_ = 61,                       /* '['  */
  YYSYMBOL_62_ = 62,                       /* ']'  */
  YYSYMBOL_YYACCEPT = 63,                  /* $accept  */
  YYSYMBOL_program = 64,                   /* program  */
  YYSYMBOL_decl_or_stmt_in_main_program_list = 65, /* decl_or_stmt_in_main_program_list  */
  YYSYMBOL_decl_or_stmt_in_main_program = 66, /* decl_or_stmt_in_main_program  */
  YYSYMBOL_decl = 67,                      /* decl  */
  YYSYMBOL_stmt = 68,                      /* stmt  */
  YYSYMBOL_var_decl = 69,                  /* var_decl  */
  YYSYMBOL_const_decl = 70,                /* const_decl  */
  YYSYMBOL_subprog_decl = 71,              /* subprog_decl  */
  YYSYMBOL_subprog_header = 72,            /* subprog_header  */
  YYSYMBOL_opt_decl_or_stmt_list = 73,     /* opt_decl_or_stmt_list  */
  YYSYMBOL_decl_or_stmt_list = 74,         /* decl_or_stmt_list  */
  YYSYMBOL_decl_or_stmt = 75,              /* decl_or_stmt  */
  YYSYMBOL_formal_decl_list = 76,          /* formal_decl_list  */
  YYSYMBOL_formal_decl = 77,               /* formal_decl  */
  YYSYMBOL_formal_type = 78,               /* formal_type  */
  YYSYMBOL_subprog_call = 79,              /* subprog_call  */
  YYSYMBOL_actual_list = 80,               /* actual_list  */
  YYSYMBOL_if_stmt = 81,                   /* if_stmt  */
  YYSYMBOL_exit_stmt = 82,                 /* exit_stmt  */
  YYSYMBOL_loop_stmt = 83,                 /* loop_stmt  */
  YYSYMBOL_for_stmt = 84,                  /* for_stmt  */
  YYSYMBOL_block = 85,                     /* block  */
  YYSYMBOL_get_stmt = 86,                  /* get_stmt  */
  YYSYMBOL_get_item_list = 87,             /* get_item_list  */
  YYSYMBOL_get_item = 88,                  /* get_item  */
  YYSYMBOL_put_stmt = 89,                  /* put_stmt  */
  YYSYMBOL_put_item_list = 90,             /* put_item_list  */
  YYSYMBOL_put_item = 91,                  /* put_item  */
  YYSYMBOL_bool_expr = 92,                 /* bool_expr  */
  YYSYMBOL_scalar_type = 93,               /* scalar_type  */
  YYSYMBOL_array_type = 94,                /* array_type  */
  YYSYMBOL_type = 95,                      /* type  */
  YYSYMBOL_var_ref = 96,                   /* var_ref  */
  YYSYMBOL_subscript_list = 97,            /* subscript_list  */
  YYSYMBOL_subscript = 98,                 /* subscript  */
  YYSYMBOL_expr = 99,                      /* expr  */
  YYSYMBOL_explicit_const = 100,           /* explicit_const  */
  YYSYMBOL_bool_const = 101,               /* bool_const  */
  YYSYMBOL_operation = 102,                /* operation  */
  YYSYMBOL_numeric_operation = 103,        /* numeric_operation  */
  YYSYMBOL_comparison_operation = 104,     /* comparison_operation  */
  YYSYMBOL_boolean_operation = 105,        /* boolean_operation  */
  YYSYMBOL_sign_operation = 106            /* sign_operation  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int16 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if 1

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* 1 */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  85
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   727

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  63
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  44
/* YYNRULES -- Number of rules.  */
#define YYNRULES  120
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  258

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   304


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      57,    58,    52,    50,    59,    51,    60,    53,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    56,     2,
      46,    48,    47,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    61,     2,    62,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
       2,    45,    49,    54,    55
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,    58,    58,    61,    65,    67,    76,    78,    83,    85,
      90,    92,    94,    96,    98,   100,   102,   104,   106,   108,
     110,   115,   117,   119,   121,   126,   128,   133,   138,   140,
     142,   144,   149,   152,   156,   158,   163,   165,   170,   172,
     177,   179,   184,   186,   188,   190,   195,   197,   202,   204,
     209,   211,   216,   218,   223,   228,   230,   232,   234,   239,
     244,   249,   251,   256,   258,   263,   265,   270,   272,   277,
     279,   284,   286,   288,   290,   300,   305,   307,   309,   311,
     313,   318,   323,   325,   333,   338,   343,   345,   350,   355,
     357,   367,   377,   379,   381,   386,   388,   390,   392,   397,
     399,   404,   406,   408,   410,   415,   416,   417,   418,   419,
     423,   424,   425,   426,   427,   428,   437,   438,   439,   443,
     444
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if 1
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  static const char *const yy_sname[] =
  {
  "end of file", "error", "invalid token", "ARRAY", "BEGIN_", "BOOL",
  "CHAR", "CONST", "DECREASING", "DEFAULT", "DO", "ELSE", "END", "EXIT",
  "FALSE", "FOR", "FUNCTION", "GET", "IF", "INT", "LOOP", "OF", "PUT",
  "PROCEDURE", "REAL", "RESULT", "RETURN", "SKIP", "STRING", "THEN",
  "TRUE", "VAR", "WHEN", "ID", "STR_CONST", "INT_CONST", "REAL_CONST",
  "AND", "OR", "MOD", "LE", "GE", "NOT", "ASSIGN", "NE", "BOOLEAN_OP",
  "'<'", "'>'", "'='", "COMPARISON_OP", "'+'", "'-'", "'*'", "'/'",
  "NUMERIC_OP", "SIGN_OP", "':'", "'('", "')'", "','", "'.'", "'['", "']'",
  "$accept", "program", "decl_or_stmt_in_main_program_list",
  "decl_or_stmt_in_main_program", "decl", "stmt", "var_decl", "const_decl",
  "subprog_decl", "subprog_header", "opt_decl_or_stmt_list",
  "decl_or_stmt_list", "decl_or_stmt", "formal_decl_list", "formal_decl",
  "formal_type", "subprog_call", "actual_list", "if_stmt", "exit_stmt",
  "loop_stmt", "for_stmt", "block", "get_stmt", "get_item_list",
  "get_item", "put_stmt", "put_item_list", "put_item", "bool_expr",
  "scalar_type", "array_type", "type", "var_ref", "subscript_list",
  "subscript", "expr", "explicit_const", "bool_const", "operation",
  "numeric_operation", "comparison_operation", "boolean_operation",
  "sign_operation", YY_NULLPTR
  };
  return yy_sname[yysymbol];
}
#endif

#define YYPACT_NINF (-98)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-104)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     324,   341,   -26,    25,    -3,     2,   -10,   197,   341,   108,
      19,   266,   -98,    31,     8,    82,   324,   -98,   -98,   -98,
     -98,   -98,   -98,   341,   -98,   -98,   -98,   -98,   -98,   -98,
     -98,   -98,   -98,    42,    81,   341,   -98,   -31,   197,   -24,
      58,   266,   -41,   -98,    62,    66,   -98,   -98,   -98,   -98,
     -43,   -98,   -98,   -98,   266,   266,   266,   266,   105,   557,
     574,   -98,   591,   -98,   -98,   608,   625,   -98,   124,   -98,
     266,   -14,   -98,   -98,   574,   -98,   -98,   -98,    90,   574,
      11,   266,   266,    62,   -98,   -98,   -98,   127,   266,   -98,
     -98,   266,     5,   -98,   107,   266,   266,   389,    68,    39,
     -10,   266,   266,   674,    27,    27,   491,   341,   266,   266,
     266,   266,   266,   266,   266,   266,   266,   266,   266,   266,
     266,   141,   513,   108,   104,    39,   266,    68,    32,   574,
     355,   -98,   133,   574,   574,   -98,   -98,   -98,   110,   128,
     266,   406,   423,   113,   266,   -98,   -98,   -98,   144,   123,
      59,   -98,   -98,    70,   338,   642,   119,   674,   659,   -98,
      47,    47,    47,    47,    47,    47,    27,    27,   -98,   -98,
     -98,   -98,   -98,   -98,    98,   574,   131,   -98,   -98,   266,
     -98,   -98,   266,   266,   440,   125,   126,   266,   457,   132,
     121,   137,    39,   -98,   129,   341,   169,   -98,   266,   574,
     535,   574,   135,   266,   266,   238,   142,   121,   266,   146,
     -98,   -98,    68,   -98,   266,   192,   -98,   574,   -98,   266,
     238,   238,   194,   266,   -98,   474,    26,   -98,   372,   196,
     238,   198,   206,   205,   274,   161,   164,   -98,   -98,   211,
     209,   213,   -98,    68,   118,   -98,   214,   -98,   -98,   -98,
     215,   -98,   189,   181,   -98,   148,   168,   -98
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       3,    33,     0,    52,     0,     0,     0,     0,    33,     0,
       0,     0,    12,     0,    46,     0,     2,     5,    36,    37,
       8,     9,     7,    33,     6,    11,    14,    15,    16,    17,
      18,    19,    20,     0,     0,    32,    35,     0,     0,     0,
       0,     0,     0,    64,    84,    60,    62,    63,   100,    99,
      84,    97,    95,    96,     0,     0,     0,     0,     0,    71,
       0,    90,    72,    93,   101,    73,    74,   104,     0,    70,
       0,    65,    68,    89,    69,    98,   102,   103,    28,    13,
       0,     0,     0,    85,    87,     1,     4,     0,     0,    59,
      34,     0,     0,    53,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   118,   119,   120,     0,    33,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    49,
       0,    86,     0,    10,    25,    78,    76,    77,    79,     0,
       0,     0,     0,     0,     0,    82,    83,    30,     0,     0,
       0,    39,    61,     0,     0,    75,     0,   116,   117,   109,
     113,   114,   115,   110,   111,   112,   105,   106,   107,   108,
      54,    94,    67,    66,     0,    21,    23,    22,    47,     0,
      88,    27,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    91,     0,    33,     0,    29,     0,    48,
       0,    26,     0,     0,     0,    33,     0,     0,     0,    79,
      40,    42,     0,    38,     0,     0,    50,    24,    80,     0,
      33,    33,     0,     0,    41,     0,     0,    31,     0,     0,
      33,     0,     0,     0,     0,     0,     0,    92,    51,     0,
       0,     0,    55,     0,     0,    43,     0,    57,    56,    81,
       0,    58,     0,    79,    44,     0,     0,    45
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
     -98,   -98,   -98,   227,   -98,   -98,   -98,   -98,   -98,   -98,
      14,   -98,     3,   134,    54,    45,   -98,   156,   -98,   -98,
     -98,   -98,   -98,   -98,   -98,   149,   -98,   -98,   138,   224,
     -86,   139,   -97,    20,   -98,   182,    -7,   -98,     1,   -98,
     -98,     4,     6,   -98
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_uint8 yydefgoto[] =
{
       0,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      34,    35,    36,   150,   151,   210,    25,   128,    26,    27,
      28,    29,    30,    31,    45,    46,    32,    71,    72,    58,
     145,   146,   211,    73,    83,    84,   200,    61,    75,    63,
      64,    76,    77,    67
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      60,   147,    74,    24,    79,    39,   139,    37,    62,    94,
     135,    65,    91,    66,   101,    98,    99,    43,   102,    24,
      33,    33,    68,    44,   136,    92,    47,    59,    33,   137,
      40,    60,    95,   138,    97,    42,    33,    87,    90,    62,
      48,   176,    65,    33,    66,   123,   124,   103,   104,   105,
     106,   -84,    78,    41,   126,    33,    49,    38,    59,    50,
      51,    52,    53,   122,    80,    81,   110,   127,    54,    82,
     148,   144,   149,   135,   129,   130,    55,    56,   236,   119,
     120,   133,    85,    70,   134,    88,   110,   136,   141,   142,
     178,   179,   137,    89,   129,   154,   138,   117,   118,   119,
     120,   157,   158,   159,   160,   161,   162,   163,   164,   165,
     166,   167,   168,   169,    96,   227,    74,   191,   192,   175,
      47,   156,    48,    82,   208,   100,   135,    33,   193,   179,
     195,   196,    48,   184,   107,    69,   121,   188,    49,   132,
     136,    50,    51,    52,    53,   137,   249,   125,    49,   209,
      54,    50,    51,    52,    53,   254,   197,   192,    55,    56,
      54,   170,    48,   140,   173,    70,   181,   182,    55,    56,
     250,   183,   199,   187,   198,    70,   201,   189,    49,   190,
     205,    50,    51,    52,    53,   203,   204,   216,   207,   214,
      54,   217,   144,   212,   135,   219,   220,   221,    55,    56,
     256,   225,   223,   226,   229,    70,   233,   228,   136,   215,
     240,    48,   230,   137,   238,    33,   234,   253,   241,   222,
     242,   244,   245,   246,   247,    33,   257,    49,   248,   251,
      50,    51,    52,    53,   231,   232,   252,   234,   255,    54,
      33,    33,     1,    86,   239,     2,   213,    55,    56,   152,
      33,     3,   224,     4,    57,     6,     7,   153,     8,   174,
       9,   172,    93,    11,    12,   131,   177,     0,     0,    13,
       0,    14,     0,     0,     0,   108,   109,   110,   111,   112,
      48,     0,   113,     0,   114,   115,   116,     0,   117,   118,
     119,   120,     0,     0,     0,   243,    49,     0,     0,    50,
      51,    52,    53,     0,     0,     0,     0,     0,    54,     0,
       0,   108,   109,   110,   111,   112,    55,    56,   113,     0,
     114,   115,   116,    70,   117,   118,   119,   120,     1,     0,
       0,     2,     0,     0,     0,     0,     0,     3,     0,     4,
       5,     6,     7,     0,     8,     1,     9,    10,     2,    11,
      12,     0,     0,     0,     3,    13,     4,    14,     6,     7,
       0,     8,     0,     9,     0,     0,    11,    12,     0,     0,
       0,     0,    13,     0,    14,   108,   109,   110,   111,   112,
       0,     0,   113,     0,   114,   115,   116,     0,   117,   118,
     119,   120,   108,   109,   110,   111,   112,     0,   194,   113,
     180,   114,   115,   116,     0,   117,   118,   119,   120,   108,
     109,   110,   111,   112,     0,     0,   113,   180,   114,   115,
     116,     0,   117,   118,   119,   120,   108,   109,   110,   111,
     112,     0,     0,   113,   237,   114,   115,   116,     0,   117,
     118,   119,   120,   108,   109,   110,   111,   112,     0,   143,
     113,     0,   114,   115,   116,     0,   117,   118,   119,   120,
     108,   109,   110,   111,   112,     0,   185,   113,     0,   114,
     115,   116,     0,   117,   118,   119,   120,   108,   109,   110,
     111,   112,     0,   186,   113,     0,   114,   115,   116,     0,
     117,   118,   119,   120,   108,   109,   110,   111,   112,     0,
     202,   113,     0,   114,   115,   116,     0,   117,   118,   119,
     120,   108,   109,   110,   111,   112,     0,   206,   113,     0,
     114,   115,   116,     0,   117,   118,   119,   120,   108,   109,
     110,   111,   112,     0,   235,   113,     0,   114,   115,   116,
       0,   117,   118,   119,   120,     0,     0,     0,     0,   155,
     108,   109,   110,   111,   112,     0,     0,   113,     0,   114,
     115,   116,     0,   117,   118,   119,   120,     0,     0,     0,
       0,   171,   108,   109,   110,   111,   112,     0,     0,   113,
       0,   114,   115,   116,     0,   117,   118,   119,   120,     0,
       0,     0,     0,   218,   -89,   -89,   -89,   -89,   -89,     0,
       0,   -89,     0,   -89,   -89,   -89,     0,   -89,   -89,   -89,
     -89,   108,   109,   110,   111,   112,     0,     0,   113,     0,
     114,   115,   116,     0,   117,   118,   119,   120,   -98,   -98,
     -98,   -98,   -98,     0,     0,   -98,     0,   -98,   -98,   -98,
       0,   -98,   -98,   -98,   -98,  -102,  -102,  -102,  -102,  -102,
       0,     0,  -102,     0,  -102,  -102,  -102,     0,  -102,  -102,
    -102,  -102,  -103,  -103,  -103,  -103,  -103,     0,     0,  -103,
       0,  -103,  -103,  -103,     0,  -103,  -103,  -103,  -103,   -94,
     -94,   -94,   -94,   -94,     0,     0,   -94,     0,   -94,   -94,
     -94,     0,   -94,   -94,   -94,   -94,   108,     0,   110,   111,
     112,     0,     0,   113,     0,   114,   115,   116,     0,   117,
     118,   119,   120,   110,   111,   112,     0,     0,   113,     0,
     114,   115,   116,     0,   117,   118,   119,   120
};

static const yytype_int16 yycheck[] =
{
       7,    98,     9,     0,    11,     8,    92,    33,     7,    33,
       5,     7,    43,     7,    57,    56,    57,    27,    61,    16,
       0,     1,     8,    33,    19,    56,     6,     7,     8,    24,
      33,    38,    56,    28,    41,    33,    16,    23,    35,    38,
      14,   127,    38,    23,    38,    59,    60,    54,    55,    56,
      57,    43,    33,    56,    43,    35,    30,    32,    38,    33,
      34,    35,    36,    70,    33,    57,    39,    56,    42,    61,
      31,     3,    33,     5,    81,    82,    50,    51,    52,    52,
      53,    88,     0,    57,    91,    43,    39,    19,    95,    96,
      58,    59,    24,    12,   101,   102,    28,    50,    51,    52,
      53,   108,   109,   110,   111,   112,   113,   114,   115,   116,
     117,   118,   119,   120,    56,   212,   123,    58,    59,   126,
     100,   107,    14,    61,     3,    59,     5,   107,    58,    59,
      11,    12,    14,   140,    29,    27,    12,   144,    30,    12,
      19,    33,    34,    35,    36,    24,   243,    57,    30,    28,
      42,    33,    34,    35,    36,   252,    58,    59,    50,    51,
      42,    20,    14,    56,    60,    57,    33,    57,    50,    51,
      52,    43,   179,    60,    43,    57,   183,    33,    30,    56,
     187,    33,    34,    35,    36,    60,    60,    18,    56,    60,
      42,   198,     3,    56,     5,    60,   203,   204,    50,    51,
      52,   208,    60,    57,    12,    57,    12,   214,    19,   195,
      12,    14,   219,    24,    18,   195,   223,    28,    12,   205,
      15,    60,    58,    12,    15,   205,    58,    30,    15,    15,
      33,    34,    35,    36,   220,   221,    21,   244,    57,    42,
     220,   221,     4,    16,   230,     7,   192,    50,    51,   100,
     230,    13,   207,    15,    57,    17,    18,   101,    20,   125,
      22,   123,    38,    25,    26,    83,   127,    -1,    -1,    31,
      -1,    33,    -1,    -1,    -1,    37,    38,    39,    40,    41,
      14,    -1,    44,    -1,    46,    47,    48,    -1,    50,    51,
      52,    53,    -1,    -1,    -1,    21,    30,    -1,    -1,    33,
      34,    35,    36,    -1,    -1,    -1,    -1,    -1,    42,    -1,
      -1,    37,    38,    39,    40,    41,    50,    51,    44,    -1,
      46,    47,    48,    57,    50,    51,    52,    53,     4,    -1,
      -1,     7,    -1,    -1,    -1,    -1,    -1,    13,    -1,    15,
      16,    17,    18,    -1,    20,     4,    22,    23,     7,    25,
      26,    -1,    -1,    -1,    13,    31,    15,    33,    17,    18,
      -1,    20,    -1,    22,    -1,    -1,    25,    26,    -1,    -1,
      -1,    -1,    31,    -1,    33,    37,    38,    39,    40,    41,
      -1,    -1,    44,    -1,    46,    47,    48,    -1,    50,    51,
      52,    53,    37,    38,    39,    40,    41,    -1,    60,    44,
      62,    46,    47,    48,    -1,    50,    51,    52,    53,    37,
      38,    39,    40,    41,    -1,    -1,    44,    62,    46,    47,
      48,    -1,    50,    51,    52,    53,    37,    38,    39,    40,
      41,    -1,    -1,    44,    62,    46,    47,    48,    -1,    50,
      51,    52,    53,    37,    38,    39,    40,    41,    -1,    60,
      44,    -1,    46,    47,    48,    -1,    50,    51,    52,    53,
      37,    38,    39,    40,    41,    -1,    60,    44,    -1,    46,
      47,    48,    -1,    50,    51,    52,    53,    37,    38,    39,
      40,    41,    -1,    60,    44,    -1,    46,    47,    48,    -1,
      50,    51,    52,    53,    37,    38,    39,    40,    41,    -1,
      60,    44,    -1,    46,    47,    48,    -1,    50,    51,    52,
      53,    37,    38,    39,    40,    41,    -1,    60,    44,    -1,
      46,    47,    48,    -1,    50,    51,    52,    53,    37,    38,
      39,    40,    41,    -1,    60,    44,    -1,    46,    47,    48,
      -1,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    58,
      37,    38,    39,    40,    41,    -1,    -1,    44,    -1,    46,
      47,    48,    -1,    50,    51,    52,    53,    -1,    -1,    -1,
      -1,    58,    37,    38,    39,    40,    41,    -1,    -1,    44,
      -1,    46,    47,    48,    -1,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    58,    37,    38,    39,    40,    41,    -1,
      -1,    44,    -1,    46,    47,    48,    -1,    50,    51,    52,
      53,    37,    38,    39,    40,    41,    -1,    -1,    44,    -1,
      46,    47,    48,    -1,    50,    51,    52,    53,    37,    38,
      39,    40,    41,    -1,    -1,    44,    -1,    46,    47,    48,
      -1,    50,    51,    52,    53,    37,    38,    39,    40,    41,
      -1,    -1,    44,    -1,    46,    47,    48,    -1,    50,    51,
      52,    53,    37,    38,    39,    40,    41,    -1,    -1,    44,
      -1,    46,    47,    48,    -1,    50,    51,    52,    53,    37,
      38,    39,    40,    41,    -1,    -1,    44,    -1,    46,    47,
      48,    -1,    50,    51,    52,    53,    37,    -1,    39,    40,
      41,    -1,    -1,    44,    -1,    46,    47,    48,    -1,    50,
      51,    52,    53,    39,    40,    41,    -1,    -1,    44,    -1,
      46,    47,    48,    -1,    50,    51,    52,    53
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     4,     7,    13,    15,    16,    17,    18,    20,    22,
      23,    25,    26,    31,    33,    64,    65,    66,    67,    68,
      69,    70,    71,    72,    75,    79,    81,    82,    83,    84,
      85,    86,    89,    96,    73,    74,    75,    33,    32,     8,
      33,    56,    33,    27,    33,    87,    88,    96,    14,    30,
      33,    34,    35,    36,    42,    50,    51,    57,    92,    96,
      99,   100,   101,   102,   103,   104,   105,   106,    73,    27,
      57,    90,    91,    96,    99,   101,   104,   105,    33,    99,
      33,    57,    61,    97,    98,     0,    66,    73,    43,    12,
      75,    43,    56,    92,    33,    56,    56,    99,    56,    57,
      59,    57,    61,    99,    99,    99,    99,    29,    37,    38,
      39,    40,    41,    44,    46,    47,    48,    50,    51,    52,
      53,    12,    99,    59,    60,    57,    43,    56,    80,    99,
      99,    98,    12,    99,    99,     5,    19,    24,    28,    93,
      56,    99,    99,    60,     3,    93,    94,    95,    31,    33,
      76,    77,    88,    80,    99,    58,    73,    99,    99,    99,
      99,    99,    99,    99,    99,    99,    99,    99,    99,    99,
      20,    58,    91,    60,    76,    99,    93,    94,    58,    59,
      62,    33,    57,    43,    99,    60,    60,    60,    99,    33,
      56,    58,    59,    58,    60,    11,    12,    58,    43,    99,
      99,    99,    60,    60,    60,    99,    60,    56,     3,    28,
      78,    95,    56,    77,    60,    73,    18,    99,    58,    60,
      99,    99,    73,    60,    78,    99,    57,    95,    99,    12,
      99,    73,    73,    12,    99,    60,    52,    62,    18,    73,
      12,    12,    15,    21,    60,    58,    12,    15,    15,    95,
      52,    15,    21,    28,    95,    57,    52,    58
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    63,    64,    64,    65,    65,    66,    66,    67,    67,
      68,    68,    68,    68,    68,    68,    68,    68,    68,    68,
      68,    69,    69,    69,    69,    70,    70,    71,    72,    72,
      72,    72,    73,    73,    74,    74,    75,    75,    76,    76,
      77,    77,    78,    78,    78,    78,    79,    79,    80,    80,
      81,    81,    82,    82,    83,    84,    84,    84,    84,    85,
      86,    87,    87,    88,    88,    89,    89,    90,    90,    91,
      91,    92,    92,    92,    92,    92,    93,    93,    93,    93,
      93,    94,    95,    95,    96,    96,    97,    97,    98,    99,
      99,    99,    99,    99,    99,   100,   100,   100,   100,   101,
     101,   102,   102,   102,   102,   103,   103,   103,   103,   103,
     104,   104,   104,   104,   104,   104,   105,   105,   105,   106,
     106
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     0,     2,     1,     1,     1,     1,     1,
       3,     1,     1,     2,     1,     1,     1,     1,     1,     1,
       1,     4,     4,     4,     6,     4,     6,     4,     2,     5,
       4,     7,     1,     0,     2,     1,     1,     1,     3,     1,
       3,     4,     1,     4,     7,    10,     1,     4,     3,     1,
       6,     8,     1,     3,     4,     9,    10,    10,    11,     3,
       2,     3,     1,     1,     1,     2,     4,     3,     1,     1,
       1,     1,     1,     1,     1,     3,     1,     1,     1,     1,
       4,     7,     1,     1,     1,     2,     2,     1,     3,     1,
       1,     4,     7,     1,     3,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     2,     2,
       2
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


/* Context of a parse error.  */
typedef struct
{
  yy_state_t *yyssp;
  yysymbol_kind_t yytoken;
} yypcontext_t;

/* Put in YYARG at most YYARGN of the expected tokens given the
   current YYCTX, and return the number of tokens stored in YYARG.  If
   YYARG is null, return the number of expected tokens (guaranteed to
   be less than YYNTOKENS).  Return YYENOMEM on memory exhaustion.
   Return 0 if there are more than YYARGN expected tokens, yet fill
   YYARG up to YYARGN. */
static int
yypcontext_expected_tokens (const yypcontext_t *yyctx,
                            yysymbol_kind_t yyarg[], int yyargn)
{
  /* Actual size of YYARG. */
  int yycount = 0;
  int yyn = yypact[+*yyctx->yyssp];
  if (!yypact_value_is_default (yyn))
    {
      /* Start YYX at -YYN if negative to avoid negative indexes in
         YYCHECK.  In other words, skip the first -YYN actions for
         this state because they are default actions.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;
      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yyx;
      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
        if (yycheck[yyx + yyn] == yyx && yyx != YYSYMBOL_YYerror
            && !yytable_value_is_error (yytable[yyx + yyn]))
          {
            if (!yyarg)
              ++yycount;
            else if (yycount == yyargn)
              return 0;
            else
              yyarg[yycount++] = YY_CAST (yysymbol_kind_t, yyx);
          }
    }
  if (yyarg && yycount == 0 && 0 < yyargn)
    yyarg[0] = YYSYMBOL_YYEMPTY;
  return yycount;
}




#ifndef yystrlen
# if defined __GLIBC__ && defined _STRING_H
#  define yystrlen(S) (YY_CAST (YYPTRDIFF_T, strlen (S)))
# else
/* Return the length of YYSTR.  */
static YYPTRDIFF_T
yystrlen (const char *yystr)
{
  YYPTRDIFF_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
# endif
#endif

#ifndef yystpcpy
# if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#  define yystpcpy stpcpy
# else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
# endif
#endif



static int
yy_syntax_error_arguments (const yypcontext_t *yyctx,
                           yysymbol_kind_t yyarg[], int yyargn)
{
  /* Actual size of YYARG. */
  int yycount = 0;
  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yyctx->yytoken != YYSYMBOL_YYEMPTY)
    {
      int yyn;
      if (yyarg)
        yyarg[yycount] = yyctx->yytoken;
      ++yycount;
      yyn = yypcontext_expected_tokens (yyctx,
                                        yyarg ? yyarg + 1 : yyarg, yyargn - 1);
      if (yyn == YYENOMEM)
        return YYENOMEM;
      else
        yycount += yyn;
    }
  return yycount;
}

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return -1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return YYENOMEM if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYPTRDIFF_T *yymsg_alloc, char **yymsg,
                const yypcontext_t *yyctx)
{
  enum { YYARGS_MAX = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat: reported tokens (one for the "unexpected",
     one per "expected"). */
  yysymbol_kind_t yyarg[YYARGS_MAX];
  /* Cumulated lengths of YYARG.  */
  YYPTRDIFF_T yysize = 0;

  /* Actual size of YYARG. */
  int yycount = yy_syntax_error_arguments (yyctx, yyarg, YYARGS_MAX);
  if (yycount == YYENOMEM)
    return YYENOMEM;

  switch (yycount)
    {
#define YYCASE_(N, S)                       \
      case N:                               \
        yyformat = S;                       \
        break
    default: /* Avoid compiler warnings. */
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
#undef YYCASE_
    }

  /* Compute error message size.  Don't count the "%s"s, but reserve
     room for the terminator.  */
  yysize = yystrlen (yyformat) - 2 * yycount + 1;
  {
    int yyi;
    for (yyi = 0; yyi < yycount; ++yyi)
      {
        YYPTRDIFF_T yysize1
          = yysize + yystrlen (yysymbol_name (yyarg[yyi]));
        if (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM)
          yysize = yysize1;
        else
          return YYENOMEM;
      }
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return -1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp = yystpcpy (yyp, yysymbol_name (yyarg[yyi++]));
          yyformat += 2;
        }
      else
        {
          ++yyp;
          ++yyformat;
        }
  }
  return 0;
}


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYPTRDIFF_T yymsg_alloc = sizeof yymsgbuf;

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* program: decl_or_stmt_in_main_program_list  */
#line 59 "src/st.y"
  { ; }
#line 1762 "src/st-parse.c"
    break;

  case 3: /* program: %empty  */
#line 61 "src/st.y"
  { ; }
#line 1768 "src/st-parse.c"
    break;

  case 4: /* decl_or_stmt_in_main_program_list: decl_or_stmt_in_main_program_list decl_or_stmt_in_main_program  */
#line 66 "src/st.y"
  { ; }
#line 1774 "src/st-parse.c"
    break;

  case 5: /* decl_or_stmt_in_main_program_list: decl_or_stmt_in_main_program  */
#line 68 "src/st.y"
  { ; }
#line 1780 "src/st-parse.c"
    break;

  case 6: /* decl_or_stmt_in_main_program: decl_or_stmt  */
#line 77 "src/st.y"
  { ; }
#line 1786 "src/st-parse.c"
    break;

  case 7: /* decl_or_stmt_in_main_program: subprog_decl  */
#line 79 "src/st.y"
  { ; }
#line 1792 "src/st-parse.c"
    break;

  case 8: /* decl: var_decl  */
#line 84 "src/st.y"
  { ; }
#line 1798 "src/st-parse.c"
    break;

  case 9: /* decl: const_decl  */
#line 86 "src/st.y"
  { ; }
#line 1804 "src/st-parse.c"
    break;

  case 10: /* stmt: var_ref ASSIGN expr  */
#line 91 "src/st.y"
  { ; }
#line 1810 "src/st-parse.c"
    break;

  case 11: /* stmt: subprog_call  */
#line 93 "src/st.y"
  { ; }
#line 1816 "src/st-parse.c"
    break;

  case 12: /* stmt: RETURN  */
#line 95 "src/st.y"
  { ; }
#line 1822 "src/st-parse.c"
    break;

  case 13: /* stmt: RESULT expr  */
#line 97 "src/st.y"
  { ; }
#line 1828 "src/st-parse.c"
    break;

  case 14: /* stmt: if_stmt  */
#line 99 "src/st.y"
  { ; }
#line 1834 "src/st-parse.c"
    break;

  case 15: /* stmt: exit_stmt  */
#line 101 "src/st.y"
  { ; }
#line 1840 "src/st-parse.c"
    break;

  case 16: /* stmt: loop_stmt  */
#line 103 "src/st.y"
  { ; }
#line 1846 "src/st-parse.c"
    break;

  case 17: /* stmt: for_stmt  */
#line 105 "src/st.y"
  { ; }
#line 1852 "src/st-parse.c"
    break;

  case 18: /* stmt: block  */
#line 107 "src/st.y"
  { ; }
#line 1858 "src/st-parse.c"
    break;

  case 19: /* stmt: get_stmt  */
#line 109 "src/st.y"
  { ; }
#line 1864 "src/st-parse.c"
    break;

  case 20: /* stmt: put_stmt  */
#line 111 "src/st.y"
  { ; }
#line 1870 "src/st-parse.c"
    break;

  case 21: /* var_decl: VAR ID ASSIGN expr  */
#line 116 "src/st.y"
  { ; }
#line 1876 "src/st-parse.c"
    break;

  case 22: /* var_decl: VAR ID ':' array_type  */
#line 118 "src/st.y"
  { ; }
#line 1882 "src/st-parse.c"
    break;

  case 23: /* var_decl: VAR ID ':' scalar_type  */
#line 120 "src/st.y"
  { ; }
#line 1888 "src/st-parse.c"
    break;

  case 24: /* var_decl: VAR ID ':' scalar_type ASSIGN expr  */
#line 122 "src/st.y"
  { ; }
#line 1894 "src/st-parse.c"
    break;

  case 25: /* const_decl: CONST ID ASSIGN expr  */
#line 127 "src/st.y"
  { ; }
#line 1900 "src/st-parse.c"
    break;

  case 26: /* const_decl: CONST ID ':' scalar_type ASSIGN expr  */
#line 129 "src/st.y"
  { ; }
#line 1906 "src/st-parse.c"
    break;

  case 27: /* subprog_decl: subprog_header opt_decl_or_stmt_list END ID  */
#line 134 "src/st.y"
  { ; }
#line 1912 "src/st-parse.c"
    break;

  case 28: /* subprog_header: PROCEDURE ID  */
#line 139 "src/st.y"
  { ; }
#line 1918 "src/st-parse.c"
    break;

  case 29: /* subprog_header: PROCEDURE ID '(' formal_decl_list ')'  */
#line 141 "src/st.y"
  { ; }
#line 1924 "src/st-parse.c"
    break;

  case 30: /* subprog_header: FUNCTION ID ':' type  */
#line 143 "src/st.y"
  { ; }
#line 1930 "src/st-parse.c"
    break;

  case 31: /* subprog_header: FUNCTION ID '(' formal_decl_list ')' ':' type  */
#line 145 "src/st.y"
  { ; }
#line 1936 "src/st-parse.c"
    break;

  case 32: /* opt_decl_or_stmt_list: decl_or_stmt_list  */
#line 150 "src/st.y"
  { ; }
#line 1942 "src/st-parse.c"
    break;

  case 33: /* opt_decl_or_stmt_list: %empty  */
#line 152 "src/st.y"
  { ; }
#line 1948 "src/st-parse.c"
    break;

  case 34: /* decl_or_stmt_list: decl_or_stmt_list decl_or_stmt  */
#line 157 "src/st.y"
  { ; }
#line 1954 "src/st-parse.c"
    break;

  case 35: /* decl_or_stmt_list: decl_or_stmt  */
#line 159 "src/st.y"
  { ; }
#line 1960 "src/st-parse.c"
    break;

  case 36: /* decl_or_stmt: decl  */
#line 164 "src/st.y"
  { ; }
#line 1966 "src/st-parse.c"
    break;

  case 37: /* decl_or_stmt: stmt  */
#line 166 "src/st.y"
  { ; }
#line 1972 "src/st-parse.c"
    break;

  case 38: /* formal_decl_list: formal_decl_list ',' formal_decl  */
#line 171 "src/st.y"
  { ; }
#line 1978 "src/st-parse.c"
    break;

  case 39: /* formal_decl_list: formal_decl  */
#line 173 "src/st.y"
  { ; }
#line 1984 "src/st-parse.c"
    break;

  case 40: /* formal_decl: ID ':' formal_type  */
#line 178 "src/st.y"
  { ; }
#line 1990 "src/st-parse.c"
    break;

  case 41: /* formal_decl: VAR ID ':' formal_type  */
#line 180 "src/st.y"
  { ; }
#line 1996 "src/st-parse.c"
    break;

  case 42: /* formal_type: type  */
#line 185 "src/st.y"
  { ; }
#line 2002 "src/st-parse.c"
    break;

  case 43: /* formal_type: STRING '(' '*' ')'  */
#line 187 "src/st.y"
  { ; }
#line 2008 "src/st-parse.c"
    break;

  case 44: /* formal_type: ARRAY expr '.' '.' '*' OF type  */
#line 189 "src/st.y"
  { ; }
#line 2014 "src/st-parse.c"
    break;

  case 45: /* formal_type: ARRAY expr '.' '.' '*' OF STRING '(' '*' ')'  */
#line 191 "src/st.y"
  { ; }
#line 2020 "src/st-parse.c"
    break;

  case 46: /* subprog_call: ID  */
#line 196 "src/st.y"
  { ; }
#line 2026 "src/st-parse.c"
    break;

  case 47: /* subprog_call: ID '(' actual_list ')'  */
#line 198 "src/st.y"
  { ; }
#line 2032 "src/st-parse.c"
    break;

  case 48: /* actual_list: actual_list ',' expr  */
#line 203 "src/st.y"
  { ; }
#line 2038 "src/st-parse.c"
    break;

  case 49: /* actual_list: expr  */
#line 205 "src/st.y"
  { ; }
#line 2044 "src/st-parse.c"
    break;

  case 50: /* if_stmt: IF bool_expr THEN opt_decl_or_stmt_list END IF  */
#line 210 "src/st.y"
  { ; }
#line 2050 "src/st-parse.c"
    break;

  case 51: /* if_stmt: IF bool_expr THEN opt_decl_or_stmt_list ELSE opt_decl_or_stmt_list END IF  */
#line 212 "src/st.y"
  { ; }
#line 2056 "src/st-parse.c"
    break;

  case 52: /* exit_stmt: EXIT  */
#line 217 "src/st.y"
  { ; }
#line 2062 "src/st-parse.c"
    break;

  case 53: /* exit_stmt: EXIT WHEN bool_expr  */
#line 219 "src/st.y"
  { ; }
#line 2068 "src/st-parse.c"
    break;

  case 54: /* loop_stmt: LOOP opt_decl_or_stmt_list END LOOP  */
#line 224 "src/st.y"
  { ; }
#line 2074 "src/st-parse.c"
    break;

  case 55: /* for_stmt: FOR ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR  */
#line 229 "src/st.y"
  { ; }
#line 2080 "src/st-parse.c"
    break;

  case 56: /* for_stmt: FOR ID ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR  */
#line 231 "src/st.y"
  { ; }
#line 2086 "src/st-parse.c"
    break;

  case 57: /* for_stmt: FOR DECREASING ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR  */
#line 233 "src/st.y"
  { ; }
#line 2092 "src/st-parse.c"
    break;

  case 58: /* for_stmt: FOR DECREASING ID ':' expr '.' '.' expr opt_decl_or_stmt_list END FOR  */
#line 235 "src/st.y"
  { ; }
#line 2098 "src/st-parse.c"
    break;

  case 59: /* block: BEGIN_ opt_decl_or_stmt_list END  */
#line 240 "src/st.y"
  { ; }
#line 2104 "src/st-parse.c"
    break;

  case 60: /* get_stmt: GET get_item_list  */
#line 245 "src/st.y"
  { ; }
#line 2110 "src/st-parse.c"
    break;

  case 61: /* get_item_list: get_item_list ',' get_item  */
#line 250 "src/st.y"
  { ; }
#line 2116 "src/st-parse.c"
    break;

  case 62: /* get_item_list: get_item  */
#line 252 "src/st.y"
  { ; }
#line 2122 "src/st-parse.c"
    break;

  case 63: /* get_item: var_ref  */
#line 257 "src/st.y"
  { ; }
#line 2128 "src/st-parse.c"
    break;

  case 64: /* get_item: SKIP  */
#line 259 "src/st.y"
  { ; }
#line 2134 "src/st-parse.c"
    break;

  case 65: /* put_stmt: PUT put_item_list  */
#line 264 "src/st.y"
  { ; }
#line 2140 "src/st-parse.c"
    break;

  case 66: /* put_stmt: PUT put_item_list '.' '.'  */
#line 266 "src/st.y"
  { ; }
#line 2146 "src/st-parse.c"
    break;

  case 67: /* put_item_list: put_item_list ',' put_item  */
#line 271 "src/st.y"
  { ; }
#line 2152 "src/st-parse.c"
    break;

  case 68: /* put_item_list: put_item  */
#line 273 "src/st.y"
  { ; }
#line 2158 "src/st-parse.c"
    break;

  case 69: /* put_item: expr  */
#line 278 "src/st.y"
  { ; }
#line 2164 "src/st-parse.c"
    break;

  case 70: /* put_item: SKIP  */
#line 280 "src/st.y"
  { ; }
#line 2170 "src/st-parse.c"
    break;

  case 71: /* bool_expr: var_ref  */
#line 285 "src/st.y"
  { ; }
#line 2176 "src/st-parse.c"
    break;

  case 72: /* bool_expr: bool_const  */
#line 287 "src/st.y"
  { ; }
#line 2182 "src/st-parse.c"
    break;

  case 73: /* bool_expr: comparison_operation  */
#line 289 "src/st.y"
  { ; }
#line 2188 "src/st-parse.c"
    break;

  case 74: /* bool_expr: boolean_operation  */
#line 291 "src/st.y"
  { ; }
#line 2194 "src/st-parse.c"
    break;

  case 75: /* bool_expr: '(' expr ')'  */
#line 301 "src/st.y"
  { ; }
#line 2200 "src/st-parse.c"
    break;

  case 76: /* scalar_type: INT  */
#line 306 "src/st.y"
  { ; }
#line 2206 "src/st-parse.c"
    break;

  case 77: /* scalar_type: REAL  */
#line 308 "src/st.y"
  { ; }
#line 2212 "src/st-parse.c"
    break;

  case 78: /* scalar_type: BOOL  */
#line 310 "src/st.y"
  { ; }
#line 2218 "src/st-parse.c"
    break;

  case 79: /* scalar_type: STRING  */
#line 312 "src/st.y"
  { ; }
#line 2224 "src/st-parse.c"
    break;

  case 80: /* scalar_type: STRING '(' expr ')'  */
#line 314 "src/st.y"
  { ; }
#line 2230 "src/st-parse.c"
    break;

  case 81: /* array_type: ARRAY expr '.' '.' expr OF type  */
#line 319 "src/st.y"
  { ; }
#line 2236 "src/st-parse.c"
    break;

  case 82: /* type: scalar_type  */
#line 324 "src/st.y"
  { ; }
#line 2242 "src/st-parse.c"
    break;

  case 83: /* type: array_type  */
#line 326 "src/st.y"
  { ; }
#line 2248 "src/st-parse.c"
    break;

  case 84: /* var_ref: ID  */
#line 334 "src/st.y"
  { ; }
#line 2254 "src/st-parse.c"
    break;

  case 85: /* var_ref: ID subscript_list  */
#line 339 "src/st.y"
  { ; }
#line 2260 "src/st-parse.c"
    break;

  case 86: /* subscript_list: subscript_list subscript  */
#line 344 "src/st.y"
  { ; }
#line 2266 "src/st-parse.c"
    break;

  case 87: /* subscript_list: subscript  */
#line 346 "src/st.y"
  { ; }
#line 2272 "src/st-parse.c"
    break;

  case 88: /* subscript: '[' expr ']'  */
#line 351 "src/st.y"
  { ; }
#line 2278 "src/st-parse.c"
    break;

  case 89: /* expr: var_ref  */
#line 356 "src/st.y"
  { ; }
#line 2284 "src/st-parse.c"
    break;

  case 90: /* expr: explicit_const  */
#line 358 "src/st.y"
  { ; }
#line 2290 "src/st-parse.c"
    break;

  case 91: /* expr: ID '(' actual_list ')'  */
#line 368 "src/st.y"
  { ; }
#line 2296 "src/st-parse.c"
    break;

  case 92: /* expr: ID '[' expr '.' '.' expr ']'  */
#line 378 "src/st.y"
  { ; }
#line 2302 "src/st-parse.c"
    break;

  case 93: /* expr: operation  */
#line 380 "src/st.y"
  { ; }
#line 2308 "src/st-parse.c"
    break;

  case 94: /* expr: '(' expr ')'  */
#line 382 "src/st.y"
  { ; }
#line 2314 "src/st-parse.c"
    break;

  case 95: /* explicit_const: INT_CONST  */
#line 387 "src/st.y"
  { ; }
#line 2320 "src/st-parse.c"
    break;

  case 96: /* explicit_const: REAL_CONST  */
#line 389 "src/st.y"
  { ; }
#line 2326 "src/st-parse.c"
    break;

  case 97: /* explicit_const: STR_CONST  */
#line 391 "src/st.y"
  { ; }
#line 2332 "src/st-parse.c"
    break;

  case 98: /* explicit_const: bool_const  */
#line 393 "src/st.y"
  { ; }
#line 2338 "src/st-parse.c"
    break;

  case 99: /* bool_const: TRUE  */
#line 398 "src/st.y"
  { ; }
#line 2344 "src/st-parse.c"
    break;

  case 100: /* bool_const: FALSE  */
#line 400 "src/st.y"
  { ; }
#line 2350 "src/st-parse.c"
    break;

  case 101: /* operation: numeric_operation  */
#line 405 "src/st.y"
  { ; }
#line 2356 "src/st-parse.c"
    break;

  case 102: /* operation: comparison_operation  */
#line 407 "src/st.y"
  { ; }
#line 2362 "src/st-parse.c"
    break;

  case 103: /* operation: boolean_operation  */
#line 409 "src/st.y"
  { ; }
#line 2368 "src/st-parse.c"
    break;

  case 104: /* operation: sign_operation  */
#line 411 "src/st.y"
  { ; }
#line 2374 "src/st-parse.c"
    break;

  case 105: /* numeric_operation: expr '+' expr  */
#line 415 "src/st.y"
                {}
#line 2380 "src/st-parse.c"
    break;

  case 106: /* numeric_operation: expr '-' expr  */
#line 416 "src/st.y"
                {}
#line 2386 "src/st-parse.c"
    break;

  case 107: /* numeric_operation: expr '*' expr  */
#line 417 "src/st.y"
                {}
#line 2392 "src/st-parse.c"
    break;

  case 108: /* numeric_operation: expr '/' expr  */
#line 418 "src/st.y"
                {}
#line 2398 "src/st-parse.c"
    break;

  case 109: /* numeric_operation: expr MOD expr  */
#line 419 "src/st.y"
                {}
#line 2404 "src/st-parse.c"
    break;

  case 110: /* comparison_operation: expr '<' expr  */
#line 423 "src/st.y"
                {}
#line 2410 "src/st-parse.c"
    break;

  case 111: /* comparison_operation: expr '>' expr  */
#line 424 "src/st.y"
                {}
#line 2416 "src/st-parse.c"
    break;

  case 112: /* comparison_operation: expr '=' expr  */
#line 425 "src/st.y"
                {}
#line 2422 "src/st-parse.c"
    break;

  case 113: /* comparison_operation: expr LE expr  */
#line 426 "src/st.y"
               {}
#line 2428 "src/st-parse.c"
    break;

  case 114: /* comparison_operation: expr GE expr  */
#line 427 "src/st.y"
               {}
#line 2434 "src/st-parse.c"
    break;

  case 115: /* comparison_operation: expr NE expr  */
#line 428 "src/st.y"
               {}
#line 2440 "src/st-parse.c"
    break;

  case 116: /* boolean_operation: expr AND expr  */
#line 437 "src/st.y"
                {}
#line 2446 "src/st-parse.c"
    break;

  case 117: /* boolean_operation: expr OR expr  */
#line 438 "src/st.y"
               {}
#line 2452 "src/st-parse.c"
    break;

  case 118: /* boolean_operation: NOT expr  */
#line 439 "src/st.y"
           {}
#line 2458 "src/st-parse.c"
    break;

  case 119: /* sign_operation: '+' expr  */
#line 443 "src/st.y"
           {}
#line 2464 "src/st-parse.c"
    break;

  case 120: /* sign_operation: '-' expr  */
#line 444 "src/st.y"
           {}
#line 2470 "src/st-parse.c"
    break;


#line 2474 "src/st-parse.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      {
        yypcontext_t yyctx
          = {yyssp, yytoken};
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = yysyntax_error (&yymsg_alloc, &yymsg, &yyctx);
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == -1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = YY_CAST (char *,
                             YYSTACK_ALLOC (YY_CAST (YYSIZE_T, yymsg_alloc)));
            if (yymsg)
              {
                yysyntax_error_status
                  = yysyntax_error (&yymsg_alloc, &yymsg, &yyctx);
                yymsgp = yymsg;
              }
            else
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = YYENOMEM;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == YYENOMEM)
          YYNOMEM;
      }
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
  return yyresult;
}

#line 447 "src/st.y"


void yyerror(const char *msg) {
  fprintf(stderr, "line %d on symbol '%s': %s\n", yylineno, yytext, msg);
}
