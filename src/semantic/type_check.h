#ifndef TYPE_CHECK_H
#define TYPE_CHECK_H

#include "common.h"
#include "symtab.h"
#include "data_types.h"

bool type_check_assignment(DATA_TYPE variable_type, DATA_TYPE expression_type, SourceLocation loc);
bool type_check_expression(DATA_TYPE type, SourceLocation loc);
void type_check_variable_declaration(const char* name, DATA_TYPE type, SourceLocation loc);

#endif