#include "expression.h"
#include "common.h"
#include "globals.h"
#include "parser.h"
#include "../utils/error.h"
#include "../utils/log.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

void free_expr_string(ExprResult *e) {
    if (e->type == TYPE_STRING && e->value.string_val != NULL) {
        free(e->value.string_val);
    }
}

void check_numeric(ExprResult *e) {
    if (e->type != TYPE_INT && e->type != TYPE_FLOAT) {
        SourceLocation loc = current_location();
        REPORT_SEMANTIC_ERROR(loc, "Type error: expected numeric type (%s or %s)", 
            TYPE_NAME[TYPE_INT], TYPE_NAME[TYPE_FLOAT]);
    }
}

void check_boolean(ExprResult *e) {
    if (e->type != TYPE_BOOL) {
        SourceLocation loc = current_location();
        REPORT_SEMANTIC_ERROR(loc, "Type error: expected %s type", TYPE_NAME[TYPE_BOOL]);
    }
}

/* Implementación de la suma (con concatenación) */
ExprResult eval_add(ExprResult a, ExprResult b) {
    ExprResult res;
    log_production("Evaluating add");
    
    // Regla: num + string O string + num -> string
    if (a.type == TYPE_STRING || b.type == TYPE_STRING) {
        res.type = TYPE_STRING;
        char buffer_a[100], buffer_b[100];
        char *str_a = a.value.string_val;
        char *str_b = b.value.string_val;

        if (a.type == TYPE_INT) sprintf(buffer_a, "%d", a.value.int_val);
        else if (a.type == TYPE_FLOAT) sprintf(buffer_a, "%f", a.value.float_val);
        else str_a = a.value.string_val;
        
        if (b.type == TYPE_INT) sprintf(buffer_b, "%d", b.value.int_val);
        else if (b.type == TYPE_FLOAT) sprintf(buffer_b, "%f", b.value.float_val);
        else str_b = b.value.string_val;
        
        if (a.type != TYPE_STRING) str_a = buffer_a;
        if (b.type != TYPE_STRING) str_b = buffer_b;

        res.value.string_val = (char*) malloc(strlen(str_a) + strlen(str_b) + 1);
        sprintf(res.value.string_val, "%s%s", str_a, str_b);
    }
    // Regla: float + ... O ... + float -> float
    else if (a.type == TYPE_FLOAT || b.type == TYPE_FLOAT) {
        res.type = TYPE_FLOAT;
        float val_a = (a.type == TYPE_FLOAT) ? a.value.float_val : a.value.int_val;
        float val_b = (b.type == TYPE_FLOAT) ? b.value.float_val : b.value.int_val;
        res.value.float_val = val_a + val_b;
    }
    // Regla: int + int -> int
    else if (a.type == TYPE_INT && b.type == TYPE_INT) {
        res.type = TYPE_INT;
        res.value.int_val = a.value.int_val + b.value.int_val;
    }
    // Error
    else {
        SourceLocation loc = current_location();
        REPORT_SEMANTIC_ERROR(loc, "Type error: invalid operands for '+' operator");
        res.type = TYPE_VOID;
    }
    return res;
}

/* Implementación de resta (solo numérico) */
ExprResult eval_sub(ExprResult a, ExprResult b) {
    log_production("Evaluating sub");
    check_numeric(&a); check_numeric(&b);
    ExprResult res;
    if (a.type == TYPE_FLOAT || b.type == TYPE_FLOAT) {
        res.type = TYPE_FLOAT;
        double val_a = (a.type == TYPE_FLOAT) ? a.value.float_val : a.value.int_val;
        double val_b = (b.type == TYPE_FLOAT) ? b.value.float_val : b.value.int_val;
        res.value.float_val = val_a - val_b;
    } else {
        res.type = TYPE_INT;
        res.value.int_val = a.value.int_val - b.value.int_val;
    }
    return res;
}

/* Implementación de * (solo numérico) */
ExprResult eval_mul(ExprResult a, ExprResult b) {
    log_production("Evaluating mul");
    check_numeric(&a); check_numeric(&b);
    ExprResult res;
    if (a.type == TYPE_FLOAT || b.type == TYPE_FLOAT) {
        res.type = TYPE_FLOAT;
        float val_a = (a.type == TYPE_FLOAT) ? a.value.float_val : a.value.int_val;
        float val_b = (b.type == TYPE_FLOAT) ? b.value.float_val : b.value.int_val;
        res.value.float_val = val_a * val_b;
    } else {
        res.type = TYPE_INT;
        res.value.int_val = a.value.int_val * b.value.int_val;
    }
    return res;
}

