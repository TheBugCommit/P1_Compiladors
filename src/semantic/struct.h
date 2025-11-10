#ifndef STRUCT_H
#define STRUCT_H

#include "data_types.h"
#include "string_list.h"
#include "expression.h"

StructFieldListNode* struct_field_list_append(StructFieldListNode *field_list, DATA_TYPE type, StringListNode *id_list);
int handle_struct_declaration(char* struct_id, StructFieldListNode* field_list);
void handle_struct_instances(char* struct_id, StringListNode* id_list);
ExprResult handle_struct_member_access_value(StructAccessData struct_access_data);
void handle_struct_member_assigment(StructAccessData struct_access_data, ExprResult e);
int struct_field_duplicates(const char* struct_id, const StructFieldListNode *list);
StructFieldListNode* struct_field_list_copy(const StructFieldListNode* list);
StructInstance* struct_instance_copy(const StructInstance* instance);

void struct_field_list_free(StructFieldListNode *list);
void struct_field_free(StructField *field);
void struct_instance_free(StructInstance *instance);

#endif