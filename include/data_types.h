#ifndef DATA_TYPES_H
#define DATA_TYPES_H

typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_BOOL,
    TYPE_UNKNOWN
} DATA_TYPE;

typedef union {
    int int_val;
    float float_val;
    char *string_val;
    int bool_val;
} VALUE_UNION;

#endif