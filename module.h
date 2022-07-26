#ifndef __MODULE_H
#define __MODULE_H

#include "print.h"
#include "delete.h"

typedef struct
{
	FILE *src;
	ReglQueryClause *regl;
} module;

char *print_module(module *mod);
int parse_module(module *mod);
module *new_module_from_file(const char *filename);
module *new_module_from_stdin(void);
module *new_module_from_string(char *src);
void delete_module(module *mod);

#endif // __MODULE_H
