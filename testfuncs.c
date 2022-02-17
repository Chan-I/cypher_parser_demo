#include "test.lex.h"
/*****************************************
 *	functions for checking the AST Tree
 *   will be deleted in the future.....
 *  TO DO
 ****************************************/
static void
check_list_invariants(const List *list)
{
	if (list == NIL)
		return;

	assert(list->length > 0);
	assert(list->head != NULL);
	assert(list->tail != NULL);

	if (list->length == 1)
		assert(list->head == list->tail);
	if (list->length == 2)
		assert(list->head->next == list->tail);
	assert(list->tail->next == NULL);
}

static void
list_free_private(List *list, bool deep)
{
	ListCell   *cell;
	check_list_invariants(list);

	cell = list_head(list);
	while (cell != NULL)
	{
		ListCell   *tmp = cell;
		cell = lnext(cell);
		if (deep)
			free(lfirst(tmp));
		free(tmp);
	}
	if (list)
		free(list);
}

void
list_free(List *list)
{
	list_free_private(list, true);
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

int
parse_module(Module *mod)
{
  int res;
	YY_BUFFER_STATE buffer = yy_scan_string(mod->src);
  res = yyparse(mod);
  yy_delete_buffer(buffer);
  return res;
}

Module *
new_module_from_string(char *str)
{
	Module *mod = (Module *) malloc(sizeof(Module));
  mod->src = malloc((strlen(str)+1) * sizeof(char));
	strncpy(mod->src,str, strlen(str)+1);
	return mod;
}
char *
print_module(Module *mod)
{
  char *sql = malloc(8192);  // TODO : 8192 ???? 
  ReturnStmtPrint(mod->rt, sql);
  /* TO DO ...*/
  // TO DO ...

  return sql;
}

void
delete_return_clause_node(ReturnStmtClause *rt)
{
  if (rt -> odb)
    free(rt -> odb);
  if(rt->returnCols != NIL)
    list_free(rt->returnCols);
}

void
delete_module(Module *mod)
{
  if(mod->src)
	  free(mod->src);
	
  if (mod->rt != NULL) {
		delete_return_clause_node(mod->rt);
	}
  /* TODO delete where clause node */
  /* TODO delete match clause node */

	free(mod);
}