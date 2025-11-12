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
#include "../src/semantic/struct.h"

extern int yylex();

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
    StructFieldListNode* struct_field_list;
    StructAccessData struct_access_data;
}
%locations
/* Type Tokens */
%token <data_type> TK_INT TK_FLOAT TK_STRING TK_BOOL

/* IDs Tokens */
%token <text> TK_ID

%token <int_val> TK_INT_LIT 
%token <float_val> TK_FLOAT_LIT TK_PI TK_E
%token <text> TK_STRING_LIT
%token <bool_val> TK_TRUE TK_FALSE

/* Puntuation and Operation Tokens  */
%token TK_ASSIGN TK_COMMA TK_NEWLINE TK_SEMICOLON TK_DOT TK_EOF
%token TK_PLUS TK_MINUS TK_MULT TK_DIV TK_MOD TK_POW
%token TK_GT TK_GE TK_LT TK_LE TK_EQ TK_NE
%token TK_NOT TK_AND TK_OR
%token TK_LPAREN TK_RPAREN TK_LBRACE TK_RBRACE

%token TK_STRUCT
/* Functions */
%token TK_SIN TK_COS TK_TAN TK_LEN TK_SUBSTR

%type <data_type> primitive_type
%type <id_list> id_list
%type <expr_val> expression arith_term arith_expr unary_expr arith_factor bool_term bool_factor relational_expr primary constant literal
%type <struct_field_list> struct_fields
%type <struct_access_data> struct_member_access

%define parse.error detailed

%%

program:
    optional_newlines item_list optional_newlines opt_eof
;

item_list:
    program_item
    | item_list optional_newlines program_item
    | item_list error end_of_stmt
      {
        log_production("Recovered from item list error, skipping item.");
        yyerrok;
      }
;

program_item:
    simple_declaration
    | struct_declaration
    | sentence
;

optional_newlines:
    /* void */
    | optional_newlines TK_NEWLINE
;

end_of_stmt:
    TK_NEWLINE
    | TK_EOF 
;

opt_eof:
      /* void */
    | TK_EOF
;


struct_declaration:
    TK_STRUCT TK_ID TK_LBRACE struct_fields TK_RBRACE id_list end_of_stmt
    {
        if(handle_struct_declaration($2, $4)) handle_struct_instances($2, $6);
    }
;

struct_fields:
    primitive_type id_list TK_SEMICOLON {  $$= struct_field_list_append(NULL, $1, $2); }
    | struct_fields primitive_type id_list TK_SEMICOLON  { $$ = struct_field_list_append($1, $2, $3); }
    | error TK_SEMICOLON
      {
        log_production("Recovered from struct field error, skipping first field.");
        yyerrok;
        $$ = NULL;
      }
    | struct_fields error TK_SEMICOLON
      { 
        log_production("Recovered from struct field error, skipping field.");
        yyerrok; 
        $$ = $1;
      }
;

simple_declaration: 
    primitive_type id_list end_of_stmt { handle_simple_declaration($1, $2); }
    | primitive_type id_list error
    {
        log_production("Recovered from missing \\n");
        string_list_free($2);
        yyerrok;
    }
    | primitive_type error end_of_stmt
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

struct_member_access: 
    TK_ID TK_DOT TK_ID 
    {
        $$.instance_id = $1;
        $$.field_id = $3;
        log_production("Struct member access: %s.%s", $1, $3);
    }
;

id_list:
    TK_ID { $$ = string_list_append(NULL, $1); }
    | id_list TK_COMMA TK_ID { $$ = string_list_append($1, $3); }
;

sentence:
    assignment_sentence end_of_stmt
    | expression_sentence end_of_stmt
;

assignment_sentence:
    TK_ID TK_ASSIGN expression { handle_assigment_sentence($1, $3); }
    | struct_member_access TK_ASSIGN expression { handle_struct_member_assigment($1, $3); }
;

expression_sentence:
    expression 
    {
        report_expression(current_location(), $1);
        free_expr_string(&$1);
    }
;


