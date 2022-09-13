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
%option prefix="module_yy"
%option extra-type="core_yy_extra"

%x COMMENT
%s BTWMODE

%{

#define update_location() \
    do \
    { \
        yyextra.last_loc = yytext - yyextra.scan_buf; \
        yyextra.end_loc = yyextra.last_loc + strlen(yytext) - 1; \
    } while (0)
#define get_location() (yyextra.last_loc)

static void yyextra_init(core_yy_extra *extra, char *buf);
#define scan_errmsg(msg) _scan_errmsg(msg, &yyextra)
static int _scan_errmsg(const char *msg, const core_yy_extra *extra);
#define scan_errposition() _scan_errposition(yyextra.last_loc, &yyextra)
static int _scan_errposition(const int location, const core_yy_extra *extra);
extern int module_scanner_errmsg(const char *msg, core_yyscan_t *scanner);
extern int module_scanner_errposition(const int location, core_yyscan_t *scanner);

%}

%%

ALL         { update_location(); return ALL;        }
AND         { update_location(); return AND;        }
ANY         { update_location(); return ANY;        }
AS          { update_location(); return AS;         }
ASC         { update_location(); return ASC;        }
BY          { update_location(); return BY;         }
CALL        { update_location(); return CALL;       }
CONTAINS    { update_location(); return CONTAINS;   }
COUNT       { update_location(); return COUNT;      }
CREATE      { update_location(); return CREATE;     }
DELETE      { update_location(); return DELETE;     }
DESC        { update_location(); return DESC;       }
DISTINCT    { update_location(); return DISTINCT;   } 
ENDS        { update_location(); return ENDS;       }
EXISTS      { update_location(); return EXISTS;     }
IN          { update_location(); return IN;         }
IS          { update_location(); return IS;         }
LIMIT       { update_location(); return LIMIT;      }
MATCH       { update_location(); return MATCH;      }
MERGE       { update_location(); return MERGE;      }
NOT         { update_location(); return NOT;        }
NULL        { update_location(); return NULLX;      }
ON          { update_location(); return ON;         }
OR          { update_location(); return OR;         }
ORDER       { update_location(); return ORDER;      }
REMOVE      { update_location(); return REMOVE;     }
RETURN      { update_location(); return RETURN;     }
SET         { update_location(); return SET;        }
UNION       { update_location(); return UNION;      }
UNWIND      { update_location(); return UNWIND;     }
WHERE       { update_location(); return WHERE;      }
WITH        { update_location(); return WITH;       }
XOR         { update_location(); return XOR;        }
YIELD       { update_location(); return YIELD;      }
TRUE    { update_location(); yylval->intval = 1; return BOOL; }
FALSE   { update_location(); yylval->intval = 0; return BOOL; }


[A-Za-z][A-Za-z0-9_]*	{ update_location(); yylval->strval = strdup(yytext); return NAME; }

   /* numbers */ 
[0-9]*	{ update_location(); yylval->intval = atoi(yytext); return INTNUM; }
[0-9]+"."[0-9]+([Ee][-+]?[0-9]+)?	|
"."[0-9]+([Ee][-+]?[0-9]+)?	{ update_location(); yylval->floatval = atof(yytext) ;return APPROXNUM; }



 /* string*/
'(\\.|''|[^'\n])*'  |
\"(\\.|\"\"|[^"\n])*\"  { update_location(); yylval->strval = strdup(yytext); return STRING; }


"="     { update_location(); yylval->subtok = 4; return COMPARISON; }
">="    { update_location(); yylval->subtok = 6; return COMPARISON; }
">"     { update_location(); yylval->subtok = 2; return COMPARISON; }
"<="    { update_location(); yylval->subtok = 5; return COMPARISON; }
"<"     { update_location(); yylval->subtok = 1; return COMPARISON; }
"<>"    { update_location(); yylval->subtok = 3; return COMPARISON; }

"->"    { update_location(); yylval->strval = strdup(yytext); return RIGHTARROW;}
"<-"    { update_location(); yylval->strval = strdup(yytext); return LEFTARROW;}
"+="    { update_location(); yylval->strval = strdup(yytext); return PLUSEQUL;}

[-+*/%(){}.:;,\[\]<>]  { update_location(); return  yytext[0]; }

".."    { update_location(); yylval->strval = strdup(yytext); return PPOINT; }

[ \t\r\f]       ;
[\n]			;

    /* comments */
"#"[^\n]*	;
"//".*	        ;
"/*"            { update_location(); oldstate = YY_START; BEGIN COMMENT;}
<COMMENT>"*/"   { update_location(); BEGIN oldstate;}
<COMMENT>.|\n   ;
.               { module_scanner_errmsg("cypher error", yyscanner); exit(0);}

%%

static void
yyextra_init(core_yy_extra *extra, char *buf)
{
    extra->high_surrogate = 0;
    extra->start_cond = INITIAL;
    extra->scan_buf = buf;
    extra->last_loc = 0;
    extra->end_loc = 0;
}

static int 
_scan_errmsg(const char *msg, const core_yy_extra *extra)
{
    int ret, loop;
    const char *t = extra->scan_buf + extra->last_loc;
    char * p = (char *)t;

    while(p > extra->scan_buf)
    {
        if (*p == '\n') 
            break;
        p--;
    }
    
    loop = ((p != extra->scan_buf) ? t - ++p : t - p);

    if (t[0] == YY_END_OF_BUFFER_CHAR)
    {
        ret = fprintf(stderr, "\n%s at end of input\n", msg);
    }
    else
    {
        ret = fprintf(stderr, "\n╭ %s near : \"%s\"\n"
                              "╰ Error Exists Here :  ", msg, p);

        for (int i = 0; i < loop; i++, fprintf(stderr, " ")); 

        for (int i = 0; i <= extra->end_loc - extra->last_loc; 
            i++, fprintf(stderr, "↑"))
            ;
        fprintf(stderr, " - Error Here!\n"); 
    }
    return ret;
}

static int 
_scan_errposition(const int location, const core_yy_extra *extra)
{
    int pos;

    // no-op if location is unknown
    if (location < 0)
        return 0;

    // convert byte offset to number of characters
    pos = mblen(extra->scan_buf, location) + 1;

    return pos;
}

core_yyscan_t 
module_scanner_create(const char *s)
{
    unsigned long int len;
    char *buf;
    yyscan_t yyscanner;
    core_yy_extra extra;

    // The last two YY_END_OF_BUFFER_CHAR are required by flex.
    len = strlen(s);
    buf = malloc(len + 2);
    memcpy(buf, s, len);
    buf[len] = YY_END_OF_BUFFER_CHAR;
    buf[len + 1] = YY_END_OF_BUFFER_CHAR;

    if (module_yylex_init(&yyscanner))
        fprintf(stderr, "module_yylex_init() failed: %m");

    yyextra_init(&extra, buf);
    module_yyset_extra(extra, yyscanner);
    module_yy_scan_buffer(buf, len + 2, yyscanner);

    return yyscanner;
}

void 
module_scanner_destroy(core_yyscan_t scanner)
{
    core_yy_extra extra = module_yyget_extra(scanner);

    module_yylex_destroy(scanner);
}

int 
module_scanner_errmsg(const char *msg, core_yyscan_t *scanner)
{
    core_yy_extra extra = module_yyget_extra(scanner);

    return _scan_errmsg(msg, &extra);
}

int 
module_scanner_errposition(const int location, core_yyscan_t *scanner)
{
    core_yy_extra extra = module_yyget_extra(scanner);

    return _scan_errposition(location, &extra);
}