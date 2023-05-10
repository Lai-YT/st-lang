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
  YYSYMBOL_bool_expr = 82,                 /* bool_expr  */
  YYSYMBOL_scalar_type = 83,               /* scalar_type  */
  YYSYMBOL_array_type = 84,                /* array_type  */
  YYSYMBOL_type = 85,                      /* type  */
  YYSYMBOL_var_ref = 86,                   /* var_ref  */
  YYSYMBOL_subscript_list = 87,            /* subscript_list  */
  YYSYMBOL_subscript = 88,                 /* subscript  */
  YYSYMBOL_expr = 89,                      /* expr  */
  YYSYMBOL_explicit_const = 90,            /* explicit_const  */
  YYSYMBOL_bool_const = 91,                /* bool_const  */
  YYSYMBOL_operation = 92,                 /* operation  */
  YYSYMBOL_numeric_operation = 93,         /* numeric_operation  */
  YYSYMBOL_comparison_operation = 94,      /* comparison_operation  */
  YYSYMBOL_boolean_operation = 95,         /* boolean_operation  */
  YYSYMBOL_sign_operation = 96             /* sign_operation  */
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
typedef yytype_uint8 yy_state_t;

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
#define YYFINAL  56
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   451

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  63
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  34
/* YYNRULES -- Number of rules.  */
#define YYNRULES  95
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  189

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
       0,    57,    57,    60,    64,    66,    75,    77,    82,    84,
      90,    92,    94,    96,    98,   103,   105,   107,   109,   114,
     116,   121,   126,   128,   130,   132,   137,   140,   144,   146,
     151,   153,   158,   160,   165,   167,   172,   174,   176,   178,
     183,   185,   190,   192,   197,   199,   204,   206,   208,   210,
     213,   218,   220,   222,   224,   226,   231,   236,   238,   246,
     251,   256,   258,   263,   268,   270,   280,   290,   292,   294,
     299,   301,   303,   305,   310,   312,   317,   319,   321,   323,
     328,   329,   330,   331,   332,   336,   337,   338,   339,   340,
     341,   350,   351,   352,   356,   357
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
  "formal_type", "subprog_call", "actual_list", "if_stmt", "bool_expr",
  "scalar_type", "array_type", "type", "var_ref", "subscript_list",
  "subscript", "expr", "explicit_const", "bool_const", "operation",
  "numeric_operation", "comparison_operation", "boolean_operation",
  "sign_operation", YY_NULLPTR
  };
  return yy_sname[yysymbol];
}
#endif

