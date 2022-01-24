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


%token MATCH
%token EOL
%token RETURN
%token DESC
%token ASC
%token DISTINCT
%token ORDER
%token BY
%token LIMIT
%token AS
%token IS
%token ALL
%token MERGE
%token ON
%token WHERE
%token WITH
%token UNIONS
%token AND
%token ENDS
%token IN
%token NOT
%token OR
%token XOR
%token NULLX
%token COUNT
%token EXISTS
%token ANY
%token CONTAINS



// %type <a> exp factor term
%type <strval> col_name opt_as_alias limit_clause asc_desc_opt order_by_clause distinct_opt
%type <strval> return_expr return_expr_list func_opt  

%type <strval> where_clause where_expression ComparisonExpression
%type <strval> Expression PartialComparisonExpression Literal FilterExpression INExpression
%type <strval> NumberLiteral StringList IntList ApproxnumList StringParam IntParam ApproxnumParam
%type <strval> match_clause Pattern Pattern_Part AnonymousPatternPart PatternElement
%type <strval> NodePattern PatternElementChain_clause PatternElementChain IntegerLiteral_Pattern
%type <strval> RelationshipPattern Variable_Pattern NodeLabels_Pattern Properties_Pattern NodeLabels NodeLabel RelationshipType_Pattern
%type <strval> MapLiteral MapLiteral_clause MapLiteral_Pattern MapLiteral_Pattern_Part property_key RelationshipDetail
%type <strval> RelTypeName RelTypeName_Pattern IntegerLiteral_Pattern_Part IntegerLiteralColon_Pattern_Part

%start Cypher

%%

Cypher: match_clause where_clause return_clause EOL     {emit("Cypher");}
/* Match Clause */

match_clause: MATCH Pattern        {emit("match_clause");}
;

Pattern:Pattern_Part                            {emit("Pattern");}
| Pattern ',' Pattern_Part                      {emit("Patterns:  ,  ");}
;

Pattern_Part:AnonymousPatternPart               {emit("Pattern_part");}
| col_name COMPARISON AnonymousPatternPart      {emit("pattern_part  %d ",$2);}
;

AnonymousPatternPart:PatternElement             {emit("AnonymousPatternPart");}
;

PatternElement:'(' PatternElement ')'           {emit("( PatternElement )");}
| NAME '(' PatternElement ')'                   {emit("Function Name ( )");}
| NodePattern PatternElementChain_clause        {emit("NodePattern : ");}
;

PatternElementChain_clause:                     {emit("");}
| PatternElementChains                           {emit("PatternElementChain");}
;

PatternElementChains:PatternElementChain        {emit("PatternElementChain");}
| PatternElementChains PatternElementChain      {emit("PatternElementChain PatternElementChain ...");}
;

PatternElementChain:RelationshipPattern NodePattern     {emit("PatternElementChain");}
;

NodePattern:'(' Variable_Pattern NodeLabels_Pattern Properties_Pattern ')'  {emit("NodePattern");}
;

Variable_Pattern:               {emit("Variable is NULL");}
| col_name                      {emit("Variable:col_name");}
;

NodeLabels_Pattern:             {emit("NodeLabels_Pattern");}
| NodeLabel NodeLabels          {emit("NodeLabel : ");}
;

NodeLabels:                     {emit("NodeLabels");}
| NodeLabel                     {emit("NodeLabel");}
;

NodeLabel: ':' col_name         {emit("NodeLabel : col_name");}
;

Properties_Pattern:             {emit("Properties_Pattern is NULL");}
| MapLiteral                    {emit("MapLiteral");}
;

MapLiteral:'{' MapLiteral_clause '}'                        {emit("{MapLiteral_clause}");}
;

MapLiteral_clause:                                          {emit("MapLiteral_clause");}
| MapLiteral_Pattern                                        {emit("MapLiteral_Pattern");}
;

MapLiteral_Pattern:MapLiteral_Pattern_Part                  {emit("MapLiteral_Pattern_Part");}
| MapLiteral_Pattern ',' MapLiteral_Pattern_Part            {emit("MapLiteral_Pattern_Part , MapLiteral_Pattern_Part");}
;

MapLiteral_Pattern_Part:property_key ':' where_expression         {emit("property_key : Expression");}
;

property_key:col_name           {emit("property_key:col_name");}
;

RelationshipPattern:LEFTARROW RelationshipDetail RIGHTARROW  {emit("<-   ->");}
| LEFTARROW RelationshipDetail '-'                        {emit("<-   -");}
| '-' RelationshipDetail RIGHTARROW                        {emit("-    ->");}
| '-' RelationshipDetail '-'                            {emit("-    -");}
| '-' RIGHTARROW                                        {emit("-->");}
| LEFTARROW '-'                                         {emit("<--");}
| '-''-'                                                {emit("--");}
;

