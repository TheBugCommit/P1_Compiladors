#include <stdio.h>
#include "type_check.h"
#include "../utils/error.h"

bool type_check_assignment(DATA_TYPE variable_type, DATA_TYPE expression_type, SourceLocation loc) {
    if (variable_type != expression_type) {
        REPORT_SEMANTIC_ERROR(loc, 
            "Incompatible types in assignment. Variable: %d, Expression: %d", 
            variable_type, expression_type);
        return false;
    }
    return true;
}

bool type_check_expression(DATA_TYPE type, SourceLocation loc) {
    if (type == TYPE_UNKNOWN) {
        REPORT_SEMANTIC_ERROR(loc, "Unknown type in expression");
        return false;
    }
    return true;
}

void type_check_variable_declaration(const char* name, DATA_TYPE type, SourceLocation loc) {
    if (type == TYPE_UNKNOWN) {
        REPORT_SEMANTIC_ERROR(loc, "Unknown type for variable '%s'", name);
    }
}