#define YYPACT_NINF (-64)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-60)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     185,   -18,     0,   -10,    21,   139,   -64,    23,     9,    65,
     185,   -64,   -64,   -64,   -64,   -64,   -64,   195,   -64,   -64,
     -64,    49,   -37,     4,   -64,   -64,    -4,   -64,   -64,   -64,
     139,   139,   139,   -10,    -8,   -22,   366,   -64,   -15,   -64,
     -64,   -13,   -12,   -64,    31,   139,   -64,   366,   -64,   -64,
     -64,   -25,   139,   139,    38,   -64,   -64,   -64,    89,   195,
     -64,   139,   139,   330,   277,   -21,   139,   139,   398,    16,
      16,    48,   322,   195,   139,   139,   139,   139,   139,   139,
     139,   139,   139,   139,   139,   139,   139,   -21,   139,   277,
      28,   366,   209,   -64,    79,   -64,   366,   366,   -64,   -64,
     -64,    56,    71,   139,   -64,   -64,   -64,    83,    63,    32,
     -64,    36,   192,   -64,   -64,    86,   398,   383,   -64,   326,
     326,   326,   326,   326,   326,    16,    16,   -64,   -64,    45,
     366,    90,   -64,   -64,   139,   -64,   -64,   139,   139,   276,
      73,   278,    78,   -21,   -64,    76,   195,   119,   -64,   139,
     366,   344,   366,    81,   278,   139,    85,   -64,   -64,   277,
     -64,   139,   131,   -64,   366,   -64,   139,   -64,   293,    75,
     -64,   226,   133,   147,    94,    97,   -64,   -64,   277,    88,
     -64,   -64,   136,   284,   102,   -64,   114,   103,   -64
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       3,     0,     0,     0,     0,     0,    12,     0,    40,     0,
       2,     5,    30,    31,     8,     9,     7,    27,     6,    11,
      14,     0,     0,     0,    75,    74,    59,    72,    70,    71,
       0,     0,     0,     0,     0,    64,     0,    65,    73,    68,
      76,    77,    78,    79,    22,     0,    64,    13,    73,    77,
      78,     0,     0,     0,    60,    62,     1,     4,     0,    26,
      29,     0,     0,     0,     0,     0,     0,     0,    93,    94,
      95,     0,     0,    27,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    43,     0,    61,     0,    28,    10,    19,    53,    51,
      52,    54,     0,     0,    57,    58,    24,     0,     0,     0,
      33,     0,     0,    50,    69,     0,    91,    92,    84,    88,
      89,    90,    85,    86,    87,    80,    81,    82,    83,     0,
      15,    17,    16,    41,     0,    63,    21,     0,     0,     0,
       0,     0,     0,     0,    66,     0,    27,     0,    23,     0,
      42,     0,    20,     0,     0,     0,    54,    34,    36,     0,
      32,     0,     0,    44,    18,    55,     0,    35,     0,     0,
      25,     0,     0,     0,     0,     0,    67,    45,     0,     0,
      37,    56,     0,     0,    54,    38,     0,     0,    39
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
     -64,   -64,   -64,   150,   -64,   -64,   -64,   -64,   -64,   -64,
     -62,   -64,     3,    80,    19,    24,   -64,   104,   -64,   144,
     -41,    93,   -63,    34,   -64,   125,    -3,   -64,     2,   -64,
     -64,     5,     6,   -64
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_uint8 yydefgoto[] =
{
       0,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      58,    59,    60,   109,   110,   157,    19,    90,    20,    34,
     104,   105,   158,    46,    54,    55,   151,    37,    48,    39,
      40,    49,    50,    43
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      36,   106,    47,    18,    24,    38,    62,   -46,    41,    42,
     107,   115,   108,    18,   -47,    22,   -48,   -49,    88,    63,
      25,    73,   102,    26,    27,    28,    29,    68,    69,    70,
      72,    89,    30,    23,    21,    38,   -46,    35,    41,    42,
      31,    32,    72,   -47,    21,   -48,   -49,    33,   131,    91,
      92,    21,   -59,    66,    44,    76,    51,    67,    96,    97,
      64,    65,    95,    91,   112,    56,    52,    35,    85,    86,
      53,   116,   117,   118,   119,   120,   121,   122,   123,   124,
     125,   126,   127,   128,   162,   130,   133,   134,    87,    24,
     142,   143,    61,    21,   144,   134,   170,   146,   147,    53,
     139,    94,    24,   148,   143,    25,   113,    21,    26,    27,
      28,    29,   136,   137,   138,   181,   140,    30,    25,   141,
     185,    26,    27,    28,    29,    31,    32,   175,    24,   154,
      30,   150,    45,   149,   159,   152,   161,   163,    31,    32,
     182,   166,   169,   172,    25,    45,   164,    26,    27,    28,
      29,   177,   168,    24,   179,   180,    30,   183,   171,   186,
      57,   188,   160,   173,    31,    32,   187,   129,   178,    25,
     111,    45,    26,    27,    28,    29,   173,    71,   167,    93,
      21,    30,   132,     0,    74,    75,    76,    77,    78,    31,
      32,    79,     1,    80,    81,    82,    45,    83,    84,    85,
      86,     2,     1,     3,     0,     0,     0,     0,     4,     0,
       5,     6,     0,     3,     0,     0,     7,     0,     8,     0,
       5,     6,     0,     0,     0,     0,     7,     0,     8,    74,
      75,    76,    77,    78,     0,     0,    79,     0,    80,    81,
      82,     0,    83,    84,    85,    86,    74,    75,    76,    77,
      78,     0,   145,    79,   135,    80,    81,    82,     0,    83,
      84,    85,    86,    74,    75,    76,    77,    78,     0,     0,
      79,   135,    80,    81,    82,     0,    83,    84,    85,    86,
     103,   155,    98,    98,     0,     0,     0,   103,   176,    98,
       0,     0,     0,     0,     0,     0,    99,    99,     0,     0,
       0,   100,   100,    99,     0,   101,   156,     0,   100,     0,
       0,     0,   184,    74,    75,    76,    77,    78,     0,     0,
      79,     0,    80,    81,    82,     0,    83,    84,    85,    86,
      74,    75,    76,    77,    78,    98,   153,    79,     0,    80,
      81,    82,     0,    83,    84,    85,    86,     0,     0,    99,
       0,     0,     0,   174,   100,     0,     0,     0,   101,    74,
      75,    76,    77,    78,     0,    76,    79,     0,    80,    81,
      82,     0,    83,    84,    85,    86,    83,    84,    85,    86,
     114,    74,    75,    76,    77,    78,     0,     0,    79,     0,
      80,    81,    82,     0,    83,    84,    85,    86,     0,     0,
       0,     0,   165,    74,    75,    76,    77,    78,     0,     0,
      79,     0,    80,    81,    82,     0,    83,    84,    85,    86,
      74,     0,    76,    77,    78,     0,     0,    79,     0,    80,
      81,    82,     0,    83,    84,    85,    86,    76,    77,    78,
       0,     0,    79,     0,    80,    81,    82,     0,    83,    84,
      85,    86
};

