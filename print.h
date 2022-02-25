#ifndef __PRINT_H
#define __PRINT_H

#include "ast.h"



void ReturnStmtPrint(ReturnStmtClause *rt, char *in);

void WhereStmtPrint(WhereStmtClause *wh, char *sql);

void MatchStmtPrint(MatchStmtClause *mch, char *sql);

void PrintCES(ComparisionExpr_Stru *ces, char *sql);

void PrintCS(Comparision_Stru *cs, char *sql);

void PrintLT(LiteralType *lt, char *sql);

void PrintAE(AnyExpr *ae, char *sql);

void PrintISAList(List *l, char *sql);

void PrintSCE(SubCompExpr *sce, char *sql);


#endif