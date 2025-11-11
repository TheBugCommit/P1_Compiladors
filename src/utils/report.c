#include "./report.h"

#include <stdio.h>

#include "globals.h"

void print_value(ExprResult e) {
    printf("Value: ");
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
            if(e.value.struct_val && e.value.struct_val->name) {
                printf("%s", e.value.struct_val->name);
            } else {
                printf("Unknown Struct");
            }
            break;
        case TYPE_VOID:
            break;
    }
}

void report_expression(ExprResult e) {
    if (e.type == TYPE_VOID) return;

    printf("EXPRESSION => Type: %s, ", TYPE_NAME[e.type]);
    print_value(e);
    printf("\n");
}

void report_assignation(const char* token_id, ExprResult e) {
    if (e.type == TYPE_VOID) return;

    printf("ASSIGNATION => Name: %s, Type: %s, ", token_id, TYPE_NAME[e.type]);
    print_value(e);
    printf("\n");
}

void report_struct_member_assigment(StructAccessData struct_acces_data,
                                    ExprResult e) {
    if (e.type == TYPE_VOID) return;

    printf("ASSIGNATION => Name: %s.%s, Type: %s, ", struct_acces_data.instance_id, struct_acces_data.field_id, TYPE_NAME[e.type]);
    print_value(e);
    printf("\n");
}
