#include "module.h"
#include "parser.h"
#include "scanner.h"

module *
new_module_from_file(const char *filename)
{
  module *mod = (module *)malloc(sizeof(module));
  mod->src = fopen(filename, "r");
  return mod;
}

module *
new_module_from_stdin(void)
{
  module *mod = (module *)malloc(sizeof(module));
  mod->src = stdin;
  return mod;
}

module *
new_module_from_string(char *src)
{
  module *mod = (module *)malloc(sizeof(module));
  mod->src = fmemopen(src, strlen(src) + 1, "r");
  return mod;
}

int parse_module(module *mod)
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

char *
print_module(module *mod)
{
#if 0
  char *sql = malloc(8192 * 3); // TODO : 8192 ????
  memset(sql, 0, 8192 * 3);
  char *order = malloc(8192);
  switch (mod->cmdType)
  {
  case C_MatchReturn:
    ReturnStmtPrint(mod->rt, sql, order); // print return clasue
    //  head += strlen(sql);

    if (mod->exWhereExpr)
    {
      WhereStmtPrint(mod->wh, sql); // print where clause
      //    head += strlen(head);
    }

    MatchStmtPrint(mod->mch, sql); // print match clause
    break;

  case C_Create:
    CreateStmtPrint(mod->crt, sql); // print return clasue
    break;

  case C_MatchDelete:
    MatchStmtPrint(mod->mch, sql); // print match clause
    DeleteStmtPrint(mod->dlt, sql);

    break;
  }
  strcat(sql, order);
  return sql;
#endif
}

void delete_module(module *mod)
{
#if 0
  if (mod->rt != NULL)
  {
    DELETE_RETURN_CLAUSE_NODE(mod->rt);
  }
  if (mod->exWhereExpr)
  {
    DELETE_WHERE_CLAUSE_NODE(mod->wh);
    mod->exWhereExpr = false;
  }
  if (mod->mch != NULL) /*  delete match clause node */
  {
    DELETE_MATCH_CLAUSE_NODE(mod->mch);
  }

  FCLOSE(mod->src);
  FREE(mod);
#endif
}
