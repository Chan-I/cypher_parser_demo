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
%token <floatval> APPROXNUM
%token <strval> NAME

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



%type <a> exp factor term
%type <strval> col_name opt_as_alias return_col limit_clause asc_desc_opt order_by_clause
%type <strval> return_expr return_expr_list  return_opts Cypher

%start return_clause

%%

/* 
Match:MATCH match_opts match_expr_list RETURN return_opts return_expr_list
| MATCH match_opts match_expr_list RETURN return_opts return_expr_list order_by_clause limit_clause
;

match_opts:

match_expr_list:

*/

return_clause: RETURN return_opts return_expr_list EOL {emit("RETURN ");}
| RETURN return_opts return_expr_list order_by_clause limit_clause EOL {emit("RETURN ");}

return_opts:     /* Distinct or no*/
| return_opts DISTINCT  {emit("DISTINCT");}
;

return_expr_list:return_expr /* [name] OR [a,b,c] */    {emit("return_expr");}
|return_expr_list ',' return_expr   {emit(" , ");}
;

return_expr:return_col opt_as_alias {}
; /* [ ... as b] OR  [...]*/

opt_as_alias: /* no AS Alias*/
| AS NAME       {emit("AS %s",$2); free($2);}
;

return_col:col_name             /* a.id */  {}
| NAME '(' col_name ')'          /* count(a.id) min(a.id) */ {emit("%s(",$1);emit(")");}
| NAME '(' DISTINCT col_name ')' /* count(distinct a.id) */  {emit("%s(DISTINCT",$1);emit(")");}
; 

order_by_clause: /* no orderby*/
| ORDER BY col_name asc_desc_opt    {emit("ORDER BY ");}
;

asc_desc_opt:/* no ASC DESC */
| ASC       {emit("ASC ");}
| DESC      {emit("DESC ");}
;

limit_clause:/* no limit */
| LIMIT INTNUM  {emit("LIMIT %d\n",$2); }
;

col_name:NAME {emit("%s ",$1);free($1);}
| NAME '.' NAME  {emit("%s.%s ",$1,$3); free($1); free($3);}
;







calclist: /* nothing */
| calclist exp EOL {
     printf("= %4.4g\n", eval($2));
     treefree($2);
     printf("> ");
 }

 | calclist EOL	{ printf("> "); } /* blank line or a comment */
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





%%
