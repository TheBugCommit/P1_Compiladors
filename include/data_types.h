#ifndef DATA_TYPES_H
#define DATA_TYPES_H

typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_BOOL,
    TYPE_STRUCT,
    TYPE_VOID
} DATA_TYPE;

struct StructInstance;

typedef union {
    long long int int_val;
    double float_val;
    char* string_val;
    char bool_val;
    struct StructInstance* struct_val;
} VALUE_UNION;

typedef struct {
    DATA_TYPE type;
    VALUE_UNION value;
} ExprResult;

typedef struct {
    DATA_TYPE type;
    char is_initialized;
    VALUE_UNION value;
} sym_value_type;

typedef struct {
    char* id;
    sym_value_type data;
} StructField;

typedef struct StructFieldListNode {
    StructField field;
    struct StructFieldListNode* next;
} StructFieldListNode;

typedef struct StructInstance {
    char* name;
    StructFieldListNode* fields;
} StructInstance;

typedef struct {
    char* instance_id;
    char* field_id;
} StructAccessData;

/**
 * Symtab -> k: "struct_name", v: StructFieldListNode
 * if ne instance s1, s2... create StructInstance, and duplicate
 * symtab StructFieldListNode
 */

#endif