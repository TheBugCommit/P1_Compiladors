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

char* unescape_string(char* s) {
    int len = strlen(s);
    if (len < 2) return strdup("");
    s[len - 1] = '\0'; // Quita la comilla final
    return strdup(s + 1);  // Retorna un duplicado desde después de la comilla inicial
}

%}

%option yylineno
%option nounput
%option noinput
%option noyywrap

/* Multiline comment state */
%x MULTI_COMMENT

ID              [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE      [ \t]
RETURN          [\n]
COMMENT         (\/\/|#)
DIGIT           [0-9]
EXPONENT        ([eE][+-]?{DIGIT}+)
FLOAT           (({DIGIT}+\.{DIGIT}+({EXPONENT})?)|(\.{DIGIT}+({EXPONENT})?)|({DIGIT}+{EXPONENT}))
INT             {DIGIT}+
STRING          \"([^"\n\\]|\\.)*\"
UNCLOSED_STRING \"[^\n\"]*(\n|$)

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

%{ /* Operators and expression keywords */ %}

":="        { return TK_ASSIGN; }
"+"         { return TK_PLUS; }
"-"         { return TK_MINUS; }
"*"         { return TK_MULT; }
"/"         { return TK_DIV; }
"%"         { return TK_MOD; }
"**"        { return TK_POW; }
">"         { return TK_GT; }
">="        { return TK_GE; }
"<"         { return TK_LT; }
"<="        { return TK_LE; }
"="         { return TK_EQ; }
"<>"        { return TK_NE; }
"not"       { return TK_NOT; }
"and"       { return TK_AND; }
"or"        { return TK_OR; }
"("         { return TK_LPAREN; }
")"         { return TK_RPAREN; }

%{ /* Literals */ %}

"true"      { yylval.bool_val = 1; return TK_TRUE; }
"false"     { yylval.bool_val = 0; return TK_FALSE; }

{FLOAT}     { yylval.float_val = atof(yytext); return TK_FLOAT_LIT; }
{INT}       { yylval.int_val = atoi(yytext); return TK_INT_LIT; }

{STRING}    { yylval.text = unescape_string(yytext); return TK_STRING_LIT; }
{UNCLOSED_STRING}  {
    SourceLocation loc = current_location();
    if (yytext[yyleng-1] == '\n') {
        REPORT_LEXICAL_ERROR(loc, "String literal cannot span multiple lines");
    } else {
        REPORT_LEXICAL_ERROR(loc, "Unclosed string literal");
    }
}

%{ /* Identifiers */ %}

{ID} { 
    yylval.text = strdup(yytext); 
    return TK_ID; 
}


%{ /* Puntuation */ %}
","         { return TK_COMMA; }
";"         { return TK_SEMICOLON; }


{WHITESPACE}+      { }
{RETURN}           { }

. { 
    SourceLocation loc = current_location();
    REPORT_LEXICAL_ERROR(loc, "Invalid character: '%s'", yytext);
}

%%