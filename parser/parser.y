%{
#include <stdio.h>
#include <string.h>
#include "../src/utils/log.h"
#include "../src/semantic/symtab.h"
#include "data_types.h"
#include "../src/utils/error.h"

extern int yylex();

%}

%code requires {
  #include "data_types.h"
}

%union {
    char *text;
    DATA_TYPE data_type;
}

%token <data_type> TK_INT TK_FLOAT TK_STRING TK_BOOL
%token <text> TK_ID
%token TK_EQ TK_COMMA TK_SEMICOLON

%type <data_type> primitive_type id_list

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
    primitive_type id_list TK_SEMICOLON
    {
        log_production("Complete simple declaration");
    }
    | primitive_type id_list error
    {
        SourceLocation loc = current_location();
        REPORT_SYNTAX_ERROR(loc, "Missing ';' at the end of the statement");
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
    TK_ID
    {
        DATA_TYPE declared_type = $$;
        
        sym_value_type new_entry;
        new_entry.type = declared_type;
        
        int result = sym_add($1, &new_entry);
        if (result == SYMTAB_DUPLICATE) {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Identifier '%s' already declared", $1);
        }

        log_production("Declared identifier: '%s'", $1);
        $$ = declared_type;
    }
    | id_list TK_COMMA TK_ID
    {
        DATA_TYPE declared_type = $1;
        
        sym_value_type new_entry;
        new_entry.type = declared_type;
        
        int result = sym_add($3, &new_entry);
        if (result == SYMTAB_DUPLICATE) {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Identifier '%s' already declared", $3);
        }
        
        log_production("Additional identifier declared: '%s'", $3);
        $$ = declared_type;
    }
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