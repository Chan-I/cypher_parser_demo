#ifndef __PRINT_H
#define __PRINT_H

#include "ast.h"

bool HasChar(char *str, char c);

void ReturnStmtPrint(ReturnStmtClause *rt, char *in, char *order);

void WhereStmtPrint(WhereStmtClause *wh, char *sql);

void MatchStmtPrint(MatchStmtClause *mch, char *sql);

void PrintCES(ComparisionExpr_Stru *ces, char *sql);

void PrintCS(Comparision_Stru *cs, char *sql);

void PrintLT(LiteralType *lt, char *sql);

void PrintAE(AnyExpr *ae, char *sql);

void PrintISAList(List *l, char *sql);

void PrintSCE(SubCompExpr *sce, char *sql);

void PrintPList(List *l, char *from, char *property);

void PrintAP(AnnoyPattern *ap, char *from, char *property);

void PrintRSP(RelationShipPattern *rsp, char *from, char *property);

void PrintRP(RelationShip *rp, char *from, char *property);

void PrintNP(NODEPattern *np, char *from, char *property);

void PrintNL(NodeLabel *nl, char *from, char *property);

void PrintPEC(PatternEleChain *pec, char *from, char *property);

void PrintML(MapLiterals *ml, char *from, char *property, char *labelname);

//void PrintMLP(MapLiteralPattern *mlp, char *from, char *property);

#endif