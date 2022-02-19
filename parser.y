%define api.pure full
%lex-param {void *scanner}
%parse-param {void *scanner}{module *mod} //  传入参数

%define parse.trace
%define parse.error verbose

%{
#include <stdio.h>
#include "module.h"
#include "ast.h"
#include "parser.tab.h"
#include "scanner.h"

void yyerror (yyscan_t *locp, module *mod, char const *msg);

char colNameAttr[MAX_COLNAME_LENGTH];
char attrNum[MAX_COLNAME_LENGTH];
%}

%code requires
{
#include "module.h"
#include "ast.h"
}
%union 
{
	char *keyword;		/* type for keywords*/

    int intval;
	int64_t lintval;
    double floatval;
    char *strval;
    int subtok;

	Node	*node;
	List 	*list;
	LiteralType *ltrlType;
	AnyExpr *anyExpr;
	IntStringAppro *intStrApp;
	Comparision_Stru *cmpStru;
	SubCompExpr *subCompExpr;
	OrderByStmtClause *odb;
	ReturnCols	*rtcols;
	ReturnStmtClause	*rtstmtcls;	
	WhereStmtClause 	*whstmtcls;
	ComparisionExpr_Stru *cmpexprstru;
	
} /* Generate YYSTYPE from these types:  */

%token <intval> INTNUM
%token <intval> BOOL
%token <floatval> APPROXNUM
%token <strval> NAME
%token <strval> STRING
%token <strval> PPOINT
%token <strval> RIGHTARROW
%token <strval> LEFTARROW


%left OR
%left XOR
%left AND
%left NOT
%left <subtok> COMPARISON
%left '+' '-'
%left '*' '/' '%'
%left '[' ']'
%left '(' ')'
%left '.'

%token <keyword> ALL AND ANY AS ASC BY CONTAINS COUNT DESC DISTINCT ENDS EOL EXISTS 
%token <keyword> IN IS LIMIT MATCH MERGE NOT NULLX ON OR ORDER RETURN UNIONS WHERE WITH XOR 
%type <mod> sexps

%type <rtstmtcls> ReturnClause 
%type <list> ReturnExprList StringList IntList ApproxnumList INExpression
%type <node> ReturnExpr StringParamNode IntParamNode ApproxnumParamNode
%type <intval> LimitClause AscDescOpt DistinctOpt 
%type <lintval> IntParam
%type <odb> OrderByClause

%type <whstmtcls> WhereClause
%type <cmpexprstru> WhereExpression

%type <floatval> ApproxnumParam 
%type <ltrlType> Literal
%type <strval> FuncOpt
%type <subCompExpr> PartialComparisonExpression
%type <cmpStru> Expression
%type <anyExpr> FilterExpression

%type <strval> AnonymousPatternPart 

%type <strval> ColName Cypher CypherClause


%type <strval> IntegerLiteralColonPatternPart IntegerLiteralPattern IntegerLiteralPatternPart

%type <strval> MapLiteral MapLiteralClause MapLiteralPattern MapLiteralPatternPart MatchClause
%type <strval> NodeLabel NodeLabels NodeLabelsPattern NodePattern NumberLiteral
%type <strval> OptAsAlias 
%type <strval>  Pattern PatternElement PatternElementChain PatternElementChainClause PatternPart PropertiesPattern PropertyKey 
%type <strval> RelTypeName RelTypeNamePattern RelationshipDetail RelationshipPattern RelationshipTypePattern 
%type <strval> StringParam
%type <strval> Variable_Pattern




%%
%start sexps;

Cypher:					/* nil */	{}
| Cypher EOL			{printf(">");}
| Cypher CypherClause EOL		{printf(">");}
;

CypherClause: MatchClause WhereClause ReturnClause     {emit("Cypher");}
/* Match Clause */

MatchClause: MATCH Pattern        {emit("MatchClause");}
;

Pattern:PatternPart                            {emit("Pattern");}
| Pattern ',' PatternPart                      {emit("Patterns:  ,  ");}
;

PatternPart:AnonymousPatternPart               {emit("Pattern_part");}
| ColName COMPARISON AnonymousPatternPart      {emit("pattern_part  %d ",$2);}
;

AnonymousPatternPart:PatternElement             {emit("AnonymousPatternPart");}
;

PatternElement:'(' PatternElement ')'           {emit("( PatternElement )");}
| NAME '(' PatternElement ')'                   {emit("Function Name ( )");}
| NodePattern PatternElementChainClause        {emit("NodePattern : ");}
;

