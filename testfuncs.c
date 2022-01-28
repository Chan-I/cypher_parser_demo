#include "test.h"


List *
lcons(void *datum, List *list)
{
	assert(IsPointerList(list));

	if (list == NIL)
		list = new_list(T_List);
	else
		new_head_cell(list);

	lfirst(list->head) = datum;
	return list;
}

static List *
new_list(NodeTag type)
{
	List	   *new_list;
	ListCell   *new_head;

	new_head = (ListCell *) malloc(sizeof(*new_head));
	new_head->next = NULL;
	/* new_head->data is left undefined! */

	new_list = (List *) malloc(sizeof(*new_list));
	new_list->type = type;
	new_list->length = 1;
	new_list->head = new_head;
	new_list->tail = new_head;

	return new_list;
}

static void
new_head_cell(List *list)
{
	ListCell   *new_head;

	new_head = (ListCell *) malloc(sizeof(*new_head));
	new_head->next = list->head;

	list->head = new_head;
	list->length++;
}

static void
new_tail_cell(List *list)
{
	ListCell   *new_tail;

	new_tail = (ListCell *) malloc(sizeof(*new_tail));
	new_tail->next = NULL;

	list->tail->next = new_tail;
	list->tail = new_tail;
	list->length++;
}

List *
lappend(List *list, void *datum)
{
	assert(IsPointerList(list));

	if (list == NIL)
		list = new_list(T_List);
	else
		new_tail_cell(list);

	lfirst(list->tail) = datum;
	return list;
}





/*/--------------------------------------------------------------------
struct ast *
newast(int nodetype, struct ast *l, struct ast *r)
{ 
  struct ast *a = malloc(sizeof(struct ast));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = nodetype;
  a->l = l;
  a->r = r;
  return a;
}
struct ast *
newappnum(double d)
{ 
  struct numval *a = malloc(sizeof(struct numval));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = 'K';
  a->number = d; 
  return (struct ast *)a;
}
struct ast *
newintnum(int d)
{ 
  struct numval *a = malloc(sizeof(struct numval));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = 'K';
  a->number = (double)d; 
  return (struct ast *)a;
}

double
eval(struct ast *a)
{ 
  double v;
  
  switch(a->nodetype) {
  case 'K': v = ((struct numval *)a)->number; break;
  
  case '+': v = eval(a->l) + eval(a->r); break;
  case '-': v = eval(a->l) - eval(a->r); break;
  case '*': v = eval(a->l) * eval(a->r); break;
  case '/': v = eval(a->l) / eval(a->r); break;
  case '|': v = eval(a->l); if(v < 0) v = -v; break;
  case 'M': v = -eval(a->l); break;
  default: printf("internal error: bad node %c\n", a->nodetype);
  }
  return v;
}

void
treefree(struct ast *a)
{
  switch(a->nodetype) {

  case '+':
  case '-':
  case '*':
  case '/':
    treefree(a->r);

  case '|':
  case 'M':
    treefree(a->l);

  case 'K':
    free(a);
    break;

  default: printf("internal error: free bad node %c\n", a->nodetype);
  }
}
*/

void
emit(char *s, ...)
{

  va_list ap;
  va_start(ap, s);

  printf("rpn: ");
  vfprintf(stdout, s, ap);
  printf("\n");
}

void 
yyerror(ReturnStmtClause *in, const char *s, ...)  /* change this type */
{ 
  extern yylineno; 
 
  va_list ap; 
  va_start(ap, s); 
 
  fprintf(stderr, "%d: error: ", yylineno); 
  vfprintf(stderr, s, ap); 
  fprintf(stderr, "\n"); 
}






/*****************************************
 *	functions for checking the AST Tree
 *   will be deleted in the future.....
 *  TO DO
 ****************************************/
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
main(int ac, char **av)
{
	char sql[8192];
  ReturnStmtClause rt;
	printf("> ");
  yyparse(&rt);
  ReturnStmtPrint(&rt, sql);
  printf("%s\n",sql);
  return 0;
} /* main */
