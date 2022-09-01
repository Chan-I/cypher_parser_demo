#ifndef __DELETE_H
#define __DELETE_H

#include "ast.h"

void delete_annoy_pattern_node(AnnoyPattern *anptn);
void delete_annoy_pattern_node(AnnoyPattern *anptn);
void delete_any_expr_node(AnyExpr *any);
void delete_comparision_clause_node(ComparisionExpr_Stru *se);
void delete_comparision_expr_node(void * comp);
void delete_map_literal_node(MapLiterals *maplit);
void delete_map_literal_pattern_node(MapLiteralPattern *mapltptn);
void delete_map_literals_node(MapLiterals *maplits);
void delete_match_clause_node(MatchStmtClause *mch);
void delete_node_lab_node(NodeLabel *nodelab);
void delete_node_pattern_node(NODEPattern *nodeptn);
void delete_pattern_element_chain_node(PatternEleChain *ptnchn);
void delete_pattern_list_node(PatternList *ptnlist);
void delete_pattern_list_node(PatternList *ptnlist);
void delete_relation_ship_node(RelationShip *relship);
void delete_relation_ship_pattern_node(RelationShipPattern *relshipptn);
void delete_return_clause_node(ReturnStmtClause *rt);
void delete_subcomparision_expr_node(void * comp);
void delete_where_clause_node(WhereStmtClause	 *wh);		

#endif // __MODULE_H
