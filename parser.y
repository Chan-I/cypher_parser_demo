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
    double floatval;
    char *strval;
    int subtok;

	Node	*node;
	List 	*list;
	OrderByStmtClause *odb;
	ReturnCols	*rtcols;
	ReturnStmtClause	*rtstmtcls;	
	
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
%type <list> ReturnExprList
%type <node> ReturnExpr 
%type <intval> LimitClause AscDescOpt DistinctOpt
%type <odb> OrderByClause

%type <strval> AnonymousPatternPart ApproxnumList ApproxnumParam 
%type <strval> ColName ComparisonExpression Cypher CypherClause


%type <strval> Expression
%type <strval> FilterExpression FuncOpt
%type <strval> INExpression IntList IntParam IntegerLiteralColonPatternPart IntegerLiteralPattern IntegerLiteralPatternPart
%type <strval>  Literal
%type <strval> MapLiteral MapLiteralClause MapLiteralPattern MapLiteralPatternPart MatchClause
%type <strval> NodeLabel NodeLabels NodeLabelsPattern NodePattern NumberLiteral
%type <strval> OptAsAlias 
%type <strval> PartialComparisonExpression Pattern PatternElement PatternElementChain PatternElementChainClause PatternPart PropertiesPattern PropertyKey 
%type <strval> RelTypeName RelTypeNamePattern RelationshipDetail RelationshipPattern RelationshipTypePattern 
%type <strval> StringList StringParam
%type <strval> Variable_Pattern
%type <strval> WhereClause WhereExpression



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

WhereClause:   {emit("WhereClause");}
| WHERE WhereExpression {emit("WHERE WhereExpression");}
;

WhereExpression:ComparisonExpression      {emit("WhereExpression");}
| WhereExpression OR WhereExpression    {emit("OR");}
| WhereExpression XOR WhereExpression   {emit("XOR");}
| WhereExpression AND WhereExpression   {emit("AND");}
| NOT WhereExpression          {emit("NOT");}
;

ComparisonExpression:Expression PartialComparisonExpression    {emit("ComparisonExpression");}
;

PartialComparisonExpression:            {emit("PartialComparisonExpression");}
| COMPARISON Expression    /* >= */    {emit("%d",$1);}
| IN Expression                         {emit("IN");}
;

Expression:Literal                  {emit("Expression:Literal");}
| ANY '(' FilterExpression ')'      {emit("ANY");}
| FuncOpt                          {emit("func");}
| '(' WhereExpression ')'          {emit(" ( ) ");}
| INExpression                      {emit("INExpression");}
;

FilterExpression:Literal IN WhereExpression WhereClause  {emit("FilterExpression:IN");}
;

Literal:IntParam                 {emit("Literal");}
| StringParam                    {emit("StringList");}
| BOOL                          {emit("BOOL:%d",$1);}
| NULLX                         {emit("NULL");}
| ApproxnumParam                 {emit("ApproxnumList");}
| ColName                      {emit("ColName");}
;

INExpression:                   {emit("no INExpression");}
| '[' StringList ']'            {emit("StringList");}
| '[' IntList ']'               {emit("IntList");}
| '[' ApproxnumList ']'         {emit("ApproxnumList");}
;

StringParam:STRING              {emit("%s",$1);free($1);}
;

IntParam:INTNUM                 {emit("%d",$1);}
;

ApproxnumParam:APPROXNUM        {emit("%f",$1);}
;

StringList:StringParam               {emit("StringParam");}
| StringList ',' StringParam         {emit("StringList , ");}
;

IntList:IntParam                  {emit("IntParam");}
| IntList ',' IntParam            {emit("IntList ,");}
;

ApproxnumList:ApproxnumParam         {emit("ApproxnumParam");}
| ApproxnumList ',' ApproxnumParam   {emit("ApproxnumList ,");}
;


sexps:
	ReturnClause	{mod->rt = $1;}

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

CountFuncOpt:COUNT '(' DistinctOpt ColName ')'    /* count(a.id) */      {emit("COUNT");} 
;

FuncOpt:NAME '(' ColName ')'         /* min(a.id) or func(a.id) */         {emit("%s(",$1);emit(")");}
| ExistsOpt                        {emit("ExistsOpt");}
| CountFuncOpt                    {emit("CountFuncOpt");}
;

ExistsOpt:EXISTS '(' ColName ')'   /* exists(a.id) */   {emit("EXISTS");}
;


OrderByClause: /* no orderby*/ {$$ = NULL;}
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
					colNameAttr[0] = 0;
				}
;


%%

void yyerror (yyscan_t *locp, module *mod, char const *msg) {
	fprintf(stderr, "--> %s\n", msg);
}

