#include "declaration.h"
#include "../../utils/log.h"
#include "../../utils/error.h"
#include "../../symtab/symtab.h"
#include <stdlib.h>

void handle_simple_declaration(DATA_TYPE declared_type, StringListNode *list)
{
    StringListNode *current = list;

    while (current != NULL)
    {
        sym_value_type new_entry;
        new_entry.type = declared_type;

        int result = sym_add(current->id, &new_entry);
        if (result == SYMTAB_DUPLICATE)
        {
            SourceLocation loc = current_location();
            REPORT_SEMANTIC_ERROR(loc, "Identifier '%s' already declared", current->id);
        }

        log_production("Declared identifier: '%s'", current->id);

        current = current->next;
    }

    log_production("Complete simple declaration (Type: %s)", DATA_TYPE_STRINGS[declared_type]);

    string_list_free(current);
}
