#ifndef __AST_H
#define __AST_H

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>

#define MAX_COLNAME_LENGTH 128
#define YYLTYPE int

#define FREE(a) \
  do            \
  {             \
    if (a)      \
      free(a);  \
    a = NULL;   \
  } while (0)

#define FCLOSE(a) \
  do              \
  {               \
    if (a)        \
      fclose(a);  \
    a = NULL;     \
  } while (0)

#define DELETE_RETURN_CLAUSE_NODE(a) \
  do                                 \
  {                                  \
    delete_return_clause_node(a);    \
    a = NULL;                        \
  } while (0)

#define DELETE_WHERE_CLAUSE_NODE(a) \
  do                                \
  {                                 \
    delete_where_clause_node(a);    \
    a = NULL;                       \
  } while (0)

#define DELETE_MATCH_CLAUSE_NODE(a) \
  do                                \
  {                                 \
    delete_match_clause_node(a);    \
    a = NULL;                       \
  } while (0)

#define ERROR(msg)                     \
  do                                   \
  {                                    \
    module_yyerror(scanner, mod, msg); \
    return 1;                          \
  } while (0)

#ifdef __YYEMIT
#define _emit emit
#else
#define _emit
#endif

typedef enum NodeTag
{
  T_Node,
  T_List,
  T_AnnoyPattern,
  T_AnyExpr,
  T_ComparisionExpr_Stru,
  T_Comparision_Stru,
  T_CreateStmtClause,
  T_DeleteStmtClause,
  T_ExpPrInvocation,
  T_IntLiteralPattern,
  T_InQueryCallStmtClause,
  T_IntStringAppro,
  T_LiteralType,
  T_MapLiteralPattern,
  T_MapLiterals,
  T_MatchStmtClause,
  T_MergeSetClause,
  T_MergeSetExpression,
  T_MtPtStmtClause,
  T_MtPtStmtClauseLoop,
  T_NODEPattern,
  T_NodeLabel,
  T_OrderByStmtClause,
  T_PatternEleChain,
  T_PatternList,
  T_RdStmtClause,
  T_ReadingStmtClause,
  T_ReglQueryClause,
  T_RelationShip,
  T_RelationShipPattern,
  T_ReturnCols,
  T_ReturnStmtClause,
  T_SetStmtClause,
  T_SgPtStmtClause,
  T_SgStmtClause,
  T_SingleUpdatingStmtClause,
  T_SubCompExpr,
  T_UpdatingStmtClause,
  T_UnWindStmtClause,
  T_WhereStmtClause,
  T_WithStmtClause,
  T_YieldStmtClause
} NodeTag;

typedef void *core_yyscan_t;

typedef struct strbuf
{
  char *buffer;
  int capacity;
  int length;
} strbuf;

typedef struct core_yy_extra
{
  /**
   * @brief     extra type for flex
   *
   */
  strbuf literal_buf;

  // for Unicode surrogate pair
  unsigned int high_surrogate;
  int start_cond;

  // for the location of the current token and the actual position of it
  const char *scan_buf;
  int last_loc;
} core_yy_extra;

typedef struct Node
{
  NodeTag type;
} Node;

#define newNode(size, tag)                                                              \
  ({                                                                                    \
    Node *_result;                                                                      \
    assert((size) >= sizeof(Node)); /* 检测申请的内存大小，>>=sizeof(Node) */ \
    _result = (Node *)malloc(size); /* 申请内存 */                                  \
    _result->type = (tag);          /*设置TypeTag */                                  \
    _result;                        /*返回值*/                                       \
  })
#define makeNode(_type_) ((_type_ *)newNode(sizeof(_type_), T_##_type_))
#define nodeTag(nodeptr) (((const Node *)(nodeptr))->type)
#define NodeSetTag(nodeptr, t) (((Node *)(nodeptr))->type = (t))
#define IsA(nodeptr, _type_) (nodeTag(nodeptr) == T_##_type_) /* IsA(stmt,T_Stmt)*/

