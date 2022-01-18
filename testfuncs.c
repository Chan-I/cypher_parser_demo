#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "test.h"
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

    /* two subtrees */
  case '+':
  case '-':
  case '*':
  case '/':
    treefree(a->r);

    /* one subtree */
  case '|':
  case 'M':
    treefree(a->l);

    /* no subtree */
  case 'K':
    free(a);
    break;

  default: printf("internal error: free bad node %c\n", a->nodetype);
  }
}


void
emit(char *s, ...)
{
  extern yylineno;

  va_list ap;
  va_start(ap, s);

  printf("rpn: ");
  vfprintf(stdout, s, ap);
  printf("\n");
}

void 
yyerror(const char *s, ...) 
{ 
  extern yylineno; 
 
  va_list ap; 
  va_start(ap, s); 
 
  fprintf(stderr, "%d: error: ", yylineno); 
  vfprintf(stderr, s, ap); 
  fprintf(stderr, "\n"); 
}


main(int ac, char **av)
{
	printf("> ");
  return yyparse();
} /* main */