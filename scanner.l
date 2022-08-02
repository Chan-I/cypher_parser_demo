%{
#include "parser.h"
int oldstate;
%}

%option bison-bridge
%option case-insensitive
%option noinput
%option nounput
%option noyywrap
%option reentrant
%option yylineno

%x COMMENT
%s BTWMODE

%%

ALL         { return ALL;        }
AND         { return AND;        }
ANY         { return ANY;        }
AS          { return AS;         }
ASC         { return ASC;        }
BY          { return BY;         }
CALL        { return CALL;       }
CONTAINS    { return CONTAINS;   }
COUNT       { return COUNT;      }
CREATE      { return CREATE;     }
DELETE      { return DELETE;     }
DESC        { return DESC;       }
DISTINCT    { return DISTINCT;   } 
ENDS        { return ENDS;       }
EXISTS      { return EXISTS;     }
IN          { return IN;         }
IS          { return IS;         }
LIMIT       { return LIMIT;      }
MATCH       { return MATCH;      }
MERGE       { return MERGE;      }
NOT         { return NOT;        }
NULL        { return NULLX;      }
ON          { return ON;         }
OR          { return OR;         }
ORDER       { return ORDER;      }
REMOVE      { return REMOVE;     }
RETURN      { return RETURN;     }
SET         { return SET;        }
UNION       { return UNION;      }
WHERE       { return WHERE;      }
WITH        { return WITH;       }
XOR         { return XOR;        }
YIELD       { return YIELD;      }
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
"+="    {yylval->strval = strdup(yytext); return PLUSEQUL;}

[-+*/%(){}.:;,\[\]<>]  { return  yytext[0]; }

".."    { yylval->strval = strdup(yytext); return PPOINT; }

[ \t\r\f\n]       ;

    /* comments */
"#"[^\n\t\f\r]*	;
"//".*	        ;
"/*"            {oldstate = YY_START; BEGIN COMMENT;}
<COMMENT>"*/"   {BEGIN oldstate;}
<COMMENT>.|\n   ;

