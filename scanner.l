%{
#include "parser.h"
int oldstate;
%}

%option reentrant
%option yylineno

%option noyywrap

%option case-insensitive
%option bison-bridge

%x COMMENT
%s BTWMODE

%%

AS          { return AS;         }
ANY         { return ANY;        }
ALL         { return ALL;        }
MATCH       { return MATCH;      }
RETURN      { return RETURN;     }
DESC        { return DESC;       }
ASC         { return ASC;        }
DISTINCT    { return DISTINCT;   } 
ORDER       { return ORDER;      }
BY          { return BY;         }
LIMIT       { return LIMIT;      }
MERGE       { return MERGE;      }
ON          { return ON;         }
WHERE       { return WHERE;      }
WITH        { return WITH;       }
UNIONS      { return UNIONS;     }
AND         { return AND;        }
ENDS        { return ENDS;       }
IN          { return IN;         }
IS          { return IS;         }
NOT         { return NOT;        }
OR          { return OR;         }
XOR         { return XOR;        }
NULL        { return NULLX;      }
COUNT       { return COUNT;      }
EXISTS      { return EXISTS;     }
CONTAINS    { return CONTAINS;   }
TRUE    { yylval->intval = 1; return BOOL; }
FALSE   { yylval->intval = 0; return BOOL; }


[A-Za-z][A-Za-z0-9_]*	{ yylval->strval = strdup(yytext); return NAME; }

   /* numbers */ 
[0-9]*	{yylval->intval = atoi(yytext); return INTNUM; }
[0-9]+"."[0-9]+([Ee][-+]?[0-9]+)?	|
"."[0-9]+([Ee][-+]?[0-9]+)?	{ yylval->floatval = atof(yytext) ;return APPROXNUM; }



 /* string*/
'(\\.|''|[^'\n])*'  |
\"(\\.|\"\"|[^"\n])*\"  { yylval->strval = strdup(yytext); return STRING; }


"="     { yylval->subtok = 4; return COMPARISON; }
">="    { yylval->subtok = 6; return COMPARISON; }
">"     { yylval->subtok = 2; return COMPARISON; }
"<="    { yylval->subtok = 5; return COMPARISON; }
"<"     { yylval->subtok = 1; return COMPARISON; }
"<>"    { yylval->subtok = 3; return COMPARISON; }

"->"    {yylval->strval = strdup(yytext); return RIGHTARROW;}
"<-"    {yylval->strval = strdup(yytext); return LEFTARROW;}


[-+*/%(){}.:;,\[\]<>]  { return  yytext[0]; }

".."    { yylval->strval = strdup(yytext); return PPOINT; }

[ \t\r\f]   ;
\n              { return EOL; }

    /* comments */
#.*		        ;
"//".*	        ;
"/*"            {oldstate = YY_START; BEGIN COMMENT;}
<COMMENT>"*/"   {BEGIN oldstate;}
<COMMENT>.|\n   ;

