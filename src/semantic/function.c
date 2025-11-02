#include "./function.h"

#include <math.h>
#include <string.h>

#include "./expression.h"
#include "../utils/log.h"

ExprResult eval_sin(ExprResult e) {
    log_production("Evaluating sin()");

    ExprResult res = e;
    if (!is_numeric(&e)) {
        res.type = TYPE_VOID;
        return res;
    }

    double val =
        (e.type == TYPE_FLOAT) ? e.value.float_val : (double)e.value.int_val;
    res.type = TYPE_FLOAT;
    res.value.float_val = sin(val);

    return res;
}

ExprResult eval_cos(ExprResult e) {
    log_production("Evaluating cos()");

    ExprResult res = e;
    if (!is_numeric(&e)) {
        res.type = TYPE_VOID;
        return res;
    }

    double val =
        (e.type == TYPE_FLOAT) ? e.value.float_val : (double)e.value.int_val;
    res.type = TYPE_FLOAT;
    res.value.float_val = cos(val);

    return res;
}

ExprResult eval_tan(ExprResult e) {
    log_production("Evaluating tan()");

    ExprResult res = e;
    if (!is_numeric(&e)) {
        res.type = TYPE_VOID;
        return res;
    }

    double val =
        (e.type == TYPE_FLOAT) ? e.value.float_val : (double)e.value.int_val;
    res.type = TYPE_FLOAT;
    res.value.float_val = tan(val);

    return res;
}

ExprResult eval_len(ExprResult e) {
    log_production("Evaluating LEN()");

    ExprResult res = e;
    if (!is_string(&e)) {
        res.type = TYPE_VOID;
        return res;
    }

    res.type = TYPE_INT;
    res.value.int_val = strlen(e.value.string_val);

    return res;
}