//------------------------------------------------------------------------------
/* List Structor */
typedef struct ListCell ListCell;

struct ListCell
{
  union
  {
    void *ptr_value; /* data */
    int int_value;
  } data;
  ListCell *next;
};

typedef struct List
{
  NodeTag type; /* T_List T_IntList .... */
  int length;   /* length of this list */
  ListCell *head;
  ListCell *tail;
} List;

#define NIL ((List *)NULL)
#define lnext(lc) ((lc)->next)
#define lfirst(lc) ((lc)->data.ptr_value)

static inline ListCell *list_head(const List *l)
{
  return l ? l->head : NULL;
}
static inline ListCell *list_tail(List *l) { return l ? l->tail : NULL; }
static inline int list_length(const List *l) { return l ? l->length : 0; }

#define list_make1(x1) lcons(x1, NIL)
#define IsPointerList(l) ((l) == NIL || IsA((l), List))
#define foreach(cell, l) \
  for ((cell) = list_head(l); (cell) != NULL; (cell) = lnext(cell))

List *lappend(List *list, void *datum);
List *lcons(void *datum, List *list);
static List *new_list(NodeTag type);
static void check_list_invariants(const List *list);
static void new_head_cell(List *list);
static void new_tail_cell(List *list);
void list_free(List *list);
void emit(char *s, ...);
//---------------------------------Return Clause------------------------------------

typedef struct OrderByStmtClause
{
  int ascDesc;                             /* asc or desc */
  char orderByColname[MAX_COLNAME_LENGTH]; /* order by ID ...*/
} OrderByStmtClause;

typedef struct ReturnCols
{
  NodeTag type;

  bool hasAlias;
  bool hasFunc;
  bool hasDistinct;
  char colname[MAX_COLNAME_LENGTH];
  char funName[MAX_COLNAME_LENGTH];
  char colAlias[MAX_COLNAME_LENGTH];

} ReturnCols;

typedef struct ReturnStmtClause
{
  NodeTag type;
  bool hasOrderBy;
  bool hasDistinct;
  bool hasLimit;
  uint64_t limitNum; /* limit 4*/
  OrderByStmtClause *odb;
  List *returnCols;

} ReturnStmtClause;

//--------------------------------Where Clause------------------------------------
typedef struct IntStringAppro
{
  NodeTag type;
  int union_type;
  union
  {
    int64_t intValue;
    double approValue;
    char *strValue;
  } isa;
} IntStringAppro;

typedef struct LiteralType
{
  NodeTag type;
  int etype; //   expression   type ...
  union
  {
    int intParam;                      // IntParam
    char strParam[MAX_COLNAME_LENGTH]; // StringParam  && colname
    bool boolValue;                    // BOOL
    char ifNull[5];                    // NULLX
    double approxNumParam;             // appronum
  } ltype;
} LiteralType;

typedef struct AnyExpr
{
  NodeTag type;
  LiteralType *ltrlType;
  struct ComparisionExpr_Stru *whExpr;
  struct WhereStmtClause *whcls;
} AnyExpr;

typedef struct Comparision_Stru
{ // Expression
  NodeTag type;
  int exprType; // Literal  or   Any()   or   func()   or  IN ...
  LiteralType *ltrlType;
  char *funcOpts;

  AnyExpr *anyExpr;

  List *inExpr; //  in [  a,  b, c, d ....]
} Comparision_Stru;

typedef struct SubCompExpr // for PartialComparisonExpression
{
  NodeTag type;
  int partialType; /*
                      "IN" ----------- 0
                     ">= ,<=" -------- 1
                    */

  int compType;                        // >  >>  >= < .....
  Comparision_Stru *subComprisionExpr; // Expression
} SubCompExpr;

