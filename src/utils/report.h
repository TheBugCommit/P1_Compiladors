#ifndef REPORT_H
#define REPORT_H

#include "../semantic/expression.h"

void report_assignation(const char* token_id, ExprResult e);
void report_expression(ExprResult e);

#endif