#ifndef __MODULE_H
#define __MODULE_H

#include "print.h"
#include "delete.h"

typedef struct
{
	FILE *src;
	int yyresult;
	ReglQueryClause *regl;
} module_yy_extra;

module_yy_extra *raw_parser(char *src);
char *print_module(module_yy_extra *mod);
int parse_module(module_yy_extra *mod);
module_yy_extra *new_module_from_file(const char *filename);
module_yy_extra *new_module_from_stdin(void);
module_yy_extra *new_module_from_string(char *src);
void delete_module(module_yy_extra *mod);

#endif // __MODULE_H
