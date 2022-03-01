#include "print.h"


//------   other functions ----------
bool
HasChar(char *str, char c)
{
  int i, len;
  bool haschar = false;

  len = strlen(str);
  for (i = 0;i < len;i++)
  {
    if (str[i] == c)
    {
      haschar = true;
      break;
    }
  }
  return haschar;
}



 //------   rerturn clause ----------

void
ReturnStmtPrint(ReturnStmtClause *rt, char *in, char *order)
{
  OrderByStmtClause *odb = rt->odb;
  if (rt->hasDistinct)
  {
    strcat(in, "SELECT DISTINCT ");
  }
  else
  {
	  strcat(in, "SELECT ");
  }

	ListCell *retcolCell ; 
  List *retcolList ;
  retcolList = NIL;
  retcolCell = NULL;
  retcolList = rt->returnCols;
  foreach(retcolCell,retcolList)
  {
    ReturnCols *retcol = (ReturnCols *) lfirst(retcolCell);
    if (retcol->hasFunc && retcol->hasDistinct)
    {
      strcat(in, retcol -> funName);
      strcat(in, "(DISTINCT ");
      strcat(in, retcol -> colname);
      strcat(in, ") ");
    }
    else if(retcol->hasFunc && !retcol->hasDistinct)
    {
      strcat(in, retcol -> funName);
      strcat(in, "(");
      strcat(in, retcol -> colname);
      strcat(in, ")");
    }
    else
    {
      strcat(in, retcol -> colname);
      strcat(in, " ");
    }
    
    if (retcol->hasAlias)
    {
      strcat(in, "AS ");
      strcat(in, retcol->colAlias);
      strcat(in, " ");
    }
    strcat(in, ",");
  }		
  in[strlen(in)-1] = '\0';
  if(rt->hasOrderBy) /*Order By ... DESC */
  {
    strcat(order, " ORDER BY ");
    strcat(order, odb->orderByColname);
    if (odb->ascDesc == 'A')
    {
      strcat(order, " ASC ");
    }
    else if (odb->ascDesc == 'D')
    {
      strcat(order, " DESC ");
    }
    else
    {
    }
  }
  if (rt->hasLimit)
  {
    sprintf(order+strlen(order)," LIMIT %ld",rt->limitNum);
  }
    
}
 
 //------   where clause ----------
void
PrintLT(LiteralType *lt, char *sql)
{
  char str[64];
  switch (lt->etype)
  {
  case 'I':
    strcat(sql,"'");
    sprintf(str, "%d", lt->ltype.intParam);
    strcat(sql, str);
    strcat(sql,"'");
    break;
  case 'S':
    //strcat(sql,"'");
    strcat(sql, lt->ltype.strParam);
    //strcat(sql,"'");
    break;
  case 'B':
    if (lt->ltype.boolValue)
      strcat(sql, "true");
    else
      strcat(sql, "false");
    break;    
  case 'N':
    strcat(sql, lt->ltype.ifNull);
    break;
  case 'A':
    strcat(sql,"'");
    sprintf(str, "%lf", lt->ltype.approxNumParam);
    strcat(sql, str);
    strcat(sql,"'");
    break; 
  case 'C':
    strcat(sql, lt->ltype.strParam);
    break;           
  default:
    /*TODO: elog*/
    break;
  }
}

void
PrintAE(AnyExpr *ae, char *sql)
{
  printf("do not support any function\n");
}

void
PrintISAList(List *l, char *sql)
{
  char str[64];
  int len;
  ListCell *ls = NULL;

  strcat(sql, "(");

  foreach(ls, l)
  {
    IntStringAppro *isa = (IntStringAppro *)lfirst(ls);
    switch (isa->union_type)
    {
      case 'S':
//        strcat(sql, "'");
        strcat(sql, isa->isa.strValue);
//        strcat(sql, "',");
        break;
      case 'I':
        strcat(sql, "'");
        sprintf(str, "%ld", isa->isa.intValue);
        strcat(sql, str);
        strcat(sql, "',");
        break;   
      case 'A':
        strcat(sql, "'");
        sprintf(str, "%lf", isa->isa.approValue);
        strcat(sql, str);
        strcat(sql, "',");
        break;
      default:
        /*TODO: elog*/
        break;
    }
  }
  len = strlen(sql);
  sql[len-1] = ')';
}

void
PrintSCE(SubCompExpr *sce, char *sql)
{
  if (sce->partialType == 0)
  {
    strcat(sql, " IN ");
  }
  else if (sce->partialType == 1)
  {
    switch (sce->compType)
    {
    case 1:
      strcat(sql, "<");
      break;
    case 2:
      strcat(sql, ">");
      break;
    case 3:
      strcat(sql, "<>");
      break;    
    case 4:
      strcat(sql, "=");
      break;
    case 5:
      strcat(sql, "<=");
      break;
    case 6:
      strcat(sql, ">=");
      break;                     
    default:
    /*TODO: elog*/
      break;
    }
  }
  else
  {
    /*TODO: elog*/
  }
  PrintCS(sce->subComprisionExpr, sql);
}

