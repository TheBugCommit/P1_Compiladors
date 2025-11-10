#include "globals.h"

#include <stdio.h>
#include <stdlib.h>

#include "./semantic/struct.h"
#include "data_types.h"

const char* TYPE_NAME[] = {"INT", "FLOAT", "STRING", "BOOLEAN", "STRUCT", "VOID"};

void value_union_free(DATA_TYPE type, VALUE_UNION* val) {
    if (!val) return;

    switch (type) {
        case TYPE_STRING:
            free(val->string_val);
            val->string_val = NULL;
            break;
        case TYPE_STRUCT:
            if (val->struct_val) {
                struct_instance_free(val->struct_val);
                val->struct_val = NULL;
            }
            break;
        default:
            break;
    }
}