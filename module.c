#include "module.h"
#include "parser.h"
#include "scanner.h"

int CPR_SUCCESSED(module_yy_extra *mod)
{
  return (!mod->yyresult || mod->yyresult == 2) ? 1 : 0;
}

module_yy_extra *raw_parser(char *src)
{
  module_yy_extra *extra;
  core_yyscan_t scanner;

  if (src == NULL)
  {
    fprintf(stderr, "input of raw_parser CANNOT be NULL");
    exit(0);
  }
  scanner = module_scanner_create(src);

  extra = (module_yy_extra *)malloc(sizeof(module_yy_extra));
  extra->src = fmemopen(src, strlen(src) + 1, "r");

  extra->yyresult = module_yyparse(scanner, extra);

  module_scanner_destroy(scanner);
  return extra;
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
#else
  return NULL;
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
