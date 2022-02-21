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
char colNameRelType[MAX_COLNAME_LENGTH * 4];
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
	AnnoyPattern *annoyptn;
	AnyExpr *anyExpr;
	ComparisionExpr_Stru *cmpexprstru;
	Comparision_Stru *cmpStru;
	IntLiteralPattern *intltpt;
	IntStringAppro *intStrApp;
	List 	*list;
	LiteralType *ltrlType;
	MapLiterals *maplit;
	MatchStmtClause *mchstmtcls;
	NODEPattern *nodeptn;
	Node	*node;
	NodeLabel *nodelbl;
	OrderByStmtClause *odb;
	PatternEleChain *ptnEleChn;
	PatternList *ptnlist;
	RelationShip *relship;
	RelationShipPattern *relshipptn;
	ReturnCols	*rtcols;
	ReturnStmtClause	*rtstmtcls;	
	SubCompExpr *subCompExpr;
	WhereStmtClause 	*whstmtcls;
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

%token <keyword> ALL AND ANY AS ASC 
%token <keyword> BY 
%token <keyword> CONTAINS COUNT 
%token <keyword> DESC DISTINCT 
%token <keyword> ENDS EOL EXISTS 
%token <keyword> IN IS 
%token <keyword> LIMIT 
%token <keyword> MATCH MERGE 
%token <keyword> NOT NULLX 
%token <keyword> ON OR ORDER 
%token <keyword> RETURN 
%token <keyword> UNIONS 
%token <keyword> WHERE WITH 
%token <keyword> XOR 


%type <annoyptn> 	AnonymousPatternPart PatternElement 
%type <anyExpr> 	FilterExpression
%type <cmpStru> 	Expression
%type <cmpexprstru> WhereExpression
%type <floatval> 	ApproxnumParam 
%type <intltpt> 	IntegerLiteralPattern
%type <intval> 		AscDescOpt DistinctOpt LimitClause
%type <lintval> 	IntegerLiteral IntParam
%type <list> 		ApproxnumList 
			 		INExpression IntList 
			 		MapLiteralPattern 
			 		Pattern PatternElementChainClause PatternElementChains 
			 		ReturnExprList 
			 		StringList 
%type <ltrlType> 	Literal
%type <maplit> 		PropertiesPattern MapLiteralClause
%type <mod> 		sexps
%type <mchstmtcls> 	MatchClause
%type <node> 		ApproxnumParamNode 
			 		IntParamNode 
					MapLiteralPatternPart 
			 		PatternElementChain PatternPart 
			 		ReturnExpr 
			 		StringParamNode 
%type <nodelbl> 	NodeLabelsPattern
%type <nodeptn> 	NodePattern
%type <odb> 		OrderByClause
%type <relship> 	RelationshipDetail
%type <relshipptn> 	RelationshipPattern
%type <rtstmtcls> 	ReturnClause 
%type <strval>  	ColName
					FuncOpt 
					IntegerLiteralColonPatternPart IntegerLiteralPatternPart
					NodeLabel NodeLabels NumberLiteral 
					OptAsAlias 
					PropertyKey 
					RelTypeName RelTypeNamePattern RelationshipTypePattern 
					StringParam
					Variable_Pattern 
%type <subCompExpr> PartialComparisonExpression
%type <whstmtcls> 	WhereClause





%%
%start sexps;



sexps:
	MatchClause WhereClause ReturnClause	
								{
									mod -> mch = $1;
									if ($2 == NULL)
									{
										mod->exWhereExpr = false;
										mod->wh = NULL;
									}
									else
									{
										mod->exWhereExpr = true;
										mod->wh = $2;
									}																		
									mod->rt = $3;
								}
;
/* Match Clause */

MatchClause: MATCH Pattern      {
									emit("MatchClause");
									$$ = makeNode(MatchStmtClause);
									$$ -> patternList = $2;
								}
;

Pattern:PatternPart             {
									emit("Pattern");
									$$ = list_make1($1);
								}
| Pattern ',' PatternPart       {
									emit("Patterns:  ,  ");
									$$ = lappend($1, $3);
								}
;

PatternPart:AnonymousPatternPart               
								{
									emit("Pattern_part");
									PatternList *ptl = makeNode(PatternList);
									ptl -> onlyAnnoyPtnPart = false;
									ptl -> annoyPattern = $1;
									$$ = (Node *)ptl;
								}
| ColName COMPARISON AnonymousPatternPart      
								{	
									emit("pattern_part  %d ",$2);
									PatternList *ptl = makeNode(PatternList);
									ptl -> onlyAnnoyPtnPart = true;
									strncpy(ptl -> colName, $1, strlen($1));
									ptl -> comparision = $2;   // >>  >=  >  ....
									ptl -> annoyPattern = $3;
									$$ = (Node *)ptl;
								}
;

AnonymousPatternPart:PatternElement             
								{
									emit("AnonymousPatternPart");
									$$ = $1;
								}