typedef struct ComparisionExpr_Stru
{
  NodeTag type; /* type ----   for malloc */
  int exprType; /* AND  OR   XOR   NOT   ->   type*/

  Comparision_Stru *comp; /* TO DO .....  Expression   */

  bool exPartialComExpr; // whether exists PartialComparisionExpress
  SubCompExpr *subComp;  // pointer to subComp

  bool branch; /* branch or not (void * is NULL)*/
  struct ComparisionExpr_Stru *lchild;
  struct ComparisionExpr_Stru *rchild;
  struct ComparisionExpr_Stru *nchild;
} ComparisionExpr_Stru;

typedef struct WhereStmtClause
{
  NodeTag type;
  ComparisionExpr_Stru *root; // root of tree
} WhereStmtClause;

//----------------------------------Match Clause---------------------------------------

typedef struct NodeLabel
{
  NodeTag type;
  bool exlabelName;
  char labelName[MAX_COLNAME_LENGTH];

  bool exlabelNames;
  char labelNames[MAX_COLNAME_LENGTH];
} NodeLabel;

typedef struct NODEPattern
{
  NodeTag type;
  bool vrbPattern;
  char colName[MAX_COLNAME_LENGTH];

  bool ifnodeLab;
  NodeLabel *nodeLab;

  bool exmaplit;
  struct MapLiterals *maplit;

} NODEPattern;

typedef struct MapLiteralPattern // MapLiteralPatternPart
{
  NodeTag type;
  char colName[MAX_COLNAME_LENGTH];
  struct ComparisionExpr_Stru *whexpr;
} MapLiteralPattern;

typedef struct MapLiterals // MapLiteralClause
{
  NodeTag type;
  bool exmpltpt;
  List *mapLitPattern;
} MapLiterals;

typedef struct IntLiteralPattern
{
  NodeTag type;
  bool exintLit;
  int intLit; //       [* 3 .. 4 ]
  bool exintLitColon;
  int intLitColon; //       [* 3 .. 4 ]
} IntLiteralPattern;

typedef struct RelationShip // RelationshipDetail
{
  NodeTag type;
  bool hasbracket; //  id exists  [

  bool hasPatternVal;
  char patternVal[MAX_COLNAME_LENGTH];

  bool hasRelshipTypePattern;
  char *RelshipTypePattern;

  bool hasIntLitPattern;
  IntLiteralPattern *intLitPat;

  bool ifMapLiteral;
  MapLiterals *maplit;

  //
} RelationShip;

typedef struct RelationShipPattern
{
  NodeTag type;
  int reltype; // <- ->   <- -    -->  ....
  RelationShip *relShip;
} RelationShipPattern;

typedef struct PatternEleChain
{
  NodeTag type;
  NODEPattern *ndPattern;
  RelationShipPattern *relshipPattern;

} PatternEleChain;

typedef struct AnnoyPattern // AnonymousPatternPart PatternElement
{
  NodeTag type;
  bool ifName;
  char name[MAX_COLNAME_LENGTH];
  NODEPattern *ndPattern;

  bool exptEleChain;
  List *ptnElementChain;
} AnnoyPattern;

typedef struct PatternList //
{
  NodeTag type;
  bool onlyAnnoyPtnPart;
  char colName[MAX_COLNAME_LENGTH];
  int comparision;
  AnnoyPattern *annoyPattern;
} PatternList;

typedef struct MatchStmtClause // MatchClause
{
  NodeTag type;
  List *patternList; // Pattern
} MatchStmtClause;

typedef struct CreateStmtClause
{
  NodeTag type;
  List *patternList;
} CreateStmtClause;

typedef struct DeleteStmtClause
{
  NodeTag type;
  ComparisionExpr_Stru *root;
} DeleteStmtClause;

typedef struct SetStmtClause
{
  NodeTag type;
  int exptype;
  char name[MAX_COLNAME_LENGTH];
  ComparisionExpr_Stru *wh;
  MapLiterals *mp;
} SetStmtClause;

