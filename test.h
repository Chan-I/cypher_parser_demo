extern int yylineno; /* from lexer */
void yyerror( const char *s, ...);

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

/* build an AST */
struct ast *newast(int nodetype, struct ast *l, struct ast *r);
struct ast *newappnum(double d);
struct ast *newintnum(int d);

/* evaluate an AST */
double eval(struct ast *);

/* delete and free an AST */
void treefree(struct ast *);