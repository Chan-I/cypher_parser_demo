%{
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "test.h"

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

%token EOL


%type <a> exp factor term

%start calclist

%%

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