typedef struct MergeSetClause
{
  NodeTag type;
  int exptype;
  List *st;
} MergeSetClause;

typedef struct MergeSetExpression
{
  NodeTag type;
  AnnoyPattern *annoyPattern;
  List *mgstexp;
} MergeSetExpression;

typedef struct UpdatingStmtClause /* UpdatingClause */
{
  NodeTag type;
  CreateStmtClause *crt;
  DeleteStmtClause *dlt;
  int ltype; /*   SET or Remove
              *       Other   : 0
              *       Set     : 1
              *       Remove  : 2
              *       Merge   : 3
              */
  List *st;
  MergeSetExpression *mg;
} UpdatingStmtClause;
typedef struct SingleUpdatingStmtClause
{
  NodeTag type;
  int branch; /*
               *  ReturnClause                      0
               *  UpdatingClause                    1
               *  UpdatingClause + ReturnClause     2
               */
  UpdatingStmtClause *upd;
  ReturnStmtClause *rt;
} SingleUpdatingStmtClause;

typedef struct ExpPrInvocation
{
  NodeTag type;
  char name[MAX_COLNAME_LENGTH];
  bool exwhls;
  List *whls; /* ExplicitProcedureStmtClause */
} ExpPrInvocation;

typedef struct YieldStmtClause
{
  NodeTag type;
  int ydtype; /*
               *  YeildClause:
               *          [Only support one column behind YIELD ...]
               *
               *  0   ---   YIELD ReturnExprList WhereClause
               *  *   ---   YIELD '*' WhereClause
               */
  char returnCols[MAX_COLNAME_LENGTH];
  bool hascolalis;
  char colAlias[MAX_COLNAME_LENGTH];
  WhereStmtClause *wh;
} YieldStmtClause;

typedef struct InQueryCallStmtClause
{
  NodeTag type;
  ExpPrInvocation *exp;
  YieldStmtClause *yd;
} InQueryCallStmtClause;

typedef struct UnWindStmtClause
{
  NodeTag type;
  ComparisionExpr_Stru *root;
  char colAlias[MAX_COLNAME_LENGTH];
} UnWindStmtClause;

typedef struct ReadingStmtClause
{
  NodeTag type;
  int cmdtype;
  MatchStmtClause *mch;
  WhereStmtClause *wh;
  InQueryCallStmtClause *inq;
  UnWindStmtClause *unwd;
} ReadingStmtClause;

typedef struct RdStmtClause
{
  NodeTag type;
  bool ifnull;
  ReadingStmtClause *rdstcls;
} RdStmtClause;

typedef struct SgPtStmtClause
{
  NodeTag type;
  bool ifrd;
  RdStmtClause *rdst;
  SingleUpdatingStmtClause *sgupd;
} SgPtStmtClause;

typedef struct WithStmtClause
{
  NodeTag type;
  bool hasOrderBy;
  bool hasDistinct;
  bool hasLimit;
  uint64_t limitNum; /* limit 4*/
  OrderByStmtClause *odb;
  List *returnCols;
  bool ifwh;
  WhereStmtClause *wh;
} WithStmtClause;

typedef struct MtPtStmtClause
{
  NodeTag type;
  bool ifrd;
  RdStmtClause *rd;
  UpdatingStmtClause *upd;
  WithStmtClause *wth;
} MtPtStmtClause;

typedef struct MtPtStmtClauseLoop
{
  NodeTag type;
  List *mtqrlp; /* MtPtStmtClause */
  SgPtStmtClause *sg;
} MtPtStmtClauseLoop;

typedef struct SgStmtClause
{
  NodeTag type;

  /**
   *  SgPtStmtClause or MtPtStmtClauseLoop
   *
   */
  SgPtStmtClause *sg;
  MtPtStmtClauseLoop *mt;
} SgStmtClause;

typedef struct ReglQueryClause
{
  NodeTag type;
  List *rgl; /* SgStmtClause */
} ReglQueryClause;

#endif // __AST_H
