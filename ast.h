#ifndef __AST_H
#define __AST_H

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <stdarg.h>

#define MAX_COLNAME_LENGTH 64


typedef enum NodeTag
{
    T_Node,
    T_List,
    T_ReturnStmtClause,
    T_ReturnCols,
    T_OrderByStmtClause
}NodeTag;

typedef struct Node
{
    NodeTag type;
}Node;

#define newNode(size, tag) \
({                      \
     Node *_result;  \
     assert((size) >= sizeof(Node));    /* 检测申请的内存大小，>>=sizeof(Node) */ \
     _result = (Node *) malloc(size);   /* 申请内存 */ \
     _result->type = (tag);             /*设置TypeTag */ \
     _result;                   		/*返回值*/\
})
#define makeNode(_type_) ((_type_ *)newNode(sizeof(_type_),T_##_type_))
#define nodeTag(nodeptr) (((const Node *)(nodeptr))->type)
#define NodeSetTag(nodeptr,t)	(((Node*)(nodeptr))->type = (t))  
#define IsA(nodeptr,_type_)		(nodeTag(nodeptr) == T_##_type_)  /* IsA(stmt,T_Stmt)*/



//------------------------------------------------------------------------------
/* List Structor */
typedef struct ListCell ListCell;

struct ListCell
{
  union
  {
    void    *ptr_value;   /* data */
    int     int_value;
  }       data;
  ListCell    *next;  
};

typedef struct List
{
  NodeTag   type;   /* T_List T_IntList .... */
  int       length; /* length of this list */
  ListCell  *head;
  ListCell  *tail;
}List;



#define NIL						((List *) NULL)
#define lnext(lc)				((lc)->next)
#define lfirst(lc)				((lc)->data.ptr_value)

static inline ListCell * list_head(const List *l){	return l ? l->head : NULL;}
static inline ListCell * list_tail(List *l)	{	return l ? l->tail : NULL;}
static inline int list_length(const List *l){	return l ? l->length : 0;}

#define list_make1(x1)      lcons(x1, NIL)
#define IsPointerList(l)    ((l) == NIL || IsA((l), List))
#define foreach(cell, l)	\
	for ((cell) = list_head(l); (cell) != NULL; (cell) = lnext(cell))

List *lcons(void *datum, List *list);
static List *new_list(NodeTag type);
static void new_head_cell(List *list);
static void new_tail_cell(List *list);
List *lappend(List *list, void *datum);
static void check_list_invariants(const List *list);
void list_free(List *list);




//-------------------------------------------------------------------------------


typedef struct OrderByStmtClause{
  int ascDesc ;               /* asc or desc */
  char orderByColname[MAX_COLNAME_LENGTH]; /* order by ID ...*/ 
} OrderByStmtClause;

typedef struct ReturnCols{
  NodeTag type;

  bool hasAlias ;
  bool hasFunc ;
  bool hasDistinct;
  char colname[MAX_COLNAME_LENGTH];
  char funName[MAX_COLNAME_LENGTH];
  char colAlias[MAX_COLNAME_LENGTH];

} ReturnCols;

typedef struct ReturnStmtClause{
  NodeTag type;
  bool hasOrderBy ;
  bool hasDistinct ;
  bool hasLimit ;
  int limitNum ;      /* limit 4*/
  OrderByStmtClause *odb;
  List *returnCols;

} ReturnStmtClause;

#endif // __AST_H