;

PatternElement:'(' PatternElement ')'           
								{
									emit("( PatternElement )");
									$$ = makeNode(AnnoyPattern);
									$$ -> ifName = false;
								}
| NAME '(' PatternElement ')'   {
									emit("Function Name ( )");
									$$ = makeNode(AnnoyPattern);
									$$ -> ifName = true;
								}
| NodePattern PatternElementChainClause        
								{	
									emit("NodePattern : ");
									$$ = makeNode(AnnoyPattern);
									$$ -> ndPattern = $1;
									if ($2 == NULL)
									{
										$$ -> exptEleChain = false;
										$$ -> ptnElementChain = NULL;		
									}	
									else
									{
										$$ -> exptEleChain = true;
										$$ -> ptnElementChain = $2;
									}	
								}
;

PatternElementChainClause:      {
									emit("");
									$$ = NULL;
								}
| PatternElementChains          {	
									$$ = $1;
								}
;

PatternElementChains:PatternElementChain        
								{
									emit("PatternElementChain");
									$$ = list_make1($1);
								}
| PatternElementChains PatternElementChain      
								{	
									emit("PatternElementChain PatternElementChain ...");
									$$ = lappend($1,$2);
								}
;

PatternElementChain:RelationshipPattern NodePattern     
								{
									emit("PatternElementChain");
									PatternEleChain *ptelch = makeNode(PatternEleChain);
									ptelch -> ndPattern = $2;
									ptelch -> relshipPattern = $1;
									$$ = (Node *)ptelch;
								}
;

NodePattern:'(' Variable_Pattern NodeLabelsPattern PropertiesPattern ')'  
						{	
							emit("NODEPattern");
							$$ = makeNode(NODEPattern);
							if ($2 == NULL)
								$$ -> vrbPattern = false;
							else
							{
								$$ -> vrbPattern = true;
								strncpy($$ -> colName,$2,strlen($2));
							}

							if ($3 == NULL)
								$$ -> ifnodeLab = false;
							else
							{
								$$ -> ifnodeLab = true;
								$$ -> nodeLab = $3;
							}

							if ($4 == NULL)
							{
								$$ -> exmaplit = false;
								$$ -> maplit = NULL;
							}
							else
							{
								$$ -> exmaplit = true;
								$$ -> maplit = $4;
							}
						}
;

Variable_Pattern:               {	
									emit("Variable is NULL");
									$$ = NULL;
								}
| ColName                       {	
									emit("Variable:ColName");
									$$ = $1;
								}
;

NodeLabelsPattern:              {
									emit("NodeLabelsPattern");
									$$ = NULL;
								}
| NodeLabel NodeLabels          {	
									emit("NodeLabel : ");
									$$  = makeNode(NodeLabel);
									if ($1 == NULL)
										$$ -> exlabelName = false;	
									else
									{
										$$ -> exlabelName = true;
										strncpy($$ -> labelName, $1, strlen($1));
									}

									if ($2 == NULL)
										$$ -> exlabelNames = false;
									else
									{
										$$ -> exlabelNames = true;
										strncpy($$ -> labelNames, $2, strlen($2));
									}
								}
;

NodeLabels:                     {
									emit("NodeLabels");
									$$ = NULL;
								}
| NodeLabel                     {	
									emit("NodeLabel");
									$$ = $1;
								}
;

NodeLabel: ':' ColName          {	
									emit("NodeLabel : ColName");
									$$ = $2;
								}
;

PropertiesPattern:              {
									emit("PropertiesPattern is NULL");
									$$ = NULL;
								}
| '{' MapLiteralClause '}'      {
									emit("MapLiteral");
									$$ = makeNode(MapLiterals);
									if ($2 == NULL)
									{
										$$ -> exmpltpt = false;
										$$ = NULL;
									}
									else
									{
										$$ -> exmpltpt = true;
										$$ = $2;
									}
								}
;

MapLiteralClause:               {
									emit("MapLiteralClause");
									$$ = NULL;
								}
| MapLiteralPattern             {
									emit("MapLiteralPattern");
									$$ -> mapLitPattern = $1;
								}
;

MapLiteralPattern:MapLiteralPatternPart                  
								{
									emit("MapLiteralPatternPart");
									$$ = list_make1($1);
								}
| MapLiteralPattern ',' MapLiteralPatternPart            
								{
									emit("MapLiteralPatternPart , MapLiteralPatternPart");
									$$ = lappend($1,$3);
								}
;

MapLiteralPatternPart:PropertyKey ':' WhereExpression         
								{
									emit("PropertyKey : Expression");
									MapLiteralPattern *mapltpat = makeNode(MapLiteralPattern);
									strncpy(mapltpat -> colName, $1, strlen($1));
									mapltpat -> whexpr = $3;
									$$ = (Node *)mapltpat;
								}
;

PropertyKey:ColName             {	
									emit("PropertyKey:ColName");
									$$ = $1;
								}