PatternElementChainClause:                     {emit("");}
| PatternElementChains                           {emit("PatternElementChain");}
;

PatternElementChains:PatternElementChain        {emit("PatternElementChain");}
| PatternElementChains PatternElementChain      {emit("PatternElementChain PatternElementChain ...");}
;

PatternElementChain:RelationshipPattern NodePattern     {emit("PatternElementChain");}
;

NodePattern:'(' Variable_Pattern NodeLabelsPattern PropertiesPattern ')'  {emit("NodePattern");}
;

Variable_Pattern:               {emit("Variable is NULL");}
| ColName                      {emit("Variable:ColName");}
;

NodeLabelsPattern:             {emit("NodeLabelsPattern");}
| NodeLabel NodeLabels          {emit("NodeLabel : ");}
;

NodeLabels:                     {emit("NodeLabels");}
| NodeLabel                     {emit("NodeLabel");}
;

NodeLabel: ':' ColName         {emit("NodeLabel : ColName");}
;

PropertiesPattern:             {emit("PropertiesPattern is NULL");}
| MapLiteral                    {emit("MapLiteral");}
;

MapLiteral:'{' MapLiteralClause '}'                        {emit("{MapLiteralClause}");}
;

MapLiteralClause:                                          {emit("MapLiteralClause");}
| MapLiteralPattern                                        {emit("MapLiteralPattern");}
;

MapLiteralPattern:MapLiteralPatternPart                  {emit("MapLiteralPatternPart");}
| MapLiteralPattern ',' MapLiteralPatternPart            {emit("MapLiteralPatternPart , MapLiteralPatternPart");}
;

MapLiteralPatternPart:PropertyKey ':' WhereExpression         {emit("PropertyKey : Expression");}
;

PropertyKey:ColName           {emit("PropertyKey:ColName");}
;

RelationshipPattern:LEFTARROW RelationshipDetail RIGHTARROW  {emit("<-   ->");}
| LEFTARROW RelationshipDetail '-'                        {emit("<-   -");}
| '-' RelationshipDetail RIGHTARROW                        {emit("-    ->");}
| '-' RelationshipDetail '-'                            {emit("-    -");}
| '-' RIGHTARROW                                        {emit("-->");}
| LEFTARROW '-'                                         {emit("<--");}
| '-''-'                                                {emit("--");}
;

RelationshipDetail: Variable_Pattern RelationshipTypePattern IntegerLiteralPattern PropertiesPattern      {emit("RelationshipDetail");}
'[' Variable_Pattern RelationshipTypePattern IntegerLiteralPattern PropertiesPattern ']'    {emit("[RelationshipDetail]");}
;

RelationshipTypePattern:               {emit("RelationshipTypePattern is NULL");}
| ':' RelTypeName RelTypeNamePattern   {emit(": RelTypeName RelTypeNamePattern");}
;

RelTypeNamePattern:        {}
| '|' RelTypeName           {emit("| RelTypeName");}
| '|' ':' RelTypeName       {emit("| : RelTypeName");}
;

RelTypeName:ColName        {emit("RelTypeName:ColName");}
;

IntegerLiteralPattern:                                              {emit("IntegerLiteralPattern is NULL");}
| '*' IntegerLiteralPatternPart IntegerLiteralColonPatternPart   {emit("* IntegerLiteralPatternPart");}
;

IntegerLiteralColonPatternPart:           {}
| PPOINT IntegerLiteralPatternPart        {emit(".. IntegerLiteralPatternPart");}
;

IntegerLiteralPatternPart:                {}
| IntegerLiteral                            {emit("IntegerLiteral");}
;

IntegerLiteral:INTNUM                       {emit("INTNUM %d",$1);}
;


/* Where Clause */

WhereClause:   
				{  /* no where conditions*/ 	} 
| WHERE WhereExpression 
				{
					emit("return where");
					$$ = makeNode(WhereStmtClause);
					$$ -> root = $2;   		
				}
;

WhereExpression:Expression PartialComparisonExpression      
				{
					emit("-----Into ComparisonExpression");
					$$ = makeNode(ComparisionExpr_Stru);
					$$ -> exprType = -1;
					$$ -> branch = false; //   leaf node;
					if ($2 == NULL)
					{
						$$ -> exPartialComExpr = false;
						$$ -> subComp = NULL;
					}
					else
					{
						$$ -> exPartialComExpr = true;
						$$ -> subComp = $2;
					}
					$$ -> comp = $1;   // TODO ..............
					$$ -> lchild = NULL;
					$$ -> rchild = NULL;
					$$ -> nchild = NULL;
				}