static const yytype_int16 yycheck[] =
{
       3,    64,     5,     0,    14,     3,    43,    29,     3,     3,
      31,    73,    33,    10,    29,    33,    29,    29,    43,    56,
      30,    29,    63,    33,    34,    35,    36,    30,    31,    32,
      33,    56,    42,    33,     0,    33,    58,     3,    33,    33,
      50,    51,    45,    58,    10,    58,    58,    57,    89,    52,
      53,    17,    43,    57,    33,    39,    33,    61,    61,    62,
      56,    57,    59,    66,    67,     0,    57,    33,    52,    53,
      61,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,   146,    88,    58,    59,    57,    14,
      58,    59,    43,    59,    58,    59,   159,    11,    12,    61,
     103,    12,    14,    58,    59,    30,    58,    73,    33,    34,
      35,    36,    33,    57,    43,   178,    33,    42,    30,    56,
     183,    33,    34,    35,    36,    50,    51,    52,    14,    56,
      42,   134,    57,    43,    56,   138,    60,    18,    50,    51,
      52,    60,    57,    12,    30,    57,   149,    33,    34,    35,
      36,    18,   155,    14,    60,    58,    42,    21,   161,    57,
      10,    58,   143,   166,    50,    51,    52,    87,    21,    30,
      66,    57,    33,    34,    35,    36,   179,    33,   154,    54,
     146,    42,    89,    -1,    37,    38,    39,    40,    41,    50,
      51,    44,     7,    46,    47,    48,    57,    50,    51,    52,
      53,    16,     7,    18,    -1,    -1,    -1,    -1,    23,    -1,
      25,    26,    -1,    18,    -1,    -1,    31,    -1,    33,    -1,
      25,    26,    -1,    -1,    -1,    -1,    31,    -1,    33,    37,
      38,    39,    40,    41,    -1,    -1,    44,    -1,    46,    47,
      48,    -1,    50,    51,    52,    53,    37,    38,    39,    40,
      41,    -1,    60,    44,    62,    46,    47,    48,    -1,    50,
      51,    52,    53,    37,    38,    39,    40,    41,    -1,    -1,
      44,    62,    46,    47,    48,    -1,    50,    51,    52,    53,
       3,     3,     5,     5,    -1,    -1,    -1,     3,    62,     5,
      -1,    -1,    -1,    -1,    -1,    -1,    19,    19,    -1,    -1,
      -1,    24,    24,    19,    -1,    28,    28,    -1,    24,    -1,
      -1,    -1,    28,    37,    38,    39,    40,    41,    -1,    -1,
      44,    -1,    46,    47,    48,    -1,    50,    51,    52,    53,
      37,    38,    39,    40,    41,     5,    60,    44,    -1,    46,
      47,    48,    -1,    50,    51,    52,    53,    -1,    -1,    19,
      -1,    -1,    -1,    60,    24,    -1,    -1,    -1,    28,    37,
      38,    39,    40,    41,    -1,    39,    44,    -1,    46,    47,
      48,    -1,    50,    51,    52,    53,    50,    51,    52,    53,
      58,    37,    38,    39,    40,    41,    -1,    -1,    44,    -1,
      46,    47,    48,    -1,    50,    51,    52,    53,    -1,    -1,
      -1,    -1,    58,    37,    38,    39,    40,    41,    -1,    -1,
      44,    -1,    46,    47,    48,    -1,    50,    51,    52,    53,
      37,    -1,    39,    40,    41,    -1,    -1,    44,    -1,    46,
      47,    48,    -1,    50,    51,    52,    53,    39,    40,    41,
      -1,    -1,    44,    -1,    46,    47,    48,    -1,    50,    51,
      52,    53
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     7,    16,    18,    23,    25,    26,    31,    33,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    75,    79,
      81,    86,    33,    33,    14,    30,    33,    34,    35,    36,
      42,    50,    51,    57,    82,    86,    89,    90,    91,    92,
      93,    94,    95,    96,    33,    57,    86,    89,    91,    94,
      95,    33,    57,    61,    87,    88,     0,    66,    73,    74,
      75,    43,    43,    56,    56,    57,    57,    61,    89,    89,
      89,    82,    89,    29,    37,    38,    39,    40,    41,    44,
      46,    47,    48,    50,    51,    52,    53,    57,    43,    56,
      80,    89,    89,    88,    12,    75,    89,    89,     5,    19,
      24,    28,    83,     3,    83,    84,    85,    31,    33,    76,
      77,    80,    89,    58,    58,    73,    89,    89,    89,    89,
      89,    89,    89,    89,    89,    89,    89,    89,    89,    76,
      89,    83,    84,    58,    59,    62,    33,    57,    43,    89,
      33,    56,    58,    59,    58,    60,    11,    12,    58,    43,
      89,    89,    89,    60,    56,     3,    28,    78,    85,    56,
      77,    60,    73,    18,    89,    58,    60,    78,    89,    57,
      85,    89,    12,    89,    60,    52,    62,    18,    21,    60,
      58,    85,    52,    21,    28,    85,    57,    52,    58
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    63,    64,    64,    65,    65,    66,    66,    67,    67,
      68,    68,    68,    68,    68,    69,    69,    69,    69,    70,
      70,    71,    72,    72,    72,    72,    73,    73,    74,    74,
      75,    75,    76,    76,    77,    77,    78,    78,    78,    78,
      79,    79,    80,    80,    81,    81,    82,    82,    82,    82,
      82,    83,    83,    83,    83,    83,    84,    85,    85,    86,
      86,    87,    87,    88,    89,    89,    89,    89,    89,    89,
      90,    90,    90,    90,    91,    91,    92,    92,    92,    92,
      93,    93,    93,    93,    93,    94,    94,    94,    94,    94,
      94,    95,    95,    95,    96,    96
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     0,     2,     1,     1,     1,     1,     1,
       3,     1,     1,     2,     1,     4,     4,     4,     6,     4,
       6,     4,     2,     5,     4,     7,     1,     0,     2,     1,
       1,     1,     3,     1,     3,     4,     1,     4,     7,    10,
       1,     4,     3,     1,     6,     8,     1,     1,     1,     1,
       3,     1,     1,     1,     1,     4,     7,     1,     1,     1,
       2,     2,     1,     3,     1,     1,     4,     7,     1,     3,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     2,     2,     2
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
#line 58 "src/st.y"
  { TRACE("[program]\n"); }
#line 1664 "src/st-parse.c"
    break;

  case 3: /* program: %empty  */
#line 60 "src/st.y"
  { TRACE("empty program\n"); }
#line 1670 "src/st-parse.c"
    break;

  case 4: /* decl_or_stmt_in_main_program_list: decl_or_stmt_in_main_program_list decl_or_stmt_in_main_program  */
#line 65 "src/st.y"
  { ; }
#line 1676 "src/st-parse.c"
    break;

  case 5: /* decl_or_stmt_in_main_program_list: decl_or_stmt_in_main_program  */
#line 67 "src/st.y"
  { ; }
#line 1682 "src/st-parse.c"
    break;

  case 6: /* decl_or_stmt_in_main_program: decl_or_stmt  */
#line 76 "src/st.y"
  { ; }
#line 1688 "src/st-parse.c"
    break;

  case 7: /* decl_or_stmt_in_main_program: subprog_decl  */
#line 78 "src/st.y"
  { TRACE("subprogram declaration\n\n"); }
#line 1694 "src/st-parse.c"
    break;

  case 8: /* decl: var_decl  */
#line 83 "src/st.y"
  { TRACE("variable declaration\n"); }
#line 1700 "src/st-parse.c"
    break;

  case 9: /* decl: const_decl  */
#line 85 "src/st.y"
  { TRACE("constant declaration\n"); }
#line 1706 "src/st-parse.c"
    break;

  case 10: /* stmt: var_ref ASSIGN expr  */
#line 91 "src/st.y"
  { TRACE("var_ref := expr\n"); }
#line 1712 "src/st-parse.c"
    break;

  case 11: /* stmt: subprog_call  */
#line 93 "src/st.y"
  { TRACE("subprogram call\n"); }
#line 1718 "src/st-parse.c"
    break;

  case 12: /* stmt: RETURN  */
#line 95 "src/st.y"
  { TRACE("return\n"); }
#line 1724 "src/st-parse.c"
    break;

  case 13: /* stmt: RESULT expr  */
#line 97 "src/st.y"
  { TRACE("result expr\n"); }
#line 1730 "src/st-parse.c"
    break;

  case 14: /* stmt: if_stmt  */
#line 99 "src/st.y"
  { TRACE("if statement\n"); }
#line 1736 "src/st-parse.c"
    break;

  case 15: /* var_decl: VAR ID ASSIGN expr  */
#line 104 "src/st.y"
  { TRACE("var %s := expr\n", (yyvsp[-2].symbol)->name); }
#line 1742 "src/st-parse.c"
    break;

  case 16: /* var_decl: VAR ID ':' array_type  */
#line 106 "src/st.y"
  { TRACE("var %s: array_type\n", (yyvsp[-2].symbol)->name); }
#line 1748 "src/st-parse.c"
    break;

  case 17: /* var_decl: VAR ID ':' scalar_type  */
#line 108 "src/st.y"
  { TRACE("var %s: scalar_type\n", (yyvsp[-2].symbol)->name); }
#line 1754 "src/st-parse.c"
    break;

  case 18: /* var_decl: VAR ID ':' scalar_type ASSIGN expr  */
#line 110 "src/st.y"
  { TRACE("var %s: scalar_type := expr\n", (yyvsp[-4].symbol)->name); }
#line 1760 "src/st-parse.c"
    break;

  case 19: /* const_decl: CONST ID ASSIGN expr  */
#line 115 "src/st.y"
  { TRACE("const %s = expr\n", (yyvsp[-2].symbol)->name); }
#line 1766 "src/st-parse.c"
    break;

  case 20: /* const_decl: CONST ID ':' scalar_type ASSIGN expr  */
#line 117 "src/st.y"
  { TRACE("const %s: scalar_type := expr\n", (yyvsp[-4].symbol)->name); }
#line 1772 "src/st-parse.c"
    break;

  case 21: /* subprog_decl: subprog_header opt_decl_or_stmt_list END ID  */
#line 122 "src/st.y"
  { ; }
#line 1778 "src/st-parse.c"
    break;

  case 22: /* subprog_header: PROCEDURE ID  */
#line 127 "src/st.y"
  { TRACE("procedure %s with no param\n", (yyvsp[0].symbol)->name); }
#line 1784 "src/st-parse.c"
    break;

  case 23: /* subprog_header: PROCEDURE ID '(' formal_decl_list ')'  */
#line 129 "src/st.y"
  { TRACE("procedure %s with params\n", (yyvsp[-3].symbol)->name); }
#line 1790 "src/st-parse.c"
    break;

  case 24: /* subprog_header: FUNCTION ID ':' type  */
#line 131 "src/st.y"
  { TRACE("procedure %s: type with no param\n", (yyvsp[-2].symbol)->name); }
#line 1796 "src/st-parse.c"
    break;

  case 25: /* subprog_header: FUNCTION ID '(' formal_decl_list ')' ':' type  */
#line 133 "src/st.y"
  { TRACE("procedure %s: type with params\n", (yyvsp[-5].symbol)->name); }
#line 1802 "src/st-parse.c"
    break;

  case 26: /* opt_decl_or_stmt_list: decl_or_stmt_list  */
#line 138 "src/st.y"
  { ; }
#line 1808 "src/st-parse.c"
    break;

  case 27: /* opt_decl_or_stmt_list: %empty  */
#line 140 "src/st.y"
  { ; }
#line 1814 "src/st-parse.c"
    break;

  case 28: /* decl_or_stmt_list: decl_or_stmt_list decl_or_stmt  */
#line 145 "src/st.y"
  {}
#line 1820 "src/st-parse.c"
    break;

  case 29: /* decl_or_stmt_list: decl_or_stmt  */
#line 147 "src/st.y"
  {}
#line 1826 "src/st-parse.c"
    break;

  case 30: /* decl_or_stmt: decl  */
#line 152 "src/st.y"
  { TRACE("declaration\n\n"); }
#line 1832 "src/st-parse.c"
    break;

  case 31: /* decl_or_stmt: stmt  */
#line 154 "src/st.y"
  { TRACE("statement\n\n"); }
#line 1838 "src/st-parse.c"
    break;

  case 32: /* formal_decl_list: formal_decl_list ',' formal_decl  */
#line 159 "src/st.y"
  { ; }
#line 1844 "src/st-parse.c"
    break;

  case 33: /* formal_decl_list: formal_decl  */
#line 161 "src/st.y"
  { ; }
#line 1850 "src/st-parse.c"
    break;

  case 34: /* formal_decl: ID ':' formal_type  */
#line 166 "src/st.y"
  { TRACE("%s: formal_type\n", (yyvsp[-2].symbol)->name); }
#line 1856 "src/st-parse.c"
    break;

  case 35: /* formal_decl: VAR ID ':' formal_type  */
#line 168 "src/st.y"
  { TRACE("var %s: formal_type\n", (yyvsp[-2].symbol)->name); }
#line 1862 "src/st-parse.c"
    break;

  case 36: /* formal_type: type  */
#line 173 "src/st.y"
  { TRACE("type\n"); }
#line 1868 "src/st-parse.c"
    break;

  case 37: /* formal_type: STRING '(' '*' ')'  */
#line 175 "src/st.y"
  { TRACE("string(*)\n"); }
#line 1874 "src/st-parse.c"
    break;

  case 38: /* formal_type: ARRAY expr '.' '.' '*' OF type  */
#line 177 "src/st.y"
  { TRACE("array of type\n"); }
#line 1880 "src/st-parse.c"
    break;

  case 39: /* formal_type: ARRAY expr '.' '.' '*' OF STRING '(' '*' ')'  */
#line 179 "src/st.y"
  { TRACE("array of string(*)\n"); }
#line 1886 "src/st-parse.c"
    break;

  case 40: /* subprog_call: ID  */
#line 184 "src/st.y"
  { TRACE("%s\n", (yyvsp[0].symbol)->name); }
#line 1892 "src/st-parse.c"
    break;

  case 41: /* subprog_call: ID '(' actual_list ')'  */
#line 186 "src/st.y"
  { TRACE("%s()\n", (yyvsp[-3].symbol)->name); }
#line 1898 "src/st-parse.c"
    break;

  case 42: /* actual_list: actual_list ',' expr  */
#line 191 "src/st.y"
  { ; }
#line 1904 "src/st-parse.c"
    break;

  case 43: /* actual_list: expr  */
#line 193 "src/st.y"
  { ; }
#line 1910 "src/st-parse.c"
    break;

  case 44: /* if_stmt: IF bool_expr THEN opt_decl_or_stmt_list END IF  */
#line 198 "src/st.y"
  { TRACE("if-then\n"); }
#line 1916 "src/st-parse.c"
    break;

  case 45: /* if_stmt: IF bool_expr THEN opt_decl_or_stmt_list ELSE opt_decl_or_stmt_list END IF  */
#line 200 "src/st.y"
  { TRACE("if-then-else\n"); }
#line 1922 "src/st-parse.c"
    break;

  case 46: /* bool_expr: var_ref  */
#line 205 "src/st.y"
  { TRACE("variable reference\n"); }
#line 1928 "src/st-parse.c"
    break;

  case 47: /* bool_expr: bool_const  */
#line 207 "src/st.y"
  { TRACE("bool\n"); }
#line 1934 "src/st-parse.c"
    break;

  case 48: /* bool_expr: comparison_operation  */
#line 209 "src/st.y"
  { TRACE("comparison operation\n"); }
#line 1940 "src/st-parse.c"
    break;

  case 49: /* bool_expr: boolean_operation  */
#line 211 "src/st.y"
  { TRACE("boolean operation\n"); }
#line 1946 "src/st-parse.c"
    break;

  case 50: /* bool_expr: '(' bool_expr ')'  */
#line 214 "src/st.y"
  { TRACE("(bool_expr)\n"); }
#line 1952 "src/st-parse.c"
    break;

  case 51: /* scalar_type: INT  */
#line 219 "src/st.y"
  { TRACE("int\n"); }
#line 1958 "src/st-parse.c"
    break;

  case 52: /* scalar_type: REAL  */
#line 221 "src/st.y"
  { TRACE("real\n"); }
#line 1964 "src/st-parse.c"
    break;

  case 53: /* scalar_type: BOOL  */
#line 223 "src/st.y"
  { TRACE("bool\n"); }
#line 1970 "src/st-parse.c"
    break;

  case 54: /* scalar_type: STRING  */
#line 225 "src/st.y"
  { TRACE("string\n"); }
#line 1976 "src/st-parse.c"
    break;

  case 55: /* scalar_type: STRING '(' expr ')'  */
#line 227 "src/st.y"
  { TRACE("string(expr)\n"); }
#line 1982 "src/st-parse.c"
    break;

  case 56: /* array_type: ARRAY expr '.' '.' expr OF type  */
#line 232 "src/st.y"
  { TRACE("array expr..expr of type\n"); }
#line 1988 "src/st-parse.c"
    break;

  case 57: /* type: scalar_type  */
#line 237 "src/st.y"
  { TRACE("scalar_type\n"); }
#line 1994 "src/st-parse.c"
    break;

  case 58: /* type: array_type  */
#line 239 "src/st.y"
  { TRACE("array_type\n"); }
#line 2000 "src/st-parse.c"
    break;

  case 59: /* var_ref: ID  */
#line 247 "src/st.y"
  { TRACE("%s\n", (yyvsp[0].symbol)->name); }
#line 2006 "src/st-parse.c"
    break;

  case 60: /* var_ref: ID subscript_list  */
#line 252 "src/st.y"
  { TRACE("%s", (yyvsp[-1].symbol)->name); }
#line 2012 "src/st-parse.c"
    break;

  case 61: /* subscript_list: subscript_list subscript  */
#line 257 "src/st.y"
  { ; }
#line 2018 "src/st-parse.c"
    break;

  case 62: /* subscript_list: subscript  */
#line 259 "src/st.y"
  { ; }
#line 2024 "src/st-parse.c"
    break;

  case 63: /* subscript: '[' expr ']'  */
#line 264 "src/st.y"
  { TRACE("[]\n"); }
#line 2030 "src/st-parse.c"
    break;

  case 64: /* expr: var_ref  */
#line 269 "src/st.y"
  { TRACE("variable reference\n"); }
#line 2036 "src/st-parse.c"
    break;

  case 65: /* expr: explicit_const  */
#line 271 "src/st.y"
  { TRACE("explicit constant\n"); }
#line 2042 "src/st-parse.c"
    break;

  case 66: /* expr: ID '(' actual_list ')'  */
#line 281 "src/st.y"
  { TRACE("subprogram call\n"); }
#line 2048 "src/st-parse.c"
    break;

  case 67: /* expr: ID '[' expr '.' '.' expr ']'  */
#line 291 "src/st.y"
  { TRACE("substring\n"); }
#line 2054 "src/st-parse.c"
    break;

  case 68: /* expr: operation  */
#line 293 "src/st.y"
  { TRACE("operation\n"); }
#line 2060 "src/st-parse.c"
    break;

  case 69: /* expr: '(' expr ')'  */
#line 295 "src/st.y"
  { TRACE("(expr)\n"); }
#line 2066 "src/st-parse.c"
    break;

  case 70: /* explicit_const: INT_CONST  */
#line 300 "src/st.y"
  { TRACE("int_const: %d\n", (yyvsp[0].int_const)); }
#line 2072 "src/st-parse.c"
    break;

  case 71: /* explicit_const: REAL_CONST  */
#line 302 "src/st.y"
  { TRACE("real_const: %f\n", (yyvsp[0].real_const)); }
#line 2078 "src/st-parse.c"
    break;

  case 72: /* explicit_const: STR_CONST  */
#line 304 "src/st.y"
  { TRACE("str_const: %s\n", (yyvsp[0].str_const)); }
#line 2084 "src/st-parse.c"
    break;

  case 73: /* explicit_const: bool_const  */
#line 306 "src/st.y"
  { TRACE("bool_const: "); }
#line 2090 "src/st-parse.c"
    break;

  case 74: /* bool_const: TRUE  */
#line 311 "src/st.y"
  { TRACE("true\n"); }
#line 2096 "src/st-parse.c"
    break;

  case 75: /* bool_const: FALSE  */
#line 313 "src/st.y"
  { TRACE("false\n"); }
#line 2102 "src/st-parse.c"
    break;

  case 76: /* operation: numeric_operation  */
#line 318 "src/st.y"
  { TRACE("numeric operation\n"); }
#line 2108 "src/st-parse.c"
    break;

  case 77: /* operation: comparison_operation  */
#line 320 "src/st.y"
  { TRACE("comparison operation\n"); }
#line 2114 "src/st-parse.c"
    break;

  case 78: /* operation: boolean_operation  */
#line 322 "src/st.y"
  { TRACE("boolean operation\n"); }
#line 2120 "src/st-parse.c"
    break;

  case 79: /* operation: sign_operation  */
#line 324 "src/st.y"
  { TRACE("sign operation\n"); }
#line 2126 "src/st-parse.c"
    break;

  case 80: /* numeric_operation: expr '+' expr  */
#line 328 "src/st.y"
                {}
#line 2132 "src/st-parse.c"
    break;

  case 81: /* numeric_operation: expr '-' expr  */
#line 329 "src/st.y"
                {}
#line 2138 "src/st-parse.c"
    break;

  case 82: /* numeric_operation: expr '*' expr  */
#line 330 "src/st.y"
                {}
#line 2144 "src/st-parse.c"
    break;

  case 83: /* numeric_operation: expr '/' expr  */
#line 331 "src/st.y"
                {}
#line 2150 "src/st-parse.c"
    break;

  case 84: /* numeric_operation: expr MOD expr  */
#line 332 "src/st.y"
                {}
#line 2156 "src/st-parse.c"
    break;

  case 85: /* comparison_operation: expr '<' expr  */
#line 336 "src/st.y"
                {}
#line 2162 "src/st-parse.c"
    break;

  case 86: /* comparison_operation: expr '>' expr  */
#line 337 "src/st.y"
                {}
#line 2168 "src/st-parse.c"
    break;

  case 87: /* comparison_operation: expr '=' expr  */
#line 338 "src/st.y"
                {}
#line 2174 "src/st-parse.c"
    break;

  case 88: /* comparison_operation: expr LE expr  */
#line 339 "src/st.y"
               {}
#line 2180 "src/st-parse.c"
    break;

  case 89: /* comparison_operation: expr GE expr  */
#line 340 "src/st.y"
               {}
#line 2186 "src/st-parse.c"
    break;

  case 90: /* comparison_operation: expr NE expr  */
#line 341 "src/st.y"
               {}
#line 2192 "src/st-parse.c"
    break;

  case 91: /* boolean_operation: expr AND expr  */
#line 350 "src/st.y"
                {}
#line 2198 "src/st-parse.c"
    break;

  case 92: /* boolean_operation: expr OR expr  */
#line 351 "src/st.y"
               {}
#line 2204 "src/st-parse.c"
    break;

  case 93: /* boolean_operation: NOT expr  */
#line 352 "src/st.y"
           {}
#line 2210 "src/st-parse.c"
    break;

  case 94: /* sign_operation: '+' expr  */
#line 356 "src/st.y"
           {}
#line 2216 "src/st-parse.c"
    break;

  case 95: /* sign_operation: '-' expr  */
#line 357 "src/st.y"
           {}
#line 2222 "src/st-parse.c"
    break;


#line 2226 "src/st-parse.c"

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

#line 360 "src/st.y"


void yyerror(const char *msg) {
  fprintf(stderr, "line %d on symbol '%s': %s\n", yylineno, yytext, msg);
}
