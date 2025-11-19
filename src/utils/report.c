#include "./report.h"

#include <stdio.h>

#include "globals.h"

void print_value(ExprResult e) {
    switch (e.type) {
        case TYPE_INT:
            printf("%lld", e.value.int_val);
            break;
        case TYPE_FLOAT:
            printf("%g", e.value.float_val);
            break;
        case TYPE_STRING:
            if (e.value.string_val) {
                printf("\"%s\"", e.value.string_val);
            } else {
                printf("(NULL)");
            }
            break;
        case TYPE_BOOL:
            printf("%s", e.value.bool_val ? "true" : "false");
            break;
        case TYPE_STRUCT:
            if (e.value.struct_val && e.value.struct_val->name) {
                printf("%s", e.value.struct_val->name);
            } else {
                printf("Unknown Struct");
            }
            break;
        case TYPE_VOID:
            break;
    }
}

void report_expression(SourceLocation loc, ExprResult e) {
    if (e.type == TYPE_VOID) return;

    printf("[%d] ", loc.line);
    print_value(e);
    printf("\n");
}

void report_assignation(SourceLocation loc, const char* token_id,
                        ExprResult e) {
    if (e.type == TYPE_VOID) return;

    printf("[%d] %s := ", loc.line, token_id);
    print_value(e);
    printf("\n");
}

void report_struct_member_assigment(SourceLocation loc,
                                    StructAccessData struct_acces_data,
                                    ExprResult e) {
    if (e.type == TYPE_VOID) return;

    printf("[%d] %s.%s := ", loc.line,
           struct_acces_data.instance_id, struct_acces_data.field_id);
    print_value(e);
    printf("\n");
}
