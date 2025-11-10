#ifndef GLOBALS_H
#define GLOBALS_H

#include "data_types.h"

extern const char* TYPE_NAME[];
void value_union_free(DATA_TYPE type, VALUE_UNION *val);

#endif