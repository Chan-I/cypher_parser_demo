#include "print.h"

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
    switch(isa->union_type)
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
  else if(sce->partialType == 1)
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
  PrintCES(wh->root,sql);

}

//-------- match clause  ----------
void 
MatchStmtPrint(MatchStmtClause *mch, char *sql)
{
    // TODO .... 
    strcpy(sql," \nMatch Clause test ");
}