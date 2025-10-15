%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
#include "../src/utils/log.h"
#include "data_types.h"
#include "../src/utils/error.h"

extern int yylineno;
extern YYSTYPE yylval;

int yycolumn = 0;
#define YY_USER_ACTION { \
    yycolumn += yyleng; \
    if (yytext[0] == '\n') { yycolumn = 0; } \
}

%}

%option yylineno
%option nounput
%option noinput
%option noyywrap

ID      [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE [ \t]
RETURN [\n]

%%

"int"       { yylval.data_type = TYPE_INT; return TK_INT; }
"float"     { yylval.data_type = TYPE_FLOAT; return TK_FLOAT; }
"string"    { yylval.data_type = TYPE_STRING; return TK_STRING; }
"bool"      { yylval.data_type = TYPE_BOOL; return TK_BOOL; }

{ID} { 
    yylval.text = strdup(yytext); 
    return TK_ID; 
}

"="         { return TK_EQ; }
","         { return TK_COMMA; }
";"         { return TK_SEMICOLON; }


{WHITESPACE}+      { }
{RETURN}           { }

. { 
    SourceLocation loc = current_location();
    REPORT_LEXICAL_ERROR(loc, "Carácter inválido: '%s'", yytext);
}

%%