#include "delete.h"

void
delete_return_clause_node(ReturnStmtClause *rt)
{
  FREE(rt -> odb);
  if(rt->returnCols != NIL)
    list_free(rt->returnCols);
  FREE(rt);
}

void
delete_any_expr_node(AnyExpr *any)
{
  if (any -> whExpr)
    delete_comparision_expr_node((void *)(any -> whExpr));
  if (any->whcls)
    delete_where_clause_node(any->whcls);
  FREE(any);
}

void
delete_comparision_expr_node(void * comp)   // free Comparision_Stru
{
  if (comp == NULL)
    return ;
  else
  {
    Comparision_Stru *fr = (Comparision_Stru *)comp;
    FREE(fr -> ltrlType);
    FREE(fr -> funcOpts);
    if (fr -> anyExpr)
    {
      delete_any_expr_node(fr -> anyExpr);
    }
    if (fr -> inExpr != NIL)
      list_free(fr -> inExpr);
  }
}

void
delete_subcomparision_expr_node(void * comp)
{
  if (comp == NULL)
    return ;
  else
  {
    SubCompExpr *sub = (SubCompExpr *)comp;
    delete_comparision_expr_node((void *)(sub->subComprisionExpr));
  }
}

void
delete_comparision_clause_node(ComparisionExpr_Stru *se)
{
  //  free the whole tree
  if (se->exprType == -1)                             // leaf node
  {
    delete_comparision_expr_node(se->comp);           // free se->comp
    if (se->exPartialComExpr)                              // free se
      delete_subcomparision_expr_node(se->subComp);   // free se->comp
    FREE(se);  
  }
  else if (se->exprType == 'F')               //  branch node (all child node have been free)
  {
    FREE(se->lchild);
    FREE(se->rchild);
    FREE(se->nchild);
    FREE(se);  
  }
  else if (se->exprType == 'N')               // NOT
  {
    delete_comparision_clause_node(se->nchild);
    se->exprType = 'F';                      // mark the branch node
    delete_comparision_clause_node(se);
  }
  else
  {
    delete_comparision_clause_node(se->lchild);
    delete_comparision_clause_node(se->rchild);
    se->exprType = 'F';                     //  mark the branch node
    delete_comparision_clause_node(se);
  }
}

void
delete_where_clause_node(WhereStmtClause	 *wh)
{
    delete_comparision_clause_node(wh->root);
    wh->root = NULL;
}


void
delete_node_lab_node(NodeLabel *nodelab)
{
  FREE(nodelab);
}

void
delete_map_literals_node(MapLiterals *maplits)
{
  if (maplits->exmpltpt)
    delete_map_literal_pattern_node((MapLiteralPattern *)maplits->mapLitPattern);
}

void
delete_node_pattern_node(NODEPattern *nodeptn)
{
  if (nodeptn->ifnodeLab)
    delete_node_lab_node(nodeptn->nodeLab);
  if (nodeptn->exmaplit)
    delete_map_literals_node(nodeptn->maplit);
}

void
delete_map_literal_pattern_node(MapLiteralPattern *mapltptn)
{
  if (mapltptn->whexpr != NULL)
    delete_comparision_expr_node((ComparisionExpr_Stru *)(mapltptn->whexpr));
}

void 
delete_map_literal_node(MapLiterals *maplit)
{
  if (maplit->exmpltpt)
  {
    ListCell   *cell;



	  cell = list_head(maplit->mapLitPattern);
	  while (cell != NULL)
	  {
		  ListCell   *tmp = cell;

		  cell = lnext(cell);
		  
			delete_map_literal_pattern_node((MapLiteralPattern *)lfirst(tmp));
  }
  }
}

void
delete_relation_ship_node(RelationShip *relship)
{
  if (relship->hasRelshipTypePattern)
    FREE(relship->RelshipTypePattern);
  if (relship->hasIntLitPattern)
    FREE(relship->intLitPat);
  if (relship->ifMapLiteral)
    delete_map_literal_node(relship->maplit);
}

void
delete_relation_ship_pattern_node(RelationShipPattern *relshipptn)
{
  if (relshipptn->relShip != NULL)
  {
    delete_relation_ship_node(relshipptn->relShip);
  }
}

void 
delete_pattern_element_chain_node(PatternEleChain *ptnchn)
{
  if (ptnchn->ndPattern != NULL)
  {
    delete_node_pattern_node(ptnchn->ndPattern);
  }
  if (ptnchn->relshipPattern != NULL)
  {
    delete_relation_ship_pattern_node(ptnchn->relshipPattern);
  }
}

void 
delete_annoy_pattern_node(AnnoyPattern *anptn)
{
  if (anptn->ndPattern != NULL)
    delete_node_pattern_node(anptn->ndPattern);
  if (anptn->ptnElementChain != NIL)
  {
    ListCell   *cell;


	  cell = list_head(anptn->ptnElementChain);
	  while (cell != NULL)
	  {
		  ListCell   *tmp = cell;

		  cell = lnext(cell);
		  
			delete_pattern_element_chain_node((PatternEleChain *)lfirst(tmp));
	  }
  }
}

void 
delete_pattern_list_node(PatternList *ptnlist)
{
  if (ptnlist->annoyPattern != NULL)
  delete_annoy_pattern_node(ptnlist->annoyPattern);
}

void 
delete_match_clause_node(MatchStmtClause *mch)
{
  if (mch->patternList != NIL)
  {
    ListCell   *cell;

	  cell = list_head(mch->patternList);
	  while (cell != NULL)
	  {
		  ListCell   *tmp = cell;

		  cell = lnext(cell);
		  
			delete_pattern_list_node((PatternList *)lfirst(tmp));
	  }
  }
}
