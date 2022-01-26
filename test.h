#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <stdarg.h>

typedef enum NodeTag
{
    T_Stmt,
    T_Value
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
     _result;                   /*返回值*/\
})

#define makeNode(_type_) ((_type_ *)newNode(sizeof(_type_),T_##_type_))

#define nodeTag(nodeptr) (((const Node *)(nodeptr))->type)




/* nodes in the Abstract Syntax Tree */
struct ast {
  int nodetype;
  struct ast *l;
  struct ast *r;
};

struct numval {
  int nodetype;         /* type K */
  double number;
};




extern int yylineno; /* from lexer */
void yyerror( const char *s, ...);

/* build an AST */
struct ast *newast(int nodetype, struct ast *l, struct ast *r);
struct ast *newappnum(double d);
struct ast *newintnum(int d);

/* evaluate an AST */
double eval(struct ast *);

/* delete and free an AST */
void treefree(struct ast *);