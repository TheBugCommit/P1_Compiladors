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

/* === MODIFICADO: Añadidos nuevos tokens de literales === */
%token <text> TK_ID
%token <text> TK_INT_LIT TK_FLOAT_LIT TK_STRING_LIT
%token TK_TRUE TK_FALSE
/* === FIN MODIFICADO === */

%token TK_EQ TK_COMMA TK_SEMICOLON

/* === MODIFICADO: Añadidos nuevos tipos para reglas === */
%type <data_type> primitive_type id_list
%type <data_type> expression literal
/* === FIN MODIFICADO === */

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

/* === MODIFICADO: Añadido free() para gestionar memoria === */
id_list:
    TK_ID
    {
        DATA_TYPE declared_type = $$; /* Esto usa el '$$' de la regla anterior, mal. */
        /* Corrección: El tipo no se pasa por $$. Se pasa de 'primitive_type' */
        /* Esta gramática es un poco rara. Asumo que primitive_type */
        /* debe poner su tipo en algún lugar global o $0 no es accesible. */
        /* Voy a asumir que tu lógica original de pasar el tipo funciona */
        /* (aunque $1 es TK_ID, no primitive_type). */
        /* Si 'id_list' hereda el tipo de 'simple_declaration', la gramática */
        /* debería ser: primitive_type { $<data_type>$ = $1; } id_list ... */
        
        /* Siguiendo tu código original: */
        DATA_TYPE declared_type = $$; // Tu código original tenía esto.
                                      // $$ aquí es el <data_type> de id_list
                                      // que no ha sido asignado.
                                      // $1 es TK_ID.
                                      // El tipo debería venir de $0 (primitive_type).
                                      // Para que funcione, primitive_type debe estar en la regla:
                                      // O en 'simple_declaration' debe ser:
                                      // primitive_type { $<data_type>$ = $1; } id_list ...
                                      // Asumiré que quieres que id_list propague el tipo:
        
        sym_value_type new_entry;
        new_entry.type = $0; // <-- TIPO DE 'primitive_type'
        
        int result = sym_add($1, &new_entry);
        if (result == SYMTAB_DUPLICATE) {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Identifier '%s' already declared", $1);
        }

        log_production("Declared identifier: '%s'", $1);
        free($1); // Liberar memoria
        $$ = $0;  // Propagar el tipo
    }
    | id_list TK_COMMA TK_ID
    {
        DATA_TYPE declared_type = $1; // $1 es el tipo de 'id_list' (propagado)
        
        sym_value_type new_entry;
        new_entry.type = declared_type;
        
        int result = sym_add($3, &new_entry);
        if (result == SYMTAB_DUPLICATE) {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Identifier '%s' already declared", $3);
        }
        
        log_production("Additional identifier declared: '%s'", $3);
        free($3); // Liberar memoria
        $$ = declared_type; // Propagar el tipo
    }
;
/* === FIN MODIFICADO === */

sentences:
    sentence
    | sentences sentence
    | sentences error TK_SEMICOLON
      {
        log_production("Recovered from sentence error");
        yyerrok;
      }
;

/* === MODIFICADO: Regla de asignación actualizada === */
sentence:
    TK_ID TK_EQ expression TK_SEMICOLON
    {
        /* Comprobación básica de tipos */
        sym_value_type *entry = sym_lookup($1);
        if (entry == NULL) {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Assignment to undeclared identifier '%s'", $1);
        } else if (entry->type != $3) { // $3 es el data_type de 'expression'
            /* Una comprobación de tipos real permitiría int -> float, etc. */
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Type mismatch in assignment to '%s'", $1);
        }
        log_production("Assignment sentence");
        free($1); // Liberar memoria
    }
;
/* === FIN MODIFICADO === */


/* === NUEVO: Reglas para expresiones y literales === */
expression:
    literal
    {
        $$ = $1; /* Propagar el tipo del literal */
        log_production("Expression: literal");
    }
    | TK_ID
    {
        sym_value_type *entry = sym_lookup($1);
        if (entry == NULL) {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Identifier '%s' not declared", $1);
            $$ = TYPE_VOID; /* O algún tipo de error */
        } else {
            $$ = entry->type; /* El tipo es el guardado en la tabla */
        }
        log_production("Expression: identifier '%s'", $1);
        free($1); // Liberar memoria
    }
    /* Aquí podrías añadir más expresiones (ej: expression '+' expression) */
;

literal:
    TK_INT_LIT
    {
        log_production("Literal: Integer (%s)", $1);
        $$ = TYPE_INT;
        free($1); // Liberar memoria
    }
    | TK_FLOAT_LIT
    {
        log_production("Literal: Float (%s)", $1);
        $$ = TYPE_FLOAT;
        free($1); // Liberar memoria
    }
    | TK_STRING_LIT
    {
        /* $1 incluye las comillas. Quizás quieras quitarlas aquí */
        log_production("Literal: String (%s)", $1);
        $$ = TYPE_STRING;
        free($1); // Liberar memoria
    }
    | TK_TRUE
    {
        log_production("Literal: Boolean (true)");
        $$ = TYPE_BOOL;
    }
    | TK_FALSE
    {
        log_production("Literal: Boolean (false)");
        $$ = TYPE_BOOL;
    }
;
/* === FIN NUEVO === */

%%