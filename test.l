%option noyywrap yylineno case-insensitive nodefault

%{
#include "test.tab.h"
#include <stdarg.h>
#include <string.h>

void yyerror(const char *s, ...);
int oldstate;
%}

%x COMMENT
%s BTWMODE

%%





   /* numbers */ 
[0-9]*	{yylval.intval = atoi(yytext); return INTNUM; }
[0-9]+"."[0-9]+([Ee][-+]?[0-9]+)?	|
"."[0-9]+([Ee][-+]?[0-9]+)?	{ yylval.floatval = atof(yytext) ;return APPROXNUM; }


[-+*/%\^(){}.:;,\[\]]  { return  yytext[0]; }




    /* comments */

    /* everything else */
[ \t]   ;
\n              { return EOL; }
.               { yyerror("mystery character '%c'", *yytext); }

%%