/* Level 1: OR */
expression:
    expression TK_OR bool_term { $$ = eval_or($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
    | bool_term { $$ = $1; }
;

/* Level 2: AND */
bool_term:
    bool_term TK_AND bool_factor { $$ = eval_and($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
    | bool_factor { $$ = $1; }
;

/* Level 3: NOT */
bool_factor:
    TK_NOT bool_factor { $$ = eval_not($2); free_expr_string(&$2); }
    | relational_expr { $$ = $1; }
;

/* Level 4: Relational (>, <, =, <>, >=, <=) */
relational_expr:
    arith_expr TK_GT arith_expr { $$ = eval_relational($1, $3, TK_GT); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_GE arith_expr { $$ = eval_relational($1, $3, TK_GE); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_LT arith_expr { $$ = eval_relational($1, $3, TK_LT); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_LE arith_expr { $$ = eval_relational($1, $3, TK_LE); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_EQ arith_expr { $$ = eval_relational($1, $3, TK_EQ); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr TK_NE arith_expr { $$ = eval_relational($1, $3, TK_NE); free_expr_string(&$1); free_expr_string(&$3); }
    | arith_expr { $$ = $1; }
;

/* Level 5: Sum, Sub, Unary +/- */
arith_expr:
    arith_expr TK_PLUS unary_expr    { $$ = eval_add($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_expr TK_MINUS unary_expr   { $$ = eval_sub($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | unary_expr                       { $$ = $1; }
;

/* Level 5.5: Unary */
unary_expr:
    TK_PLUS unary_expr  { $$ = eval_unary_plus($2); free_expr_string(&$2); }
  | TK_MINUS unary_expr { $$ = eval_unary_minus($2); free_expr_string(&$2); }
  | arith_term          { $$ = $1; }
;

/* Level 6: *, /, % */
arith_term:
    arith_term TK_MULT arith_factor { $$ = eval_mul($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_term TK_DIV arith_factor  { $$ = eval_div($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_term TK_MOD arith_factor  { $$ = eval_mod($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
  | arith_factor                    { $$ = $1; }
;

/* Level 7: Pow (**) */
arith_factor:
    primary TK_POW arith_factor { $$ = eval_pow($1, $3); free_expr_string(&$1); free_expr_string(&$3); }
    | primary { $$ = $1; }
;

primary:
    TK_LPAREN expression TK_RPAREN { $$ = $2; log_production("Expression: Parenthesized"); }
    | literal { $$ = $1; }
    | constant { $$ = $1; }
    | TK_ID { $$ = handle_primary_id($1); }
    | struct_member_access { $$ = handle_struct_member_access_value($1); }
    | TK_SIN TK_LPAREN expression TK_RPAREN { $$ = eval_sin($3); free_expr_string(&$3); }
    | TK_COS TK_LPAREN expression TK_RPAREN { $$ = eval_cos($3); free_expr_string(&$3); }
    | TK_TAN TK_LPAREN expression TK_RPAREN { $$ = eval_tan($3); free_expr_string(&$3); }
    | TK_LEN TK_LPAREN expression TK_RPAREN { $$ = eval_len($3); free_expr_string(&$3); }
    | TK_SUBSTR TK_LPAREN expression TK_SEMICOLON expression TK_SEMICOLON expression TK_RPAREN { 
        $$ = eval_substr($3, $5, $7); 
        free_expr_string(&$3); 
        free_expr_string(&$5); 
        free_expr_string(&$7); 
    }
;

constant: 
    TK_PI
    {
        $$.type = TYPE_FLOAT;
        $$.value.float_val = $1;
        log_production("PI constant: %s (%g)", TYPE_NAME[$$.type], $1);
    }
    | TK_E
    {
        $$.type = TYPE_FLOAT;
        $$.value.float_val = $1;
        log_production("E constant: %s (%g)", TYPE_NAME[$$.type], $1);
    }

literal:
    TK_INT_LIT
    {
        $$.type = TYPE_INT;
        $$.value.int_val = $1;
        log_production("Literal: %s (%lld)", TYPE_NAME[$$.type], $1);
    }
    | TK_FLOAT_LIT
    {
        $$.type = TYPE_FLOAT;
        $$.value.float_val = $1;
        log_production("Literal: %s (%g)", TYPE_NAME[$$.type], $1);
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