void
PrintCS(Comparision_Stru *cs, char *sql)
{
  switch (cs->exprType)
  {
  case 'L':
    PrintLT(cs->ltrlType, sql);
    break;
  case 'A':
    PrintAE(cs->anyExpr, sql);
    break;
  case 'F':
    strcat(sql, cs->funcOpts);
    break;
  case 'I':
    PrintISAList(cs->inExpr, sql);
    break;
  default:
    /*TODO: elog*/
    break;
  }
}

void
PrintCES(ComparisionExpr_Stru *ces, char *sql)
{
  if(ces->branch)
  {
    switch(ces->exprType)
    {
      case 'O':
        PrintCES(ces->lchild, sql);
        strcat(sql," OR ");
        PrintCES(ces->rchild, sql);
        break;
      case 'X':
        PrintCES(ces->lchild, sql);
        strcat(sql," XOR ");
        PrintCES(ces->rchild, sql);      
        break;
      case 'A':
        PrintCES(ces->lchild, sql);
        strcat(sql," AND ");
        PrintCES(ces->rchild, sql);      
        break;
      case 'N':
        strcat(sql," NOT ");
        PrintCES(ces->nchild, sql);      
        break;
      default:
        /*TODO: elog */
        break;
    }
  }
  else
  {
    PrintCS(ces->comp, sql);
    if (ces->exPartialComExpr)
      PrintSCE(ces->subComp, sql);
  }
}



void 
WhereStmtPrint(WhereStmtClause *wh, char *sql)
{
//  strcpy(sql," \nWhere Clause test ");
  strcat(sql, " WHERE ");
  PrintCES(wh->root,sql);

}

//-------- match clause  ----------

void
PrintNL(NodeLabel *nl, char *from, char *property)
{
  strcat(from, nl->labelName);
}

void
PrintNP(NODEPattern *np, char *from, char *property)
{
  if (!np->ifnodeLab)
  {
    //elog
  }
  PrintNL(np->nodeLab, from, property);
  if (!np->exmaplit)
  {
    printf("node label cannot be ignored\n");
  }
  else
  {
    PrintML(np->maplit, from, property, np->nodeLab->labelName);
  }
}

void
PrintML(MapLiterals *ml, char *from, char *property, char *labelname)
{
  ListCell *lc = NULL;
  List *l = ml->mapLitPattern;
  foreach(lc, l)
  {
    MapLiteralPattern *mlp = (MapLiteralPattern *)lfirst(lc);
    strcat(property, " AND ");
    strcat(property, labelname);
    strcat(property, ".");
    strcat(property, mlp->colName);
    strcat(property, " = ");
    PrintCES(mlp->whexpr, property);
  }
}

void
PrintRP(RelationShip *rp, char *from, char *property)
{
  if (!rp->hasRelshipTypePattern || rp->hasIntLitPattern 
  || HasChar(rp->RelshipTypePattern, '|'))
  {
    printf("relationship label cannot be ignored\n");
  }
  strcat(from, rp->RelshipTypePattern);
  strcat(from, " on id=src ");
  if (rp->ifMapLiteral)
  {  
    PrintML(rp->maplit, from, property, rp->RelshipTypePattern);
  }
}

void
PrintRSP(RelationShipPattern *rsp, char *from, char *property)
{
  switch (rsp->reltype)
  {
  case 1:
  //
    break;
  case 2:
  //
    break;    
  case 3:
    strcat(from, " join ");
    PrintRP(rsp->relShip, from, property);
    break;
  case 4:
  //
    break;
  case 5:
  //
    break;
  case 6:
  //
    break;
  case 7:
  //
    break;                  
  default:
    break;
  }
}

void
PrintPEC(PatternEleChain *pec, char *from, char *property)
{
  PrintRSP(pec->relshipPattern, from, property);
}

void
PrintAP(AnnoyPattern *ap, char *from, char *property)
{
  strcat(from, " from ");
  PrintNP(ap->ndPattern, from, property);
  ListCell *lc = NULL;

  if (ap->exptEleChain)
  {
    if (ap->ptnElementChain->length >1 )
    {
      printf("path is too long\n");
    }
    foreach(lc, ap->ptnElementChain)
    {
      PatternEleChain *pec = (PatternEleChain *)lfirst(lc);
      PrintPEC(pec, from, property);
    }
  }
}

void
PrintPList(List *l, char *from, char *property)
{
  int len;
  ListCell *lc = NULL;

  len = l->length;
  if (len > 1)
  {
    //elog
  }
  foreach(lc, l)
  {
    PatternList *pl = (PatternList *)lfirst(lc);
    PrintAP(pl->annoyPattern, from, property);
  }
}


void 
MatchStmtPrint(MatchStmtClause *mch, char *sql)
{
    char *from = (char *)malloc(8192);
    char *property = (char *)malloc(8192);

    PrintPList(mch->patternList, from, property); 
    strcat(sql, property);
    strcat(sql, from);
    free(from);
    free(property);
}
