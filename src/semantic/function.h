#ifndef FUNCTION_H
#define FUNCTION_H

#include "data_types.h"

ExprResult eval_sin(ExprResult e);
ExprResult eval_cos(ExprResult e);
ExprResult eval_tan(ExprResult e);
ExprResult eval_len(ExprResult e);
ExprResult eval_substr(ExprResult input, ExprResult start, ExprResult end);

#endif