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

%type <strval> where_clause where_expression XORExpression ANDExpression NOTExpression ComparisonExpression
%type <strval> Expression PartialComparisonExpression Literal FilterExpression INExpression
%type <strval> NumberLiteral StringList IntList ApproxnumList
%type <strval> Cypher

%start Cypher

%%

Cypher:where_clause return_clause {emit("Cypher");}
;

where_clause:   {emit("where_clause");}
| WHERE where_expression {emit("WHERE ");}
;

where_expression:XORExpression      {emit("where_expression");}
| XORExpression OR XORExpression    {emit("OR");}
;

XORExpression:ANDExpression         {emit("XORExpression");}
| ANDExpression XOR ANDExpression   {emit("XOR");}
;

ANDExpression:NOTExpression         {emit("ANDExpression");}
| NOTExpression AND NOTExpression   {emit("AND");}
;

NOTExpression:ComparisonExpression      {emit("NOTExpression");}
| NOT ComparisonExpression          {emit("NOT");}
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

FilterExpression:Literal IN where_expression where_clause  {emit("FilterExpression");}
;

Literal:IntList                 {emit("Literal");}
| StringList                    {emit("StringList");}
| BOOL                          {emit("BOOL:%d",$1);}
| NULLX                         {emit("NULL");}
| ApproxnumList                 {emit("ApproxnumList");}
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


StringList:STRING               {emit("%s",$1);free($1);}
| StringList ',' STRING         {emit("StringList");}
;

IntList:INTNUM                  {emit("%d",$1);}
| IntList ',' INTNUM            {emit("IntList");}
;

ApproxnumList:APPROXNUM         {emit("%f",$1);}
| ApproxnumList ',' APPROXNUM   {emit("ApproxnumList");}
;





return_clause: RETURN distinct_opt return_expr_list order_by_clause limit_clause EOL {emit("RETURN ");}

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