RelationshipDetail: Variable_Pattern RelationshipType_Pattern IntegerLiteral_Pattern Properties_Pattern      {emit("RelationshipDetail");}
'[' Variable_Pattern RelationshipType_Pattern IntegerLiteral_Pattern Properties_Pattern ']'    {emit("[RelationshipDetail]");}
;

RelationshipType_Pattern:               {emit("RelationshipType_Pattern is NULL");}
| ':' RelTypeName RelTypeName_Pattern   {emit(": RelTypeName RelTypeName_Pattern");}
;

RelTypeName_Pattern:        {}
| '|' RelTypeName           {emit("| RelTypeName");}
| '|' ':' RelTypeName       {emit("| : RelTypeName");}
;

RelTypeName:col_name        {emit("RelTypeName:col_name");}
;

IntegerLiteral_Pattern:                                              {emit("IntegerLiteral_Pattern is NULL");}
| '*' IntegerLiteral_Pattern_Part IntegerLiteralColon_Pattern_Part   {emit("* IntegerLiteral_Pattern_Part");}
;

IntegerLiteralColon_Pattern_Part:           {}
| PPOINT IntegerLiteral_Pattern_Part        {emit(".. IntegerLiteral_Pattern_Part");}
;

IntegerLiteral_Pattern_Part:                {}
| IntegerLiteral                            {emit("IntegerLiteral");}
;

IntegerLiteral:INTNUM                       {emit("INTNUM %d",$1);}
;


/* Where Clause */

where_clause:   {emit("where_clause");}
| WHERE where_expression {emit("WHERE where_expression");}
;

where_expression:ComparisonExpression      {emit("where_expression");}
| where_expression OR where_expression    {emit("OR");}
| where_expression XOR where_expression   {emit("XOR");}
| where_expression AND where_expression   {emit("AND");}
| NOT where_expression          {emit("NOT");}
;

ComparisonExpression:Expression PartialComparisonExpression    {emit("ComparisonExpression");}
;

PartialComparisonExpression:            {emit("PartialComparisonExpression");}
| COMPARISON Expression    /* >= */    {emit("%d",$1);}
| IN Expression                         {emit("IN");}
;

Expression:Literal                  {emit("Expression:Literal");}
| ANY '(' FilterExpression ')'      {emit("ANY");}
| func_opt                          {emit("func");}
| '(' where_expression ')'          {emit(" ( ) ");}
| INExpression                      {emit("INExpression");}
;

FilterExpression:Literal IN where_expression where_clause  {emit("FilterExpression:IN");}
;

Literal:IntParam                 {emit("Literal");}
| StringParam                    {emit("StringList");}
| BOOL                          {emit("BOOL:%d",$1);}
| NULLX                         {emit("NULL");}
| ApproxnumParam                 {emit("ApproxnumList");}
| col_name                      {emit("col_name");}
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

return_clause: RETURN distinct_opt return_expr_list order_by_clause limit_clause {emit("RETURN ");}

return_expr_list:return_expr /* [name] OR [a,b,c] */    {emit("return_expr");}
| return_expr_list ',' return_expr   {emit(" , ");}
;

return_expr:col_name opt_as_alias {emit("return_expr:col");}
| func_opt opt_as_alias             {emit("return_expr:func");}
| NumberLiteral opt_as_alias          {emit("return_expr:digital");}
; /* [ ... as b] OR  [...]*/

opt_as_alias: /* no AS Alias*/ {}
| AS NAME       {emit("AS %s",$2); free($2);}
;

count_func_opt:COUNT '(' distinct_opt col_name ')'    /* count(a.id) */      {emit("COUNT");} 
;

func_opt:NAME '(' col_name ')'         /* min(a.id) or func(a.id) */         {emit("%s(",$1);emit(")");}
| exists_opt                        {emit("exists_opt");}
| count_func_opt                    {emit("count_func_opt");}
;

exists_opt:EXISTS '(' col_name ')'   /* exists(a.id) */   {emit("EXISTS");}
;


order_by_clause: /* no orderby*/ {}
| ORDER BY col_name asc_desc_opt    {emit("ORDER BY ");}
;

distinct_opt:   {emit("no DISTINCT");}       
| DISTINCT      {emit("DISTINCT");}
;

asc_desc_opt:/* no ASC DESC */ {}
| ASC       {emit("ASC ");}
| DESC      {emit("DESC ");}
;

limit_clause:/* no limit */ {}
| LIMIT INTNUM  {emit("LIMIT %d\n",$2); }
;

col_name:NAME {emit("%s ",$1);free($1);}
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