/* Implementación de / (siempre devuelve float) */
ExprResult eval_div(ExprResult a, ExprResult b) {
    log_production("Evaluating div");
    check_numeric(&a); check_numeric(&b);
    ExprResult res;
    res.type = TYPE_FLOAT;
    double val_a = (a.type == TYPE_FLOAT) ? a.value.float_val : a.value.int_val;
    double val_b = (b.type == TYPE_FLOAT) ? b.value.float_val : b.value.int_val;
    if (val_b == 0.0) {
        SourceLocation loc = current_location();
        REPORT_SEMANTIC_ERROR(loc, "Runtime error: Division by zero");
        res.value.float_val = 0.0;
    } else {
        res.value.float_val = val_a / val_b;
    }
    return res;
}

/* Implementación de % (solo int) */
ExprResult eval_mod(ExprResult a, ExprResult b) {
    log_production("Evaluating mod");
    if (a.type != TYPE_INT || b.type != TYPE_INT) {
        SourceLocation loc = current_location();
        REPORT_SEMANTIC_ERROR(loc, "Type error: '%%' operator requires integer operands");
    }
    ExprResult res;
    res.type = TYPE_INT;
    if (b.value.int_val == 0) {
        SourceLocation loc = current_location();
        REPORT_SEMANTIC_ERROR(loc, "Runtime error: Modulo by zero");
        res.value.int_val = 0;
    } else {
        res.value.int_val = a.value.int_val % b.value.int_val;
    }
    return res;
}

/* Implementación de ** (solo numérico) */
ExprResult eval_pow(ExprResult a, ExprResult b) {
    log_production("Evaluating pow");
    check_numeric(&a); check_numeric(&b);
    ExprResult res;
    double val_a = (a.type == TYPE_FLOAT) ? a.value.float_val : a.value.int_val;
    double val_b = (b.type == TYPE_FLOAT) ? b.value.float_val : b.value.int_val;
    double result = pow(val_a, val_b);

    /* Si la base y el exponente eran int, y el resultado es entero, devolver int */
    if (a.type == TYPE_INT && b.type == TYPE_INT && result == (int)result) {
        res.type = TYPE_INT;
        res.value.int_val = (int)result;
    } else {
        res.type = TYPE_FLOAT;
        res.value.float_val = result;
    }
    return res;
}

/* Implementación de unario - */
ExprResult eval_unary_minus(ExprResult a) {
    log_production("Evaluating unary minus");
    check_numeric(&a);
    ExprResult res = a;
    if (a.type == TYPE_FLOAT) {
        res.value.float_val = -a.value.float_val;
    } else {
        res.value.int_val = -a.value.int_val;
    }
    return res;
}

ExprResult eval_unary_plus(ExprResult a) {
    log_production("Evaluating unary plus");
    check_numeric(&a);
    ExprResult res = a;
    if (a.type == TYPE_FLOAT) {
        res.value.float_val = +a.value.float_val;
    } else {
        res.value.int_val = +a.value.int_val;
    }
    return res;
}

/* Implementación de relacionales (>, <, =, etc.) */
ExprResult eval_relational(ExprResult a, ExprResult b, int op) {
    log_production("Evaluating relational op");
    check_numeric(&a); check_numeric(&b);
    ExprResult res;
    res.type = TYPE_BOOL;
    
    double val_a = (a.type == TYPE_FLOAT) ? a.value.float_val : a.value.int_val;
    double val_b = (b.type == TYPE_FLOAT) ? b.value.float_val : b.value.int_val;

    switch (op) {
        case TK_GT: res.value.bool_val = (val_a > val_b); break;
        case TK_GE: res.value.bool_val = (val_a >= val_b); break;
        case TK_LT: res.value.bool_val = (val_a < val_b); break;
        case TK_LE: res.value.bool_val = (val_a <= val_b); break;
        case TK_EQ: res.value.bool_val = (val_a == val_b); break;
        case TK_NE: res.value.bool_val = (val_a != val_b); break;
    }
    return res;
}

/* Implementación de AND */
ExprResult eval_and(ExprResult a, ExprResult b) {
    log_production("Evaluating AND");
    check_boolean(&a); check_boolean(&b);
    ExprResult res;
    res.type = TYPE_BOOL;
    res.value.bool_val = a.value.bool_val && b.value.bool_val;
    return res;
}

/* Implementación de OR */
ExprResult eval_or(ExprResult a, ExprResult b) {
    log_production("Evaluating OR");
    check_boolean(&a); check_boolean(&b);
    ExprResult res;
    res.type = TYPE_BOOL;
    res.value.bool_val = a.value.bool_val || b.value.bool_val;
    return res;
}

/* Implementación de NOT */
ExprResult eval_not(ExprResult a) {
    log_production("Evaluating NOT");
    check_boolean(&a);
    ExprResult res;
    res.type = TYPE_BOOL;
    res.value.bool_val = !a.value.bool_val;
    return res;
}