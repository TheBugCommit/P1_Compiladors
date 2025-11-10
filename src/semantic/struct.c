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

    StructFieldListNode* new_list = field_list;
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
        node->next = new_list;
        new_list = node;

        current_id = current_id->next;
    }

    string_list_free(id_list);

    return new_list;
}

int struct_field_duplicates(const char* struct_id,
                            const StructFieldListNode* list) {
    int duplicates = 0;

    StructFieldListNode* outer = list;
    while (outer != NULL) {
        StructFieldListNode* inner = outer->next;
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

void struct_field_list_free(StructFieldListNode *list) {
    while (list != NULL) {
        StructFieldListNode *next = list->next;

        // Liberar el id del campo
        if (list->field.id != NULL) {
            free(list->field.id);
        }

        // Si quieres liberar data.string_val dentro de sym_value_type
        if (list->field.data.type == TYPE_STRING && list->field.data.value.string_val != NULL) {
            free(list->field.data.value.string_val);
        }

        // No free de data.struct_val porque estamos compartiendo la lista de campos
        // y cada instancia del struct gestiona su propio struct_val

        free(list);
        list = next;
    }
}


StructFieldListNode* struct_field_list_copy(const StructFieldListNode* list) {
    if (!list) return NULL;

    StructFieldListNode* copy_head = NULL;
    StructFieldListNode* copy_tail = NULL;

    const StructFieldListNode* current = list;
    while (current != NULL) {
        StructFieldListNode* node = malloc(sizeof(StructFieldListNode));

        node->field.id = strdup(current->field.id);
        node->field.data = current->field.data; 

        if(current->field.data.value.string_val != NULL)
            node->field.data.value.string_val = strdup(current->field.data.value.string_val);
        
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

void handle_struct_declaration(char* struct_id, StructFieldListNode* field_list,
                               StringListNode* id_list) {
    if (struct_field_duplicates(struct_id, field_list)) {
        log_production("dup");
        struct_field_list_free(field_list);
        string_list_free(id_list);
        free(struct_id);
        return;
    }

    int res = sym_add(strdup(struct_id), NULL);
    if (res == SYMTAB_DUPLICATE) {
        REPORT_SEMANTIC_ERROR(current_location(),
                              "Struct '%s' already declared", struct_id);
        struct_field_list_free(field_list);
        string_list_free(id_list);
        free(struct_id);
        return;
    }

    log_production("registered");

    sym_value_type* new_entry = malloc(sizeof(sym_value_type));
    StringListNode* current = id_list;
    while (current != NULL) {
        StructInstance* inst = (StructInstance*)malloc(sizeof(StructInstance));
        inst->name = strdup(struct_id);
        inst->fields = field_list; //copia 

        new_entry->type = TYPE_STRUCT;
        new_entry->is_initialized = 1;
        new_entry->value.struct_val = inst;

        int result = sym_add(current->id, new_entry);
        if (result == SYMTAB_DUPLICATE) {
            REPORT_SEMANTIC_ERROR(
                current_location(),
                "On Struct '%s', identifier '%s' already declared", struct_id,
                current->id);

            //free_struct_instance(inst);
            free(new_entry);
        }

        current = current->next;
    }

    log_production("Declared struct: '%s' (Type: %s)", struct_id,
                   TYPE_NAME[TYPE_STRUCT]);

    string_list_free(id_list);
    free(struct_id);
}