#include "./struct.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../symtab/symtab.h"
#include "../utils/error.h"
#include "../utils/log.h"
#include "globals.h"

StructFieldListNode* struct_field_list_append(StructFieldListNode* field_list,
                                              DATA_TYPE type,
                                              StringListNode* id_list) {
    if (type == TYPE_STRUCT) {
        REPORT_SEMANTIC_ERROR(current_location(),
                              "Invalid type declaration in struct");
        return field_list;
    }

    StructFieldListNode* list = field_list;
    StringListNode* current_id = id_list;
    while (current_id != NULL) {
        StructFieldListNode* node = malloc(sizeof(StructFieldListNode));

        StructField sf;
        sf.id = strdup(current_id->id);

        sym_value_type new_entry;
        new_entry.is_initialized = 0;
        new_entry.type = type;

        sf.data = new_entry;

        log_production("Declared struct identifier: '%s' (Type: %s)",
                       current_id->id, TYPE_NAME[type]);

        node->field = sf;
        node->next = list;
        list = node;

        current_id = current_id->next;
    }

    string_list_free(id_list);

    return list;
}

int struct_field_duplicates(const char* struct_id,
                            const StructFieldListNode* list) {
    int duplicates = 0;

    const StructFieldListNode* outer = list;
    while (outer != NULL) {
        const StructFieldListNode* inner = outer->next;
        while (inner != NULL) {
            if (strcmp(outer->field.id, inner->field.id) == 0) {
                REPORT_SEMANTIC_ERROR(
                    current_location(),
                    "In struct '%s', identifier '%s' already declared",
                    struct_id, inner->field.id);
                duplicates++;
            }
            inner = inner->next;
        }
        outer = outer->next;
    }

    return duplicates;
}

StructFieldListNode* struct_field_list_copy(const StructFieldListNode* list) {
    if (!list) return NULL;

    StructFieldListNode* copy_head = NULL;
    StructFieldListNode* copy_tail = NULL;

    const StructFieldListNode* current = list;
    while (current != NULL) {
        StructFieldListNode* node = malloc(sizeof(StructFieldListNode));
        
        node->field.data = current->field.data; 
        node->field.id = strdup(current->field.id);

        if (node->field.data.type == TYPE_STRING && current->field.data.value.string_val != NULL) {
            node->field.data.value.string_val = strdup(current->field.data.value.string_val);
        }
        
        node->next = NULL;

        if (!copy_head) {
            copy_head = node;
            copy_tail = node;
        } else {
            copy_tail->next = node;
            copy_tail = node;
        }

        current = current->next;
    }

    return copy_head;
}

StructInstance* struct_instance_copy(const StructInstance* instance){
    if (instance == NULL) {
        return NULL;
    }

    StructInstance* new_inst = (StructInstance*)malloc(sizeof(StructInstance));
    if (new_inst == NULL) {
        return NULL; 
    }

    new_inst->name = strdup(instance->name);
    new_inst->fields = struct_field_list_copy(instance->fields); 

    return new_inst;
}

void handle_struct_instance(char* struct_id, StringListNode* id_list) {}

void handle_struct_declaration(char* struct_id,
                               StructFieldListNode* field_list) {
    if (struct_id == NULL || field_list == NULL) {
        return;
    }

    if (struct_field_duplicates(struct_id, field_list)) {
        log_production("dup");

        struct_field_list_free(field_list);
        free(struct_id);
        return;
    }

    sym_value_type* entry = (sym_value_type*) malloc(sizeof(sym_value_type));
    int res = sym_lookup(struct_id, entry);
    if (res == SYMTAB_OK) {
        REPORT_SEMANTIC_ERROR(current_location(),
                              "Struct '%s' already declared", struct_id);
        struct_field_list_free(field_list);
        free(struct_id);
        return;
    }

    sym_value_type* new_entry = (sym_value_type*)malloc(sizeof(sym_value_type));
    StructInstance* inst = (StructInstance*)malloc(sizeof(StructInstance));

    inst->name = strdup(struct_id);
    inst->fields = field_list;

    new_entry->type = TYPE_STRUCT;
    new_entry->is_initialized = 1;
    new_entry->value.struct_val = inst;

    int result = sym_add(inst->name, new_entry);
    if (result != SYMTAB_OK) {
        report_error(ERROR_LEVEL_FATAL, COMPILER_SUCCESS, current_location(),
                     "SYMTAB ERROR", "Error adding struct '%s' to symtab");
        exit(1);
    }

    log_production("Declared struct: '%s' (Type: %s)", struct_id,
                   TYPE_NAME[TYPE_STRUCT]);

    free(struct_id);
}

void struct_field_free(StructField* field) {
    if (!field) return;

    if (field->id) {
        free(field->id);
        field->id = NULL;
    }

    value_union_free(field->data.type, &field->data.value);
}

void struct_field_list_free(StructFieldListNode* list) {
    StructFieldListNode* curr = list;
    while (curr) {
        StructFieldListNode* next = curr->next;
        struct_field_free(&curr->field);
        free(curr);
        curr = next;
    }
}

void struct_instance_free(StructInstance* instance) {
    if (!instance) return;

    if (instance->name) {
        free(instance->name);
        instance->name = NULL;
    }

    struct_field_list_free(instance->fields);
    instance->fields = NULL;

    free(instance);
}