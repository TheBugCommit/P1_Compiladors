/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_BUILD_PARSER_TAB_H_INCLUDED
# define YY_YY_BUILD_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 20 "src/parser/parser.y"

  #include "data_types.h"
  #include "../src/semantic/string_list.h"

#line 54 "build/parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    TK_INT = 258,                  /* TK_INT  */
    TK_FLOAT = 259,                /* TK_FLOAT  */
    TK_STRING = 260,               /* TK_STRING  */
    TK_BOOL = 261,                 /* TK_BOOL  */
    TK_ID = 262,                   /* TK_ID  */
    TK_INT_LIT = 263,              /* TK_INT_LIT  */
    TK_FLOAT_LIT = 264,            /* TK_FLOAT_LIT  */
    TK_PI = 265,                   /* TK_PI  */
    TK_E = 266,                    /* TK_E  */
    TK_STRING_LIT = 267,           /* TK_STRING_LIT  */
    TK_TRUE = 268,                 /* TK_TRUE  */
    TK_FALSE = 269,                /* TK_FALSE  */
    TK_ASSIGN = 270,               /* TK_ASSIGN  */
    TK_COMMA = 271,                /* TK_COMMA  */
    TK_NEWLINE = 272,              /* TK_NEWLINE  */
    TK_SEMICOLON = 273,            /* TK_SEMICOLON  */
    TK_DOT = 274,                  /* TK_DOT  */
    TK_PLUS = 275,                 /* TK_PLUS  */
    TK_MINUS = 276,                /* TK_MINUS  */
    TK_MULT = 277,                 /* TK_MULT  */
    TK_DIV = 278,                  /* TK_DIV  */
    TK_MOD = 279,                  /* TK_MOD  */
    TK_POW = 280,                  /* TK_POW  */
    TK_GT = 281,                   /* TK_GT  */
    TK_GE = 282,                   /* TK_GE  */
    TK_LT = 283,                   /* TK_LT  */
    TK_LE = 284,                   /* TK_LE  */
    TK_EQ = 285,                   /* TK_EQ  */
    TK_NE = 286,                   /* TK_NE  */
    TK_NOT = 287,                  /* TK_NOT  */
    TK_AND = 288,                  /* TK_AND  */
    TK_OR = 289,                   /* TK_OR  */
    TK_LPAREN = 290,               /* TK_LPAREN  */
    TK_RPAREN = 291,               /* TK_RPAREN  */
    TK_LBRACE = 292,               /* TK_LBRACE  */
    TK_RBRACE = 293,               /* TK_RBRACE  */
    TK_STRUCT = 294,               /* TK_STRUCT  */
    TK_SIN = 295,                  /* TK_SIN  */
    TK_COS = 296,                  /* TK_COS  */
    TK_TAN = 297,                  /* TK_TAN  */
    TK_LEN = 298,                  /* TK_LEN  */
    TK_SUBSTR = 299                /* TK_SUBSTR  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 25 "src/parser/parser.y"

    char *text;
    DATA_TYPE data_type;
    StringListNode *id_list;

    long long int_val;
    double float_val;
    char bool_val;

    ExprResult expr_val;
    //sym_value_type* struct_field;

#line 128 "build/parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_BUILD_PARSER_TAB_H_INCLUDED  */
