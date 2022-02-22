#ifndef __PRINT_H
#define __PRINT_H

#include "ast.h"



void ReturnStmtPrint(ReturnStmtClause *rt, char *in);

void WhereStmtPrint(WhereStmtClause *wh, char *sql);

void MatchStmtPrint(MatchStmtClause *mch, char *sql);

#endif