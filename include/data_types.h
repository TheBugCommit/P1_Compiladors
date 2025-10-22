#ifndef DATA_TYPES_H
#define DATA_TYPES_H

typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_BOOL,
    TYPE_VOID
} DATA_TYPE;

typedef struct {
    DATA_TYPE type;
    union {
        int int_val;
        double float_val;
        char *string_val;
        char bool_val;
    } value;
} ExprResult;

typedef struct {
    DATA_TYPE type;
    char is_initialized;
    union {
        int int_val;
        double float_val;
        char *string_val;
        int bool_val;
    } value;
} sym_value_type;


#endif