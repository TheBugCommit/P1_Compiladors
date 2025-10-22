%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
#include "data_types.h"
#include "../src/utils/log.h"
#include "../src/utils/error.h"

extern int yylineno;
extern YYSTYPE yylval;

int yycolumn = 0;
#define YY_USER_ACTION { \
    \
    int i; \
    for (i = 0; i < yyleng; ++i) { \
        if (yytext[i] == '\n') { \
            yycolumn = 0; \
        } else { \
            yycolumn++; \
        } \
    } \
}

%}

%option yylineno
%option nounput
%option noinput
%option noyywrap

/* Multiline comment state */
%x MULTI_COMMENT


ID         [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE [ \t]
RETURN     [\n]
COMMENT    (\/\/|#)
DIGIT      [0-9]
EXPONENT   [eE][+-]?{DIGIT}+

%%

"/*" { 
    BEGIN(MULTI_COMMENT);
    SourceLocation loc = current_location();
    log_production("Multiline comment start on row: %d col: %d", loc.line, loc.column);
}
<MULTI_COMMENT>[^*]+ { log_production("Multicomment skipping characters"); }
<MULTI_COMMENT>\*+\/ {
    BEGIN(INITIAL);
    SourceLocation loc = current_location();
    log_production("Multiline comment closed on row: %d col: %d", loc.line, loc.column);
}
<MULTI_COMMENT>.|\n  { }
<MULTI_COMMENT><<EOF>> {
    SourceLocation loc = current_location();
    REPORT_LEXICAL_ERROR(loc, "Unclosed multi-line comment");
    BEGIN(INITIAL);
}

{COMMENT}.* { log_production("Skiped comment line"); }

%{ /* Types */ %}

"int"       { yylval.data_type = TYPE_INT; return TK_INT; }
"float"     { yylval.data_type = TYPE_FLOAT; return TK_FLOAT; }
"string"    { yylval.data_type = TYPE_STRING; return TK_STRING; }
"bool"      { yylval.data_type = TYPE_BOOL; return TK_BOOL; }

%{ /* Literals */ %}

"true"      { return TK_TRUE; }
"false"     { return TK_FALSE; }


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
    REPORT_LEXICAL_ERROR(loc, "Invalid character: '%s'", yytext);
}

%%