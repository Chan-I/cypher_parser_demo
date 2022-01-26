%{
#include<stdlib.h>
#include<stdio.h>
#include<stdarg.h>
#include<string.h>
#include"test.h"

void emit(char *s, ...);
%}


%union {
    int intval;
    double floatval;
    char *strval;
    int subtok;
	
	struct ast *a;


	const char* keyword;
}

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

%token <keyword> 
	ALL AND ANY AS ASC 
	BY 
	CONTAINS COUNT 
	DESC DISTINCT 
	ENDS EOL EXISTS 
	IN IS 
	LIMIT 
	MATCH MERGE 
	NOT NULLX 
	ON OR ORDER 
	RETURN 
	UNIONS 
	WHERE WITH 
	XOR 



// %type <a> exp factor term
%type <strval> AnonymousPatternPart ApproxnumList ApproxnumParam AscDescOpt
%type <strval> ColName ComparisonExpression Cypher CypherClause
%type <strval> DistinctOpt
%type <strval> Expression
%type <strval> FilterExpression FuncOpt
%type <strval> INExpression IntList IntParam IntegerLiteralColonPatternPart IntegerLiteralPattern IntegerLiteralPatternPart
%type <strval> LimitClause Literal
%type <strval> MapLiteral MapLiteralClause MapLiteralPattern MapLiteralPatternPart MatchClause
%type <strval> NodeLabel NodeLabels NodeLabelsPattern NodePattern NumberLiteral
%type <strval> OptAsAlias OrderByClause
%type <strval> PartialComparisonExpression Pattern PatternElement PatternElementChain PatternElementChainClause PatternPart PropertiesPattern PropertyKey 
%type <strval> RelTypeName RelTypeNamePattern RelationshipDetail RelationshipPattern RelationshipTypePattern ReturnExpr ReturnExprList
%type <strval> StringList StringParam
%type <strval> Variable_Pattern
%type <strval> WhereClause WhereExpression

%start Cypher

%%
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

NumberLiteral:INTNUM        {emit("%d",$1);}
| APPROXNUM                 {emit("%f",$1);}
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



/* Return Clause */

ReturnClause: RETURN DistinctOpt ReturnExprList OrderByClause LimitClause {emit("RETURN ");}

ReturnExprList:ReturnExpr /* [name] OR [a,b,c] */    {emit("ReturnExpr");}
| ReturnExprList ',' ReturnExpr   {emit(" , ");}
;

ReturnExpr:ColName OptAsAlias {emit("ReturnExpr:col");}
| FuncOpt OptAsAlias             {emit("ReturnExpr:func");}
| NumberLiteral OptAsAlias          {emit("ReturnExpr:digital");}
; /* [ ... as b] OR  [...]*/

OptAsAlias: /* no AS Alias*/ {}
| AS NAME       {emit("AS %s",$2); free($2);}
;

CountFuncOpt:COUNT '(' DistinctOpt ColName ')'    /* count(a.id) */      {emit("COUNT");} 
;

FuncOpt:NAME '(' ColName ')'         /* min(a.id) or func(a.id) */         {emit("%s(",$1);emit(")");}
| ExistsOpt                        {emit("ExistsOpt");}
| CountFuncOpt                    {emit("CountFuncOpt");}
;

ExistsOpt:EXISTS '(' ColName ')'   /* exists(a.id) */   {emit("EXISTS");}
;


OrderByClause: /* no orderby*/ {}
| ORDER BY ColName AscDescOpt    {emit("ORDER BY ");}
;

DistinctOpt:   {emit("no DISTINCT");}       
| DISTINCT      {emit("DISTINCT");}
;

AscDescOpt:/* no ASC DESC */ {}
| ASC       {emit("ASC ");}
| DESC      {emit("DESC ");}
;

LimitClause:/* no limit */ {}
| LIMIT INTNUM  {emit("LIMIT %d\n",$2); }
;

ColName:NAME {emit("%s ",$1);free($1);}
| NAME '.' NAME  {emit("%s.%s ",$1,$3); free($1); free($3);}
;





/*
calclist: 
| calclist exp EOL {
     printf("= %4.4g\n", eval($2));
     treefree($2);
     printf("> ");
 }

 | calclist EOL	{ printf("> "); } 
 ;

exp: factor
 | exp '+' factor { $$ = newast('+', $1,$3);}
 | exp '-' factor { $$ = newast('-', $1,$3);}
 ;

factor: term
 | factor '*' term { $$ = newast('*', $1,$3); }
 | factor '/' term { $$ = newast('/', $1,$3); }
 ;

term: APPROXNUM	{ $$ = newappnum($1); }
 | INTNUM {$$ = newintnum($1); }
 | '(' exp ')' { $$ = $2; }
 | '-' term    { $$ = newast('M', $2, NULL); }
 ;

*/



%%