;

RelationshipPattern:LEFTARROW RelationshipDetail RIGHTARROW  
										{
											emit("<-   ->");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 1;   
											$$ -> relShip = $2;
										}
| LEFTARROW RelationshipDetail '-'      {
											emit("<-   -");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 2;  
											$$ -> relShip = $2;
										}
| '-' RelationshipDetail RIGHTARROW     {	
											emit("-    ->");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 3;  
											$$ -> relShip = $2;
										}
| '-' RelationshipDetail '-'            {
											emit("-    -");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 4;  
											$$ -> relShip = $2;
										}
| '-' RIGHTARROW                        {	
											emit("-->");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 5;  
											$$ -> relShip = NULL;
										}
| LEFTARROW '-'                         {
											emit("<--");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 6;  
											$$ -> relShip = NULL;
										}
| '-''-'                                {	
											emit("--");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 7;  
											$$ -> relShip = NULL;
										}
;

RelationshipDetail: 
 '[' Variable_Pattern RelationshipTypePattern IntegerLiteralPattern PropertiesPattern ']'    
										{	
											emit("[RelationshipDetail]");
											$$ = makeNode(RelationShip);
											$$ -> hasbracket = true;

											if ($2 == NULL)
											{
												$$ -> hasPatternVal = false;
											}
											else
											{
												$$ -> hasPatternVal = true;
												strncpy($$ -> patternVal,$2,strlen($2)+1);
											}

											if ($3 == NULL)
											{
												$$ -> hasRelshipTypePattern = false;
												$$ -> RelshipTypePattern = NULL;
											}
											else
											{
												$$ -> hasRelshipTypePattern = true;	
												$$ -> RelshipTypePattern = $3;
											}

											if ($4 == NULL)
											{
												$$ -> hasIntLitPattern = false;
												$$ -> intLitPat = NULL;
											}
											else
											{
												$$ -> hasIntLitPattern = true;
												$$ -> intLitPat = $4;
											}

											if ($5 == NULL)
											{
												$$ -> ifMapLiteral = false;	
												$$ -> maplit = NULL;
											}
											else
											{
												$$ -> ifMapLiteral = true;	
												$$ -> maplit = $5;
											}
										}
;

RelationshipTypePattern:                {	
											emit("RelationshipTypePattern is NULL");
											$$ = NULL;
										}
| ':' RelTypeName RelTypeNamePattern    {	
											emit(": RelTypeName RelTypeNamePattern");
											sprintf(colNameRelType,":%s %s",$2,$3);
											strncpy($$,colNameRelType,strlen(colNameRelType));
											memset(colNameRelType,0,strlen(colNameRelType));
										}
;

RelTypeNamePattern:         
							{
								$$ = NULL;
							}
| '|' RelTypeName           
							{
								emit("| RelTypeName");
								sprintf(colNameAttr,"|%s", $2);
								strncpy($$,colNameAttr,strlen(colNameAttr));
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
| '|' ':' RelTypeName       {	
								emit("| : RelTypeName");
								sprintf(colNameAttr,"|:%s", $3);
								strncpy($$,colNameAttr,strlen(colNameAttr));
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
;

RelTypeName:ColName        {$$ = $1;}
;

IntegerLiteralPattern:                      {
												emit("IntegerLiteralPattern is NULL");
												$$ = NULL;
											}
| '*' IntegerLiteralPatternPart IntegerLiteralColonPatternPart   
											{
												emit("* IntegerLiteralPatternPart");
												$$ = makeNode(IntLiteralPattern);
												
												if ($2 == NULL)
												{
													$$ -> exintLit = false;
												}
												else
												{
													$$ -> exintLit = true;
													$$ -> intLit = atoi($2);
												}

												if ($3 == NULL)
												{
													$$ -> exintLitColon = false;
												}
												else
												{
													$$ -> exintLitColon = true;
													$$ -> intLitColon = atoi($3);
												}
											}
;

IntegerLiteralColonPatternPart:             {$$ = NULL;}
| PPOINT IntegerLiteralPatternPart          {
												emit(".. IntegerLiteralPatternPart");
												sprintf(colNameAttr,"%s%s",$1,$2);
												$$ = malloc(strlen(colNameAttr) * sizeof(char));
												strncpy($$,colNameAttr,strlen(colNameAttr));
												memset(colNameAttr,0,strlen(colNameAttr));
											}
;

IntegerLiteralPatternPart:                	{$$ = NULL;}
| IntegerLiteral                            {
												emit("IntegerLiteral");
												sprintf(colNameAttr,"%d",$1);
												printf("-----%d\n",$1);
												$$ = malloc(strlen(colNameAttr) * sizeof(char));
												strncpy($$,colNameAttr,strlen(colNameAttr));
												memset(colNameAttr,0,strlen(colNameAttr));
											}
;

IntegerLiteral:INTNUM                       {
												emit("INTNUM %d",$1);
												$$ = $1;
											}
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

