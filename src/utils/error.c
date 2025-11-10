#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include "./error.h"

extern int yylineno;
extern int yycolumn; 

static int error_count = 0;
static bool errors_occurred = false;

void error_init(void) {
    error_count = 0;
    errors_occurred = false;
}

bool has_errors(void) { return errors_occurred; }

int get_error_count(void) { return error_count; }

SourceLocation current_location(void) {
    SourceLocation loc = {yylineno, yycolumn, "input"};
    return loc;
}

void report_error(ErrorLevel level, CompilerResult code, 
                  SourceLocation loc, const char* module, 
                  const char* format, ...) {
    
    error_count++;
    errors_occurred = true;
    
    char message[256];
    va_list args;
    va_start(args, format);
    vsnprintf(message, sizeof(message), format, args);
    va_end(args);
    
    const char* level_str = "ERROR";
    if (level == ERROR_LEVEL_WARNING) level_str = "WARNING";
    if (level == ERROR_LEVEL_FATAL) level_str = "FATAL";
    
    fprintf(stderr, "[%s] %s:%d:%d: %s: %s\n",
            module,
            loc.filename ? loc.filename : "<void>",
            loc.line,
            loc.column,
            level_str,
            message);
}

void yyerror(const char *s) {
    SourceLocation loc = current_location();
    if (strstr(s, "syntax error")) {
        REPORT_SYNTAX_ERROR(loc, "Syntax Error: incorrect strocture -> %s", s);
    } else if (strstr(s, "unexpected")) {
        REPORT_SYNTAX_ERROR(loc, "Unexpected Token");
    } else {
        REPORT_SYNTAX_ERROR(loc, "%s", s);
    }
}