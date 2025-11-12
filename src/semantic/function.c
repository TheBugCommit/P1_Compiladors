#include "./function.h"

#include <math.h>
#include <string.h>
#include <stdlib.h> 

#include "./expression.h"
#include "../utils/log.h"
#include "../utils/error.h"

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

ExprResult eval_substr(ExprResult input, ExprResult start, ExprResult len) {
    log_production("Evaluating SUBSTR()");
    ExprResult res;

    if (!is_string(&input)) {
        res.type = TYPE_VOID;
        return res;
    }

    if(!(is_int(&start) && is_int(&len))){
        res.type = TYPE_VOID;
        return res;
    }

    long long int pos = start.value.int_val;
    long long int count = len.value.int_val;

    if (pos < 0 || count < 0 || pos >= strlen(input.value.string_val) || pos+count > strlen(input.value.string_val)) {
        REPORT_SEMANTIC_ERROR(current_location(), "Error: SUBSTR() out of range")
        res.type = TYPE_VOID;
        return res;
    }

    res.type = TYPE_STRING;
    res.value.string_val = (char*) malloc(count + 1);
    strncpy(res.value.string_val, input.value.string_val + pos, count);
    res.value.string_val[count] = '\0';

    return res;
}
