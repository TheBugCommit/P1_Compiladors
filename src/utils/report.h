#ifndef REPORT_H
#define REPORT_H

#include "../semantic/expression.h"
#include "data_types.h"

void report_assignation(const char* token_id, ExprResult e);
void report_expression(ExprResult e);
void report_struct_member_assigment(StructAccessData struct_acces_data, ExprResult e); 

#endif