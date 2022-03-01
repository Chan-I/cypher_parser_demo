%define api.pure full
%lex-param {void *scanner}
%parse-param {void *scanner}{module *mod} //  传入参数

%define parse.trace
%define parse.error verbose

%{
#include "module.h"
#include "ast.h"
#include "parser.h"
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
								    return 0;    // ignore '\n' from stdin, directly exit yyparse; 
								}
;
/* Match Clause */

MatchClause: MATCH Pattern      {
									_emit("MatchClause");
									$$ = makeNode(MatchStmtClause);
									$$ -> patternList = $2;
								}
;

Pattern:PatternPart             {
									_emit("Pattern");
									$$ = list_make1($1);
								}
| Pattern ',' PatternPart       {
									_emit("Patterns:  ,  ");
									$$ = lappend($1, $3);
								}
;

PatternPart:AnonymousPatternPart               
								{
									_emit("Pattern_part");
									PatternList *ptl ;
									ptl = makeNode(PatternList);
									ptl -> onlyAnnoyPtnPart = false;
									ptl -> annoyPattern = $1;
									$$ = (Node *)ptl;
								}
| ColName COMPARISON AnonymousPatternPart      
								{	
									_emit("pattern_part  %d ",$2);
									PatternList *ptl ;
									ptl = makeNode(PatternList);
									ptl -> onlyAnnoyPtnPart = true;
									if (strlen($1) <= MAX_COLNAME_LENGTH)
										strncpy(ptl -> colName, $1, strlen($1));
									else
										ERROR("colName is too long!");
									ptl -> comparision = $2;   // >>  >=  >  ....
									ptl -> annoyPattern = $3;
									$$ = (Node *)ptl;
								}
;

AnonymousPatternPart:PatternElement             
								{
									_emit("AnonymousPatternPart");
									$$ = $1;
								}
;

PatternElement:'(' PatternElement ')'           
								{
									_emit("( PatternElement )");
									$$ = makeNode(AnnoyPattern);
									$$ -> ifName = false;
								}
| NAME '(' PatternElement ')'   {
									_emit("Function Name ( )");
									$$ = makeNode(AnnoyPattern);
									$$ -> ifName = true;
								}
| NodePattern PatternElementChainClause        
								{	
									_emit("NodePattern : ");
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
									_emit("");
									$$ = NULL;
								}
| PatternElementChains          {	
									$$ = $1;
								}
;

PatternElementChains:PatternElementChain        
								{
									_emit("PatternElementChain");
									$$ = list_make1($1);
								}
| PatternElementChains PatternElementChain      
								{	
									_emit("PatternElementChain PatternElementChain ...");
									$$ = lappend($1,$2);
								}
;

PatternElementChain:RelationshipPattern NodePattern     
								{
									_emit("PatternElementChain");
									PatternEleChain *ptelch ;
									ptelch = makeNode(PatternEleChain);
									ptelch -> ndPattern = $2;
									ptelch -> relshipPattern = $1;
									$$ = (Node *)ptelch;
								}
;

