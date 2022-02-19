#include "module.h"
#include "parser.tab.h"
#include "scanner.h"

void
emit(char *s, ...)
{
  va_list ap;
  va_start(ap, s);

  printf("rpn: ");
  vfprintf(stdout, s, ap);
  printf("\n");
}

module *
new_module_from_stdin()
{
	module *mod = (module *) malloc(sizeof(module));
	mod->src = stdin;
	return mod;
}

module *
new_module_from_file(const char *filename)
{
	module *mod = (module *) malloc(sizeof(module));
	mod->src = fopen(filename, "r");
	return mod;
}

module *
new_module_from_string(char *src)
{
	module *mod = (module *) malloc(sizeof(module));
	mod->src = fmemopen(src, strlen(src)+1, "r");
	return mod;
}

int
parse_module(module *mod)
{
	yyscan_t sc;
	int res;
	
	yylex_init(&sc);
	yyset_in(mod->src, sc);

#ifdef _YYDEBUG
	yydebug = 1;
#endif

	res = yyparse(sc, mod);

	return res;
}

void
ReturnStmtPrint(ReturnStmtClause *rt, char *in)
{
  OrderByStmtClause *odb = rt->odb;
  char *str = in;
  if (rt->hasDistinct)
  {
    sprintf(str,"SELECT DISTINCT ");
    str  += 16;
  }
  else
  {
	  sprintf(str,"SELECT ");
    str += 7;
  }

	ListCell *retcolCell = NULL;
  List *retcolList = NIL;

  retcolList = rt->returnCols;
  foreach(retcolCell,retcolList)
  {
    ReturnCols *retcol = (ReturnCols *) lfirst(retcolCell);
    if (retcol->hasFunc && retcol->hasDistinct)
    {
      sprintf(str,"%s(DISTINCT %s) ",retcol -> funName, retcol -> colname);
      str += strlen(retcol -> funName) + strlen(retcol -> colname) + 12;
    }
    else if(retcol->hasFunc && !retcol->hasDistinct)
    {
      sprintf(str,"%s(%s) ",retcol -> funName, retcol -> colname);
      str += strlen(retcol -> funName) + strlen(retcol -> colname) + 3;
    }
    else
    {
      sprintf(str,"%s ", retcol -> colname);
      str += strlen(retcol -> colname) + 1;
    }
    
    if (retcol->hasAlias)
    {
      sprintf(str,"AS %s ",retcol->colAlias);
      str += strlen(retcol->colAlias) + 4;
    }
    *str++ = ',';
  }		
  *--str = 0;
  if(rt->hasOrderBy) /*Order By ... DESC */
  {
    if (odb->ascDesc == 'A')
    {
      sprintf(str,"\nORDER BY %s ASC ",odb->orderByColname);
      str += strlen(odb->orderByColname) + 15;
    }
    else if (odb->ascDesc == 'D')
    {
      sprintf(str,"\nORDER BY %s DESC ",odb->orderByColname);
      str += strlen(odb->orderByColname) + 16;
    }
    else
    {
      sprintf(str,"\nORDER BY %s ",odb->orderByColname);  
      str += strlen(odb->orderByColname) + 11;
    }
  }
  if(rt->hasLimit)
    sprintf(str,"LIMIT %ld",rt->limitNum);
}

void
ComparisionExprPrint(ComparisionExpr_Stru *se)
{
  // TODO  print the whole tree () comparisonExprPrint;
}

void 
WhereStmtPrint(WhereStmtClause *wh, char *sql)
{
    ComparisionExprPrint(wh->root);
}

void
delete_return_clause_node(ReturnStmtClause *rt)
{
  FREE(rt -> odb);
  if(rt->returnCols != NIL)
    list_free(rt->returnCols);
  FREE(rt);
}

void
delete_comparision_expr_node(void * comp)
{
  if (comp == NULL)
    return ;
  else
  {
      // free void * comp tree node ....
  }
}

void
delete_comparision_clause_node(ComparisionExpr_Stru *se)
{
  //  free the whole tree
  if (se->exprType == -1)   // leaf node
  {
    delete_comparision_expr_node(se->comp);  // free se->comp
    FREE(se);                                // free se
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
delete_module(module *mod)
{
	if (mod->rt != NULL) 
  {
    DELETE_RETURN_CLAUSE_NODE(mod->rt);
	}
  if (mod->exWhereExpr) 
  {
    DELETE_WHERE_CLAUSE_NODE(mod->wh);
  }
  if (mod->mch != NULL) /*  delete match clause node */
  {
    // TODO  DELETE_WHERE_CLAUSE_NODE(mod->mch); 
  }
  
	FCLOSE(mod->src);
	FREE(mod);
}

char *
print_module(module *mod)
{
  char *sql = malloc(8192 * 3);  // TODO : 8192 ???? 
  char *head = sql;
  ReturnStmtPrint(mod->rt, head);
  head += strlen(sql);
  if(mod->exWhereExpr)
    WhereStmtPrint(mod->wh, head);

  /* TO DO */

  return sql;
}