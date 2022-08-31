#include "module.h"
#include "parser.h"
#include "scanner.h"

module_yy_extra *
new_module_from_file(const char *filename)
{
  module_yy_extra *mod = (module_yy_extra *)malloc(sizeof(module_yy_extra));
  mod->src = fopen(filename, "r");
  return mod;
}

module_yy_extra *
new_module_from_stdin(void)
{
  module_yy_extra *mod = (module_yy_extra *)malloc(sizeof(module_yy_extra));
  mod->src = stdin;
  return mod;
}

module_yy_extra *
new_module_from_string(char *src)
{
  module_yy_extra *mod = (module_yy_extra *)malloc(sizeof(module_yy_extra));
  mod->src = fmemopen(src, strlen(src) + 1, "r");
  return mod;
}

int parse_module(module_yy_extra *mod)
{
  yyscan_t sc;
  int res;

  module_yylex_init(&sc);
  module_yyset_in(mod->src, sc);

#ifdef _YYDEBUG
  yydebug = 1;
#endif

  res = module_yyparse(sc, mod);
  return res;
}

char *
print_module(module_yy_extra *mod)
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

void delete_module(module_yy_extra *mod)
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