NodePattern:'(' Variable_Pattern NodeLabelsPattern PropertiesPattern ')'  
						{	
							_emit("NODEPattern");
							$$ = makeNode(NODEPattern);
							if ($2 == NULL)
								$$ -> vrbPattern = false;
							else
							{
								$$ -> vrbPattern = true;
								if (strlen($2) <= MAX_COLNAME_LENGTH)
									strncpy($$ -> colName,$2,strlen($2));
								else
									ERROR("colName is too long!");
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
									_emit("Variable is NULL");
									$$ = NULL;
								}
| ColName                       {	
									_emit("Variable:ColName");
									$$ = $1;
								}
;

NodeLabelsPattern:              {
									_emit("NodeLabelsPattern");
									$$ = NULL;
								}
| NodeLabel NodeLabels          {	
									_emit("NodeLabel : ");
									$$  = makeNode(NodeLabel);
									if ($1 == NULL)
										$$ -> exlabelName = false;	
									else
									{
										$$ -> exlabelName = true;
										if (strlen($1) <= MAX_COLNAME_LENGTH)
											strncpy($$ -> labelName, $1, strlen($1));
										else
											ERROR("LabelName is too long!");
									}

									if ($2 == NULL)
										$$ -> exlabelNames = false;
									else
									{
										$$ -> exlabelNames = true;
										if (strlen($2) <= MAX_COLNAME_LENGTH)
											strncpy($$ -> labelNames, $2, strlen($2));
										else
											ERROR("LabelName is too long!");
									}
								}
;

NodeLabels:                     {
									_emit("NodeLabels");
									$$ = NULL;
								}
| NodeLabel                     {	
									_emit("NodeLabel");
									$$ = $1;
								}
;

NodeLabel: ':' ColName          {	
									_emit("NodeLabel : ColName");
									$$ = $2;
								}
;

PropertiesPattern:              {
									_emit("PropertiesPattern is NULL");
									$$ = NULL;
								}
| '{' MapLiteralClause '}'      {
									_emit("MapLiteral");
									$$ = $2;
								}
;

MapLiteralClause:               {
									_emit("MapLiteralClause");
									$$ = NULL;
								}
| MapLiteralPattern             {
									_emit("MapLiteralPattern");
									$$ = makeNode(MapLiterals);
									if ($1 == NULL)
									{
										$$ -> exmpltpt = false;
										$$ = NULL;
									}
									else
									{
										$$ -> exmpltpt = true;
										$$ -> mapLitPattern = $1;
									}
								}
;

MapLiteralPattern:MapLiteralPatternPart                  
								{
									_emit("MapLiteralPatternPart");
									$$ = list_make1($1);
								}
| MapLiteralPattern ',' MapLiteralPatternPart            
								{
									_emit("MapLiteralPatternPart , MapLiteralPatternPart");
									$$ = lappend($1,$3);
								}
;

MapLiteralPatternPart:PropertyKey ':' WhereExpression         
								{
									_emit("PropertyKey : Expression");
									MapLiteralPattern *mapltpat;
									mapltpat = makeNode(MapLiteralPattern);
									if (strlen($1) <= MAX_COLNAME_LENGTH)
										strncpy(mapltpat -> colName, $1, strlen($1));
									else
										ERROR("colName is too long!");
									mapltpat -> whexpr = $3;
									$$ = (Node *)mapltpat;
								}
;

PropertyKey:ColName             {	
									_emit("PropertyKey:ColName");
									$$ = $1;
								}
;

RelationshipPattern:LEFTARROW RelationshipDetail RIGHTARROW  
										{
											_emit("<-   ->");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 1;   
											$$ -> relShip = $2;
										}
| LEFTARROW RelationshipDetail '-'      {
											_emit("<-   -");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 2;  
											$$ -> relShip = $2;
										}
| '-' RelationshipDetail RIGHTARROW     {	
											_emit("-    ->");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 3;  
											$$ -> relShip = $2;
										}
| '-' RelationshipDetail '-'            {
											_emit("-    -");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 4;  
											$$ -> relShip = $2;
										}
| '-' RIGHTARROW                        {	
											_emit("-->");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 5;  
											$$ -> relShip = NULL;
										}
| LEFTARROW '-'                         {
											_emit("<--");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 6;  
											$$ -> relShip = NULL;
										}
| '-''-'                                {	
											_emit("--");
											$$ = makeNode(RelationShipPattern);
											$$ -> reltype = 7;  
											$$ -> relShip = NULL;
										}
;

RelationshipDetail: 
 '[' Variable_Pattern RelationshipTypePattern IntegerLiteralPattern PropertiesPattern ']'    
										{	
											_emit("[RelationshipDetail]");
											$$ = makeNode(RelationShip);
											$$ -> hasbracket = true;

											if ($2 == NULL)
											{
												$$ -> hasPatternVal = false;
											}
											else
											{
												$$ -> hasPatternVal = true;
												if (strlen($2) < MAX_COLNAME_LENGTH)
													strncpy($$ -> patternVal,$2,strlen($2)+1);
												else
													ERROR("PatternVal is too long!");
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
											_emit("RelationshipTypePattern is NULL");
											$$ = NULL;
										}
| ':' RelTypeName RelTypeNamePattern    {	
											_emit(": RelTypeName RelTypeNamePattern");
											if ($3 == NULL)
											{
												$$ = (char *)malloc(strlen($2));
												sprintf(colNameRelType,"%s",$2);
											}
											else
											{
												$$ = (char *)malloc(strlen($2) + strlen($3));
												sprintf(colNameRelType,":%s %s",$2,$3);
											}
											if (strlen(colNameRelType) <= MAX_COLNAME_LENGTH)
												strncpy($$,colNameRelType,strlen(colNameRelType));
											else
												ERROR("colName is too long!");
											memset(colNameRelType,0,strlen(colNameRelType));
										}
;

RelTypeNamePattern:         
							{
								$$ = NULL;
							}
| '|' RelTypeName           
							{
								_emit("| RelTypeName");
								sprintf(colNameAttr,"|%s", $2);
								if (strlen(colNameAttr) <= MAX_COLNAME_LENGTH)
									strncpy($$,colNameAttr,strlen(colNameAttr));
								else
									ERROR("colName is too long!");
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
| '|' ':' RelTypeName       {	
								_emit("| : RelTypeName");
								sprintf(colNameAttr,"|:%s", $3);
								if (strlen(colNameAttr) <= MAX_COLNAME_LENGTH)
									strncpy($$,colNameAttr,strlen(colNameAttr));
								else
									ERROR("colName is too long!");
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
;

RelTypeName:ColName        {$$ = $1;}
;

IntegerLiteralPattern:                      {
												_emit("IntegerLiteralPattern is NULL");
												$$ = NULL;
											}
| '*' IntegerLiteralPatternPart IntegerLiteralColonPatternPart   
											{
												_emit("* IntegerLiteralPatternPart");
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
												_emit(".. IntegerLiteralPatternPart");
												sprintf(colNameAttr,"%s%s",$1,$2);
												$$ = malloc(strlen(colNameAttr) * sizeof(char));
												if (strlen(colNameAttr) <= MAX_COLNAME_LENGTH)
													strncpy($$,colNameAttr,strlen(colNameAttr));
												else
													ERROR("colName is too long!");
												memset(colNameAttr,0,strlen(colNameAttr));
											}
;

IntegerLiteralPatternPart:                	{$$ = NULL;}
| IntegerLiteral                            {
												_emit("IntegerLiteral");
												sprintf(colNameAttr,"%ld",$1);
												printf("-----%ld\n",$1);
												$$ = malloc(strlen(colNameAttr) * sizeof(char));
												if (strlen(colNameAttr) <= MAX_COLNAME_LENGTH)
													strncpy($$,colNameAttr,strlen(colNameAttr));
												else
													ERROR("colName is too long!");
												memset(colNameAttr,0,strlen(colNameAttr));
											}
;

IntegerLiteral:INTNUM                       {
												_emit("INTNUM %d",$1);
												$$ = $1;
											}
;


/* Where Clause */

WhereClause:   
				{  
					_emit("whereClause is null");
					$$ = NULL; 	
				} 
| WHERE WhereExpression 
				{
					_emit("return where");
					$$ = makeNode(WhereStmtClause);
					$$ -> root = $2;   		
				}
;

WhereExpression:Expression PartialComparisonExpression      
				{
					_emit("-----Into ComparisonExpression");
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
					_emit("OR");
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
					_emit("XOR");
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
					_emit("AND");
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
					_emit("NOT");
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

// ComparisonExpression:Expression PartialComparisonExpression    {_emit("ComparisonExpression");}
// ;

PartialComparisonExpression:            
							{
								$$ = NULL;
							}
| COMPARISON Expression     {
								_emit("COMPARISION %d",$1);
								$$ = makeNode(SubCompExpr);
								$$ -> partialType = 1;		// > >= ...
								$$ -> compType = $1;
								$$ -> subComprisionExpr = $2;
							}
| IN Expression             {
								_emit("IN");
								$$ = makeNode(SubCompExpr);
								$$ -> partialType = 0;		// IN ...
								$$ -> subComprisionExpr = $2;
							}
;

Expression:Literal                	{
										_emit("Expression:Literal");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'L';
										$$ -> ltrlType = $1;
										$$ -> funcOpts = NULL;
										$$ -> anyExpr = NULL;
										$$ -> inExpr = NULL;
										
									}
| ANY '(' FilterExpression ')'      {
										_emit("ANY");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'A';
										$$ -> funcOpts = NULL;
										$$ -> anyExpr = $3;
										$$ -> inExpr = NULL;
									}
| FuncOpt                           {	
										_emit("func");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'F';
										$$ -> funcOpts = $1;
										$$ -> anyExpr = NULL;
										$$ -> inExpr = NULL;
									}
// | '(' WhereExpression ')'          {_emit(" ( ) ");}
| INExpression                      {
										_emit("INExpression");
										$$ = makeNode(Comparision_Stru);
										$$ -> exprType = 'I';
										$$ -> funcOpts = NULL;
										$$ -> anyExpr = NULL;
										$$ -> inExpr = $1;   // in List
									}
;


FilterExpression:Literal IN WhereExpression WhereClause  
									{
										_emit("FilterExpression:IN");
										$$ = makeNode(AnyExpr);
										$$ -> ltrlType = $1;
										$$ -> whExpr = $3;
										$$ -> whcls = $4;
									}
;

Literal:IntParam                {
									_emit("Literal");
									$$ = makeNode(LiteralType);
									$$->etype = 'I';		// Intparam;
									$$->ltype.intParam = $1;
								}
| StringParam                   {
									_emit("StringList");
									$$ = makeNode(LiteralType);
									$$->etype = 'S';		// StringParm
									if (strlen($1) <= MAX_COLNAME_LENGTH)
										strncpy($$->ltype.strParam, $1, strlen($1));
									else
										ERROR("colName is too long!");
								}
| BOOL                          {
									_emit("BOOL:%d",$1);
									$$ = makeNode(LiteralType);
									$$->etype = 'B';		// BOOL
									$$->ltype.boolValue = $1;
								}
| NULLX                         {
									$$ = makeNode(LiteralType);
									$$->etype = 'N';		// NULLX
									strncpy($$->ltype.ifNull,$1,4);
								}
| ApproxnumParam                {
									_emit("ApproxnumList");
									$$ = makeNode(LiteralType);
									$$->etype = 'A';		// ApproxNumParam;
									$$->ltype.approxNumParam = $1;
								}
| ColName                       {
									_emit("ColName");
									$$ = makeNode(LiteralType);
									$$->etype = 'C';		// ColName
									if (strlen($1) <= MAX_COLNAME_LENGTH)
										strncpy($$->ltype.strParam, $1, strlen($1));
									else
										ERROR("colName is too long!");								
								}
;

FuncOpt:NAME '(' ColName ')'         /* min(a.id) or func(a.id) */         
							{
								_emit("%s(",$1);_emit(")");
								sprintf(colNameAttr,"%s(%s)",$1, $3);
								$$ = (char *)malloc(strlen(colNameAttr) * sizeof(char));
								if (strlen(colNameAttr) <= MAX_COLNAME_LENGTH)
									strncpy($$, colNameAttr, strlen(colNameAttr));
								else
									ERROR("colName is too long!");
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
| EXISTS '(' ColName ')'    {	/* exists(a.id) */ 
								_emit("EXISTS");
								sprintf(colNameAttr,"EXISTS(%s)",$3);
								$$ = (char *)malloc(strlen(colNameAttr) * sizeof(char));
								if (strlen(colNameAttr) <= MAX_COLNAME_LENGTH)
									strncpy($$, colNameAttr, strlen(colNameAttr));
								else
									ERROR("colName is too long!");
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							} 
| COUNT '(' DistinctOpt ColName ')'    /* count(a.id) */     	
							{
								_emit("COUNT");
								if ($3 == 1)
									sprintf(colNameAttr,"COUNT(DISTINCT %s)",$4);
								else
									sprintf(colNameAttr,"COUNT(%s)",$4);
								$$ = (char *)malloc(strlen(colNameAttr) * sizeof(char));
								if (strlen(colNameAttr) <= MAX_COLNAME_LENGTH)
									strncpy($$, colNameAttr, strlen(colNameAttr));
								else	
									ERROR("colName is too long!");
								memset(colNameAttr,0,MAX_COLNAME_LENGTH);
							}
;

INExpression:                   {$$ = NULL;}
| '[' StringList ']'            {_emit("StringList");$$ = $2;}
| '[' IntList ']'               {_emit("IntList");$$ = $2;}
| '[' ApproxnumList ']'         {_emit("ApproxnumList");$$ = $2;}
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
										intstrapp->union_type = 'S';
										$$ = (Node *)intstrapp;
										
									}
;

IntParamNode:INTNUM                 {
										IntStringAppro *intstrapp = makeNode(IntStringAppro);
										intstrapp->isa.intValue = (int64_t) $1;
										intstrapp->union_type = 'I';
										$$ = (Node *)intstrapp;
									}
;

ApproxnumParamNode:APPROXNUM        {
										IntStringAppro *intstrapp = makeNode(IntStringAppro);
										intstrapp->isa.approValue = $1;
										intstrapp->union_type = 'A';
										$$ = (Node *)intstrapp;
									}
;

StringList:StringParamNode          {
										_emit("StringParam");
										$$ = list_make1($1);
									}
| StringList ',' StringParamNode    {
										_emit("StringList , ");
										$$ = lappend($1,$3);
									}
;

IntList:IntParamNode                {
										_emit("IntParam");
										$$ = list_make1($1);
									}
| IntList ',' IntParamNode          {
										_emit("IntList ,");
										$$ = lappend($1,$3);
									}
;

ApproxnumList:ApproxnumParamNode        {
											_emit("ApproxnumParam");
											$$ = list_make1($1);
										}
| ApproxnumList ',' ApproxnumParamNode  {
											_emit("ApproxnumList ,");
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

					if (($$->limitNum = $5,$5<=0))	/* limit num*/
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
								// _emit("%s",$1);
								if (strlen($1) <= MAX_COLNAME_LENGTH)
									strncpy(cols->colname,$1,MAX_COLNAME_LENGTH);
								else
									ERROR("colName is too long!");
								if($2 != NULL)
								{
									if (strlen($2) <= MAX_COLNAME_LENGTH)
										strncpy(cols->colAlias,$2,MAX_COLNAME_LENGTH);
									else
										ERROR("colName is too long!");
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
									if (strlen($5) <= MAX_COLNAME_LENGTH)
										strncpy(cols->colAlias,$5,MAX_COLNAME_LENGTH);
									else
										ERROR("colName is too long!");
									cols->hasAlias = 1;
								} else
									cols->hasAlias = 0;
								if (strlen($1) <= MAX_COLNAME_LENGTH)
									strncpy(cols->funName,$1,MAX_COLNAME_LENGTH);
								else
									ERROR("colName is too long!");

								if (strlen($3) <= MAX_COLNAME_LENGTH)
									strncpy(cols->colname,$3,MAX_COLNAME_LENGTH);
								else
									ERROR("colName is too long!");
								$$ = (Node *)cols;
							}
| COUNT '(' DistinctOpt ColName ')' OptAsAlias
							{
								ReturnCols *cols = makeNode(ReturnCols);
			
								if($6 != NULL)
								{
									if (strlen($6) <= MAX_COLNAME_LENGTH)
										strncpy(cols->colAlias,$6,MAX_COLNAME_LENGTH);
									else
										ERROR("colName is too long!");
									cols->hasAlias = 1;
								} else
									cols->hasAlias = 0;

								strcpy(cols->funName,"COUNT"); // ?????
								cols->hasFunc = 1;
								cols->hasDistinct = $3;
								if (strlen($4) <= MAX_COLNAME_LENGTH)
									strncpy(cols->colname,$4,MAX_COLNAME_LENGTH);
								else
									ERROR("colName is too long!");
								$$ = (Node *)cols;
							}
| NumberLiteral OptAsAlias          
							{
								ReturnCols *cols = makeNode(ReturnCols);
								
								cols->hasFunc = 0;
								cols->hasDistinct = 0;
								if (strlen($1) <= MAX_COLNAME_LENGTH)
									strncpy(cols->colname,$1,MAX_COLNAME_LENGTH);
								else
									ERROR("colName is too long!");

								if($2 != NULL) 
								{
									if (strlen($2) <= MAX_COLNAME_LENGTH)
										strncpy(cols->colAlias,$2,MAX_COLNAME_LENGTH);
									else
										ERROR("colName is too long!");
									cols->hasAlias = 1;
								} else
									cols->hasAlias = 0;
								$$ = (Node *)cols;
							}
; /* [ ... as b] OR  [...]*/

OptAsAlias: /* no AS Alias*/ 	{$$ = NULL;}
| AS NAME       				{$$ = $2;}
;

OrderByClause: /* no orderby*/ 		{ $$ = NULL; }
| ORDER BY ColName AscDescOpt    
					{
						$$ = makeNode(OrderByStmtClause);
						$$->ascDesc = $4;
						if (strlen($3) <= MAX_COLNAME_LENGTH)
							strncpy($$->orderByColname, $3 ,MAX_COLNAME_LENGTH); 	
						else
							ERROR("colName of Ordder is too long!");					
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

NumberLiteral:INTNUM        { sprintf(attrNum,"%d",$1); $$ = attrNum; }
| APPROXNUM                 { sprintf(attrNum,"%f",$1); $$ = attrNum; }
;

ColName:NAME 
				{
					// _emit("ColName");
					$$ = $1;
				}
| NAME '.' NAME  
				{
					// _emit("ColName");
					if (strlen($1) + strlen($3) <= MAX_COLNAME_LENGTH)
						sprintf(colNameAttr,"%s.%s",$1,$3);
					else
						ERROR("ColName too long!");
					strncpy($$,colNameAttr,MAX_COLNAME_LENGTH); 
					// $$ = colNameAttr;
					memset(colNameAttr,0,MAX_COLNAME_LENGTH);
				}
;


%%

void yyerror (yyscan_t *locp, module *mod, char const *msg) 
{
	fprintf(stderr, "--> %s\n", msg);
}