| '(' WhereExpression ')'	
				{
					$$ = $2;
				}
| WhereExpression OR WhereExpression    
				{
					emit("OR");
					$$ = makeNode(ComparisionExpr_Stru);
					$$ -> exprType = 'O';
					$$ -> exPartialComExpr = false;
					$$ -> subComp = NULL;
					$$ -> branch = true;
					$$ -> comp = NULL;
					$$ -> lchild = $1;
					$$ -> rchild = $3;
					$$ -> nchild = NULL;
				}
| WhereExpression XOR WhereExpression   
				{
					emit("XOR");
					$$ = makeNode(ComparisionExpr_Stru);
					$$ -> exprType = 'X';
					$$ -> exPartialComExpr = false;
					$$ -> subComp = NULL;
					$$ -> branch = true;
					$$ -> comp = NULL;
					$$ -> lchild = $1;
					$$ -> rchild = $3;
					$$ -> nchild = NULL;
				}
| WhereExpression AND WhereExpression   
				{
					emit("AND");
					$$ = makeNode(ComparisionExpr_Stru);
					$$ -> exprType = 'A';
					$$ -> exPartialComExpr = false;
					$$ -> subComp = NULL;
					$$ -> branch = true;
					$$ -> comp = NULL;
					$$ -> lchild = $1;
					$$ -> rchild = $3;
					$$ -> nchild = NULL;
				}
| NOT WhereExpression          
				{
					emit("NOT");
					$$ = makeNode(ComparisionExpr_Stru);
					$$ -> exprType = 'N';
					$$ -> exPartialComExpr = false;
					$$ -> subComp = NULL;
					$$ -> branch = true;
					$$ -> comp = NULL;
					$$ -> lchild = NULL;
					$$ -> rchild = NULL;
					$$ -> nchild = $2;
				}
;

// ComparisonExpression:Expression PartialComparisonExpression    {emit("ComparisonExpression");}
// ;

PartialComparisonExpression:            
							{
								$$ = NULL;
							}
| COMPARISON Expression     {
								emit("COMPARISION %d",$1);
								$$ = makeNode(SubCompExpr);
								$$ -> partialType = 1;		// > >= ...
								$$ -> compType = $1;
								$$ -> subComprisionExpr = $2;
							}
| IN Expression             {
								emit("IN");
								$$ = makeNode(SubCompExpr);
								$$ -> partialType = 0;		// IN ...
								$$ -> subComprisionExpr = $2;
							}
;

Expression:Literal                	{
										emit("Expression:Literal");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'L';
										$$ -> ltrlType = $1;
										$$ -> funcOpts = NULL;
										$$ -> anyExpr = NULL;
										$$ -> inExpr = NULL;
										
									}
| ANY '(' FilterExpression ')'      {
										emit("ANY");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'A';
										$$ -> funcOpts = NULL;
										$$ -> anyExpr = $3;
										$$ -> inExpr = NULL;
									}
| FuncOpt                           {	
										emit("func");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'F';
										$$ -> funcOpts = $1;
										$$ -> anyExpr = NULL;
										$$ -> inExpr = NULL;
									}
// | '(' WhereExpression ')'          {emit(" ( ) ");}
| INExpression                      {
										emit("INExpression");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'I';
										$$ -> funcOpts = NULL;
										$$ -> anyExpr = NULL;
										$$ -> inExpr = $1;   // in List
									}
;


FilterExpression:Literal IN WhereExpression WhereClause  
									{
										emit("FilterExpression:IN");
										$$ = makeNode(AnyExpr);
										$$ -> ltrlType = $1;
										$$ -> whExpr = $3;
										$$ -> whcls = $4;
									}
;

Literal:IntParam                {
									emit("Literal");
									$$ = makeNode(LiteralType);
									$$->type = 'I';		// Intparam;
									$$->ltype.intParam = $1;
								}
| StringParam                   {
									emit("StringList");
									$$ = makeNode(LiteralType);
									$$->type = 'S';		// StringParm
									strncpy($$->ltype.strParam, $1, strlen($1));
								}
| BOOL                          {
									emit("BOOL:%d",$1);
									$$ = makeNode(LiteralType);
									$$->type = 'B';		// BOOL
									$$->ltype.boolValue = $1;
								}
| NULLX                         {
									$$ = makeNode(LiteralType);
									$$->type = 'N';		// NULLX
									strncpy($$->ltype.ifNull,$1,4);
								}
