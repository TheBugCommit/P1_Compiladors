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

/* === NUEVO: Estado para comentarios multilínea === */

/* === NUEVO: Definiciones para números === */
D         [0-9]
EXPONENT  [eE][+-]?{D}+

/* Definiciones existentes */
ID        [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE [ \t]
RETURN    [\n]

%%

/* Palabras clave (keywords) */
"int"       { yylval.data_type = TYPE_INT; return TK_INT; }
"float"     { yylval.data_type = TYPE_FLOAT; return TK_FLOAT; }
"string"    { yylval.data_type = TYPE_STRING; return TK_STRING; }
"bool"      { yylval.data_type = TYPE_BOOL; return TK_BOOL; }

/* === NUEVO: Comentarios (deben ir antes que otros tokens) === */

/* Comentarios multilínea /* ... */
"/*"                    { BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL); }
<COMMENT>.              { /* consumir carácter dentro del comentario */ }
<COMMENT>\n             { /* consumir newline dentro del comentario */ }
<COMMENT><<EOF>>        { 
                          SourceLocation loc = current_location();
                          REPORT_LEXICAL_ERROR(loc, "Unclosed multi-line comment");
                          BEGIN(INITIAL); 
                        }

/* Comentarios de una línea // ... y # ... */
"//".* { /* Descartar */ }
"#".* { /* Descartar */ }

/* === FIN NUEVO === */


/* === NUEVO: Literales (el orden importa) === */

/* Booleanos */
"true"      { return TK_TRUE; }
"false"     { return TK_FALSE; }

/* Literales Reales (float) - deben ir ANTES que los enteros */
/* Ej: 3.1416, 0.5e-04, 1.2345e3, 3., .14 */
{D}+\.{D}*({EXPONENT})?  { yylval.text = strdup(yytext); return TK_FLOAT_LIT; }
\.{D}+({EXPONENT})?      { yylval.text = strdup(yytext); return TK_FLOAT_LIT; }
{D}+{EXPONENT}          { yylval.text = strdup(yytext); return TK_FLOAT_LIT; }

/* Literal Entero (int) */
/* Ej: 123, 045 */
{D}+                    { yylval.text = strdup(yytext); return TK_INT_LIT; }

/* Literal de Cadena (string) */
/* Ej: "Hola", "Con \"escapes\"" */
/* No permite saltos de línea literales */
\"([^"\n\\]|\\.)*\"     { yylval.text = strdup(yytext); return TK_STRING_LIT; }

/* Error para strings mal formados */
\"[^\n\"]*(\n|<<EOF>>)  {
                          SourceLocation loc = current_location();
                          if (yytext[yyleng-1] == '\n') {
                            REPORT_LEXICAL_ERROR(loc, "String literal cannot span multiple lines");
                          } else {
                            REPORT_LEXICAL_ERROR(loc, "Unclosed string literal");
                          }
                        }
/* === FIN NUEVO === */


/* Identificador (después de keywords y literales) */
{ID} { 
    yylval.text = strdup(yytext); 
    return TK_ID; 
}

/* Operadores y puntuación */
"="         { return TK_EQ; }
","         { return TK_COMMA; }
";"         { return TK_SEMICOLON; }

/* Espacios en blanco y saltos de línea */
{WHITESPACE}+      { /* Descartar */ }
{RETURN}           { /* Descartar */ }

/* Regla de error por defecto */
. { 
    SourceLocation loc = current_location();
    REPORT_LEXICAL_ERROR(loc, "Invalid character: '%s'", yytext);
}

%%