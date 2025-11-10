#ifndef STRUCT_H
#define STRUCT_H

#include "data_types.h"
#include "string_list.h"

StructFieldListNode* struct_field_list_append(StructFieldListNode *field_list, DATA_TYPE type, StringListNode *id_list);
void handle_struct_declaration(char* struct_id, StructFieldListNode* field_list, StringListNode *id_list);
int struct_field_duplicates(const char* struct_id, const StructFieldListNode *list);

void struct_field_list_free(StructFieldListNode *list);
void struct_field_free(StructField *field);
void struct_instance_free(StructField *field);
void struct_field_list_free(StructFieldListNode *list);

#endif