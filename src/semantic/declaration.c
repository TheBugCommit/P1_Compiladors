#include "declaration.h"
#include "../utils/log.h"
#include "../utils/error.h"
#include "../symtab/symtab.h"
#include <stdlib.h>

void handle_simple_declaration(DATA_TYPE declared_type, StringListNode *list)
{
    StringListNode *current = list;

    while (current != NULL)
    {
        sym_value_type new_entry;
        new_entry.type = declared_type;
        new_entry.is_initialized = 0;

        int result = sym_add(current->id, &new_entry);
        if (result == SYMTAB_DUPLICATE)
        {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Identifier '%s' already declared", current->id);
        }

        log_production("Declared identifier: '%s' (Type: %d)", current->id, declared_type);

        current = current->next;
    }

    string_list_free(current);
}
