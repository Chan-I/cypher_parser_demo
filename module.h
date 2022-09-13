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
void delete_module(module_yy_extra *mod);
int CPR_SUCCESSED(module_yy_extra *mod);
#endif // __MODULE_H
