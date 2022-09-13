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
#define Return update_location(); return
#define scan_errmsg(msg) _scan_errmsg(msg, &yyextra)
#define scan_errposition() _scan_errposition(yyextra.last_loc, &yyextra)

static void yyextra_init(core_yy_extra *extra, char *buf);
static int _scan_errmsg(const char *msg, const core_yy_extra *extra);
static int _scan_errposition(const int location, const core_yy_extra *extra);
extern int module_scanner_errmsg(const char *msg, core_yyscan_t *scanner);
extern int module_scanner_errposition(const int location, core_yyscan_t *scanner);

%}

%%

ALL         { Return ALL;        }
AND         { Return AND;        }
ANY         { Return ANY;        }
AS          { Return AS;         }
ASC         { Return ASC;        }
BY          { Return BY;         }
CALL        { Return CALL;       }
CONTAINS    { Return CONTAINS;   }
COUNT       { Return COUNT;      }
CREATE      { Return CREATE;     }
DELETE      { Return DELETE;     }
DESC        { Return DESC;       }
DISTINCT    { Return DISTINCT;   } 
ENDS        { Return ENDS;       }
EXISTS      { Return EXISTS;     }
IN          { Return IN;         }
IS          { Return IS;         }
LIMIT       { Return LIMIT;      }
MATCH       { Return MATCH;      }
MERGE       { Return MERGE;      }
NOT         { Return NOT;        }
NULL        { Return NULLX;      }
ON          { Return ON;         }
OR          { Return OR;         }
ORDER       { Return ORDER;      }
REMOVE      { Return REMOVE;     }
RETURN      { Return RETURN;     }
SET         { Return SET;        }
UNION       { Return UNION;      }
UNWIND      { Return UNWIND;     }
WHERE       { Return WHERE;      }
WITH        { Return WITH;       }
XOR         { Return XOR;        }
YIELD       { Return YIELD;      }
TRUE    { yylval->intval = 1; Return BOOL; }
FALSE   { yylval->intval = 0; Return BOOL; }


[A-Za-z][A-Za-z0-9_]*	{ yylval->strval = strdup(yytext); Return NAME; }

   /* numbers */ 
[0-9]*	{ yylval->intval = atoi(yytext); Return INTNUM; }
[0-9]+"."[0-9]+([Ee][-+]?[0-9]+)?	|
"."[0-9]+([Ee][-+]?[0-9]+)?	{ yylval->floatval = atof(yytext); Return APPROXNUM; }



 /* string*/
'(\\.|''|[^'\n])*'  |
\"(\\.|\"\"|[^"\n])*\"  { yylval->strval = strdup(yytext); Return STRING; }


"="     { yylval->subtok = 4; Return COMPARISON; }
">="    { yylval->subtok = 6; Return COMPARISON; }
">"     { yylval->subtok = 2; Return COMPARISON; }
"<="    { yylval->subtok = 5; Return COMPARISON; }
"<"     { yylval->subtok = 1; Return COMPARISON; }
"<>"    { yylval->subtok = 3; Return COMPARISON; }

"->"    { yylval->strval = strdup(yytext); Return RIGHTARROW; }
"<-"    { yylval->strval = strdup(yytext); Return LEFTARROW;  }
"+="    { yylval->strval = strdup(yytext); Return PLUSEQUL;   }

[-+*/%(){}.:;,\[\]<>]  { Return  yytext[0]; }

".."    { yylval->strval = strdup(yytext); Return PPOINT; }

[ \t\r\f]       ;
[\n]			;

    /* comments */
"#"[^\n]*	;
"//".*	        ;
"/*"            { oldstate = YY_START; BEGIN COMMENT; }
<COMMENT>"*/"   { BEGIN oldstate; }
<COMMENT>.|\n   ;
.               { module_scanner_errmsg("cypher error", yyscanner); exit(0); }

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