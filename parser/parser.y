%{
#include <stdio.h>
#include <string.h>
#include "data_types.h"
#include "../src/utils/log.h"
#include "../src/symtab/symtab.h"
#include "../src/utils/error.h"
#include "../src/data/string_list.h"
#include "../src/parser/declarations/declaration.h"

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
}

%token <data_type> TK_INT TK_FLOAT TK_STRING TK_BOOL
%token <text> TK_ID
%token TK_EQ TK_COMMA TK_SEMICOLON
%token TK_TRUE TK_FALSE

%type <data_type> primitive_type
%type <id_list> id_list

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
    TK_ID TK_EQ TK_SEMICOLON  // TODO: posar expressio
    {
        log_production("Assignment sentence");
    }
;

%%