| ApproxnumParam                {
									emit("ApproxnumList");
									$$ = makeNode(LiteralType);
									$$->type = 'A';		// ApproxNumParam;
									$$->ltype.approxNumParam = $1;
								}
| ColName                       {
									emit("ColName");
									$$ = makeNode(LiteralType);
									$$->type = 'C';		// ColName
									strncpy($$->ltype.strParam, $1, strlen($1));
								}
;

FuncOpt:NAME '(' ColName ')'         /* min(a.id) or func(a.id) */         
							{
								emit("%s(",$1);emit(")");
								sprintf(colNameAttr,"%s(%s)",$1, $3);
								$$ = (char *)malloc(strlen(colNameAttr) * sizeof(char));
								strncpy($$, colNameAttr, strlen(colNameAttr));
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
| EXISTS '(' ColName ')'    {	/* exists(a.id) */ 
								emit("EXISTS");
								sprintf(colNameAttr,"EXISTS(%s)",$3);
								$$ = (char *)malloc(strlen(colNameAttr) * sizeof(char));
								strncpy($$, colNameAttr, strlen(colNameAttr));
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							} 
| COUNT '(' DistinctOpt ColName ')'    /* count(a.id) */     	
							{
								emit("COUNT");
								if ($3 == 1)
									sprintf(colNameAttr,"COUNT(DISTINCT %s)",$1, $3);
								else
									sprintf(colNameAttr,"COUNT(%s)",$1, $3);
								$$ = (char *)malloc(strlen(colNameAttr) * sizeof(char));
								strncpy($$, colNameAttr, strlen(colNameAttr));
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
;

INExpression:                   {$$ = NULL;}
| '[' StringList ']'            {emit("StringList");$$ = $2;}
| '[' IntList ']'               {emit("IntList");$$ = $2;}
| '[' ApproxnumList ']'         {emit("ApproxnumList");$$ = $2;}
;

StringParam:STRING              {$$ = $1;}
;
IntParam:INTNUM                 {$$ = $1;}
;
ApproxnumParam:APPROXNUM        {$$ = $1;}
;

StringParamNode:STRING              {
										IntStringAppro *intstrapp = makeNode(IntStringAppro);
										intstrapp->isa.strValue = malloc(strlen($1) * sizeof(char));
										strcpy(intstrapp->isa.strValue, $1);
										intstrapp->type = 'S';
										$$ = (Node *)intstrapp;
										
									}
;

IntParamNode:INTNUM                 {
										IntStringAppro *intstrapp = makeNode(IntStringAppro);
										intstrapp->isa.intValue = (int64_t) $1;
										intstrapp->type = 'I';
										$$ = (Node *)intstrapp;
									}
;

ApproxnumParamNode:APPROXNUM        {
										IntStringAppro *intstrapp = makeNode(IntStringAppro);
										intstrapp->isa.approValue = $1;
										intstrapp->type = 'A';
										$$ = (Node *)intstrapp;
									}
;

StringList:StringParamNode          {
										emit("StringParam");
										$$ = list_make1($1);
									}
| StringList ',' StringParamNode    {
										emit("StringList , ");
										$$ = lappend($1,$3);
									}
;

IntList:IntParamNode                {
										emit("IntParam");
										$$ = list_make1($1);
									}
| IntList ',' IntParamNode          {
										emit("IntList ,");
										$$ = lappend($1,$3);
									}
;

ApproxnumList:ApproxnumParamNode        {
											emit("ApproxnumParam");
											$$ = list_make1($1);
										}
| ApproxnumList ',' ApproxnumParamNode  {
											emit("ApproxnumList ,");
											$$ = lappend($1,$3);
										}
;


sexps:
	WhereClause ReturnClause	{
									if ($1 == NULL)
									{
										mod->exWhereExpr = false;
										mod->wh = NULL;
									}
									else
									{
										mod->exWhereExpr = true;
										mod->wh = $1;
									}																		
									mod->rt = $2;
								}

ReturnClause:  RETURN DistinctOpt ReturnExprList OrderByClause LimitClause ';'
				{
					$$ = makeNode(ReturnStmtClause); /* malloc space for rt*/ 

					$$->hasDistinct = $2;   /* distinct */

					$$->returnCols = $3;
					
					if(($$->odb=$4) != NULL)	/* order by*/
						$$->hasOrderBy = 1;
					else	
						$$->hasOrderBy = 0;

					if (($$->limitNum = $5)<0)	/* limit num*/
						$$->hasLimit = false;
					else
						$$->hasLimit = true;

					/* Only run yyparse one time */
					
					// $$ = rt;
				}
;

ReturnExprList:ReturnExpr /* [name] OR [a,b,c] */    {	$$ = list_make1($1); }
| ReturnExprList ',' ReturnExpr   {	$$ = lappend($1,$3); }
;

ReturnExpr:ColName OptAsAlias 
							{
								ReturnCols *cols = makeNode(ReturnCols);
								cols->hasFunc = 0;
								cols->hasDistinct = 0;
								// emit("%s",$1);
								strncpy(cols->colname,$1,MAX_COLNAME_LENGTH);
								if($2 != NULL)
								{
									strncpy(cols->colAlias,$2,MAX_COLNAME_LENGTH);
									cols->hasAlias = 1;
								} else
									cols->hasAlias = 0;
								
								$$ = (Node *)cols;
							}
| NAME '(' ColName ')' OptAsAlias             
							{
								ReturnCols *cols = makeNode(ReturnCols);
								cols->hasFunc = 1;
								cols->hasDistinct = 0;
								if($5 != NULL)
								{
									strncpy(cols->colAlias,$5,MAX_COLNAME_LENGTH);
									cols->hasAlias = 1;
								} else
									cols->hasAlias = 0;

								strncpy(cols->funName,$1,MAX_COLNAME_LENGTH);
								
								strncpy(cols->colname,$3,MAX_COLNAME_LENGTH);
								$$ = (Node *)cols;
							}
| COUNT '(' DistinctOpt ColName ')' OptAsAlias
							{
								ReturnCols *cols = makeNode(ReturnCols);
			
								if($6 != NULL)
								{
									strncpy(cols->colAlias,$6,MAX_COLNAME_LENGTH);
									cols->hasAlias = 1;
								} else
									cols->hasAlias = 0;

								strcpy(cols->funName,"COUNT"); // ?????
								cols->hasFunc = 1;
								cols->hasDistinct = $3;

								strncpy(cols->colname,$4,MAX_COLNAME_LENGTH);
								$$ = (Node *)cols;
							}
| NumberLiteral OptAsAlias          
							{
								ReturnCols *cols = makeNode(ReturnCols);
								
								cols->hasFunc = 0;
								cols->hasDistinct = 0;
								strncpy(cols->colname,$1,MAX_COLNAME_LENGTH);

								if($2 != NULL) 
								{
									strncpy(cols->colAlias,$2,MAX_COLNAME_LENGTH);
									cols->hasAlias = 1;
								} else
									cols->hasAlias = 0;
								$$ = (Node *)cols;
							}
; /* [ ... as b] OR  [...]*/



OptAsAlias: /* no AS Alias*/ 	{$$ = NULL;}
| AS NAME       				{$$ = $2;}
;
/*
CountFuncOpt:COUNT '(' DistinctOpt ColName ')'        	
							{
								emit("COUNT");
								if ($3 == 1)
									sprintf(colNameAttr,"COUNT(DISTINCT %s)",$1, $3);
								else
									sprintf(colNameAttr,"COUNT(%s)",$1, $3);
								strncpy($$, colNameAttr, strlen(colNameAttr));
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							} 
;*/


OrderByClause: /* no orderby*/ 		{ $$ = NULL; }
| ORDER BY ColName AscDescOpt    
					{
						$$ = makeNode(OrderByStmtClause);
						$$->ascDesc = $4;
						strncpy($$->orderByColname, $3 ,MAX_COLNAME_LENGTH); 						
					}
;

DistinctOpt:   {$$ = 0;}       
| DISTINCT      {$$ = 1;}
;

AscDescOpt:/* no ASC DESC */ {$$ = -1;}
| ASC       {$$ = 'A';}
| DESC      {$$ = 'D';}
;

LimitClause:/* no limit */ {$$ = -1;}
| LIMIT INTNUM  {$$ = $2; }
;

NumberLiteral:INTNUM        { sprintf(attrNum,"%ld",$1); $$ = attrNum; }
| APPROXNUM                 { sprintf(attrNum,"%lf",$1); $$ = attrNum; }
;

ColName:NAME 
				{
					// emit("ColName");
					$$ = $1;
				}
| NAME '.' NAME  
				{
					// emit("ColName");
					sprintf(colNameAttr,"%s.%s",$1,$3);
					strncpy($$,colNameAttr,MAX_COLNAME_LENGTH); 
					// $$ = colNameAttr;
					memset(colNameAttr,0,MAX_COLNAME_LENGTH);
				}
;


%%

void yyerror (yyscan_t *locp, module *mod, char const *msg) {
	fprintf(stderr, "--> %s\n", msg);
}

