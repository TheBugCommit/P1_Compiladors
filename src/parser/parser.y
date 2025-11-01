%{
#include <stdio.h>
#include <string.h>
#include "data_types.h"
#include "../src/utils/log.h"
#include "../src/symtab/symtab.h"
#include "../src/utils/error.h"
#include "../src/data/string_list.h"
#include "../src/semantic/handler.h"
#include "../src/semantic/expression.h"

extern int yylex();

%}

%code requires {
  #include "data_types.h"
  #include "../src/data/string_list.h"
}

%union {
    char *text;
    DATA_TYPE data_type;
    StringListNode *id_list;

    int int_val;
    float float_val;
    char bool_val;

    ExprResult expr_val;
}

/* Type Tokens */
%token <data_type> TK_INT TK_FLOAT TK_STRING TK_BOOL

/* IDs Tokens */
%token <text> TK_ID

%token <int_val> TK_INT_LIT 
%token <float_val> TK_FLOAT_LIT 
%token <text> TK_STRING_LIT
%token <bool_val> TK_TRUE TK_FALSE

/* Puntuation and Operation Tokens  */
%token TK_ASSIGN TK_COMMA TK_SEMICOLON
%token TK_PLUS TK_MINUS TK_MULT TK_DIV TK_MOD TK_POW
%token TK_GT TK_GE TK_LT TK_LE TK_EQ TK_NE
%token TK_NOT TK_AND TK_OR
%token TK_LPAREN TK_RPAREN

%type <data_type> primitive_type
%type <id_list> id_list
/*%type <expr_val> expression bool_term bool_factor relational_expr arith_expr arith_term arith_factor primary literal*/
%type <expr_val> expression literal arith_term arith_expr

%define parse.error detailed

%%

program:
    declarations sentences
    | declarations
    | sentences
;

declarations:
    declarations simple_declaration
    | simple_declaration
    | declarations error TK_SEMICOLON
      {
        log_production("Recovered from error declarations");
        yyerrok;
      }
;

simple_declaration: 
    primitive_type id_list TK_SEMICOLON { handle_simple_declaration($1, $2); }
    | primitive_type id_list error
    {
        SourceLocation loc = current_location();
        REPORT_SYNTAX_ERROR(loc, "Missing ';' at the end of the statement");
        string_list_free($2);
        yyerrok;
    }
    | primitive_type error TK_SEMICOLON
    {
        log_production("Recovered from identifier list error");
        yyerrok;
    }
;
primitive_type:
    TK_INT      { $$ = TYPE_INT; log_production("Type: int"); }
    | TK_FLOAT  { $$ = TYPE_FLOAT; log_production("Type: float"); }
    | TK_STRING { $$ = TYPE_STRING; log_production("Type: string"); }
    | TK_BOOL   { $$ = TYPE_BOOL; log_production("Type: bool"); }
;

id_list:
    TK_ID { $$ = string_list_append(NULL, $1); }
    | id_list TK_COMMA TK_ID { $$ = string_list_append($1, $3); }
;

sentences:
    sentence
    | sentences sentence
    | sentences error TK_SEMICOLON
      {
        log_production("Recovered from sentence error");
        yyerrok;
      }
;

sentence:
    assignment_sentence
    //| expression_sentence
;

assignment_sentence:
    TK_ID TK_ASSIGN expression TK_SEMICOLON {
        handle_assigment_sentence($1, $3);
    }
;

expression:
    arith_expr
;

arith_expr:
    arith_expr TK_PLUS arith_term {
        $$ = eval_add($1, $3);
        free_expr_string(&$1); free_expr_string(&$3);
    }
    | arith_term { $$ = $1; }
;
arith_term:
    arith_term TK_MULT literal
    {
        $$ = eval_mul($1, $3);
        free_expr_string(&$1); free_expr_string(&$3);
    }
    | literal { $$ = $1; }
;
literal:
    TK_INT_LIT
    {
        $$.type = TYPE_INT;
        $$.value.int_val = $1;
        log_production("Literal: Integer (%d)", $1);
    }
    | TK_FLOAT_LIT
    {
        $$.type = TYPE_FLOAT;
        $$.value.float_val = $1;
        log_production("Literal: Float (%f)", $1);
    }
    | TK_STRING_LIT
    {
        $$.type = TYPE_STRING;
        $$.value.string_val = $1;
        log_production("Literal: String (%s)", $1);
    }
    | TK_TRUE
    {
        $$.type = TYPE_BOOL;
        $$.value.bool_val = $1;
        log_production("Literal: Boolean (true)");
    }
    | TK_FALSE
    {
        $$.type = TYPE_BOOL;
        $$.value.bool_val = $1;
        log_production("Literal: Boolean (false)");
    }
;
%%