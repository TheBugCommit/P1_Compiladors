%{
#include <stdio.h>
#include <string.h>
#include "data_types.h"
#include "globals.h"
#include "../src/utils/log.h"
#include "../src/symtab/symtab.h"
#include "../src/utils/error.h"
#include "../src/utils/report.h"
#include "../src/semantic/string_list.h"
#include "../src/semantic/handler.h"
#include "../src/semantic/expression.h"
#include "../src/semantic/function.h"

extern int yylex();
extern int yylineno;

%}

%code requires {
  #include "data_types.h"
  #include "../src/semantic/string_list.h"
}

%union {
    char *text;
    DATA_TYPE data_type;
    StringListNode *id_list;

    long long int_val;
    double float_val;
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
%token TK_ASSIGN TK_COMMA TK_NEWLINE
%token TK_PLUS TK_MINUS TK_MULT TK_DIV TK_MOD TK_POW
%token TK_GT TK_GE TK_LT TK_LE TK_EQ TK_NE
%token TK_NOT TK_AND TK_OR
%token TK_LPAREN TK_RPAREN

/* Functions */
%token TK_SIN TK_COS TK_TAN

%type <data_type> primitive_type
%type <id_list> id_list
%type <expr_val> expression arith_term arith_expr arith_unit arith_factor bool_term bool_factor relational_expr primary literal

%define parse.error detailed

%%

program:
    optional_newlines declarations optional_newlines sentence_list optional_newlines
    | optional_newlines declarations optional_newlines
    | optional_newlines sentence_list optional_newlines
;

optional_newlines:
    /* void */
    | optional_newlines TK_NEWLINE
;
declarations:
    declarations optional_newlines simple_declaration
    | simple_declaration
    | declarations error TK_NEWLINE
      {
        log_production("Recovered from error declarations");
        yyerrok;
      }
;

simple_declaration: 
    primitive_type id_list TK_NEWLINE { handle_simple_declaration($1, $2); }
    | primitive_type id_list error
    {
        SourceLocation loc = current_location();
        REPORT_SYNTAX_ERROR(loc, "Invalid declaration structure or missing '\\n' at EOF");
        string_list_free($2);
        yyerrok;
    }
    | primitive_type error TK_NEWLINE
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

sentence_list:
    sentence
    | sentence_list optional_newlines sentence
    | sentence_list error TK_NEWLINE
      {
        log_production("Recovered from sentence error");
        yyerrok;
      }
;

sentence:
    assignment_sentence TK_NEWLINE
    | expression_sentence TK_NEWLINE
;

assignment_sentence:
    TK_ID TK_ASSIGN expression {
        report_assignation($1, $3);
        handle_assigment_sentence($1, $3);
    }
;

expression_sentence:
    expression 
    {
        report_expression($1);
        free_expr_string(&$1);
    }
;


expression:
    expression TK_OR bool_term { $$ = eval_or($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
    | bool_term { $$ = $1; }
;

/* Nivel 2: AND */
bool_term:
    bool_term TK_AND bool_factor { $$ = eval_and($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
    | bool_factor { $$ = $1; }
;

/* Nivel 3: NOT */
bool_factor:
    TK_NOT bool_factor { $$ = eval_not($2); free_expr_string(&$2); }
    | relational_expr { $$ = $1; }
;

/* Nivel 4: Relacional (>, <, =, <>, >=, <=) */
relational_expr:
    arith_expr TK_GT arith_expr { $$ = eval_relational($1, $3, TK_GT); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_GE arith_expr { $$ = eval_relational($1, $3, TK_GE); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_LT arith_expr { $$ = eval_relational($1, $3, TK_LT); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_LE arith_expr { $$ = eval_relational($1, $3, TK_LE); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_EQ arith_expr { $$ = eval_relational($1, $3, TK_EQ); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_NE arith_expr { $$ = eval_relational($1, $3, TK_NE); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr { $$ = $1; }
;

/* Nivel 5: Suma, Resta, Unario +/- */
arith_expr:
    arith_expr TK_PLUS arith_term    { $$ = eval_add($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_expr TK_MINUS arith_term   { $$ = eval_sub($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_term                       { $$ = $1; }
;

/* Nivel 6: *, /, % */
arith_term:
    arith_term TK_MULT arith_unit { $$ = eval_mul($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_term TK_DIV arith_unit  { $$ = eval_div($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_term TK_MOD arith_unit  { $$ = eval_mod($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_unit                    { $$ = $1; }
;

arith_unit:
    TK_PLUS arith_unit    { $$ = eval_unary_plus($2); free_expr_string(&$2); }
  | TK_MINUS arith_unit   { $$ = eval_unary_minus($2); free_expr_string(&$2); }
  | arith_factor          { $$ = $1; }
;

/* Nivel 7: Potencia (**) (Asociativa por la derecha) */
arith_factor:
    primary TK_POW arith_factor { $$ = eval_pow($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
    | primary { $$ = $1; }
;

primary:
    TK_LPAREN expression TK_RPAREN { $$ = $2; log_production("Expression: Parenthesized"); }
    | literal { $$ = $1; }
    | TK_ID { $$ = handle_primary_id($1); }
    | TK_SIN TK_LPAREN expression TK_RPAREN { $$ = eval_sin($3); free_expr_string(&$3); }
    | TK_COS TK_LPAREN expression TK_RPAREN { $$ = eval_cos($3); free_expr_string(&$3); }
    | TK_TAN TK_LPAREN expression TK_RPAREN { $$ = eval_tan($3); free_expr_string(&$3); }
;

literal:
    TK_INT_LIT
    {
        $$.type = TYPE_INT;
        $$.value.int_val = $1;
        log_production("Literal: %s (%d)", TYPE_NAME[$$.type], $1);
    }
    | TK_FLOAT_LIT
    {
        $$.type = TYPE_FLOAT;
        $$.value.float_val = $1;
        log_production("Literal: %s (%f)", TYPE_NAME[$$.type], $1);
    }
    | TK_STRING_LIT
    {
        $$.type = TYPE_STRING;
        $$.value.string_val = $1;
        log_production("Literal: %s (%s)", TYPE_NAME[$$.type], $1);
    }
    | TK_TRUE
    {
        $$.type = TYPE_BOOL;
        $$.value.bool_val = $1;
        log_production("Literal: %s (true)", TYPE_NAME[$$.type]);
    }
    | TK_FALSE
    {
        $$.type = TYPE_BOOL;
        $$.value.bool_val = $1;
        log_production("Literal: %s (false)", TYPE_NAME[$$.type]);
    }
;
%%