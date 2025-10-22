#include "string_list.h"
#include <stdlib.h>
#include <string.h>

StringListNode* string_list_append(StringListNode *list, char *id) {
    StringListNode *node = malloc(sizeof(StringListNode));
    node->id = id; //Strdup on lexer
    node->next = list;
    return node;
}

void string_list_free(StringListNode *list) {
    while (list) {
        StringListNode *tmp = list;
        list = list->next;
        free(tmp->id);
        free(tmp);
    }
}
