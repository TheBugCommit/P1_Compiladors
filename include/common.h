#ifndef COMMON_H
#define COMMON_H

#include <stdbool.h>

typedef enum {
    COMPILER_SUCCESS = 0,
    COMPILER_ERROR_LEXICAL,
    COMPILER_ERROR_SYNTAX, 
    COMPILER_ERROR_SEMANTIC,
    COMPILER_ERROR_IO,
    COMPILER_ERROR_MEMORY
} CompilerResult;

typedef struct {
    int line;
    int column;
    const char* filename;
} SourceLocation;

SourceLocation current_location(void);

#endif