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
static void strbuf_init(strbuf *sb, int capacity);
static void strbuf_cleanup(strbuf *sb);
static void strbuf_append_buf(strbuf *sb, const char *b, const int len);
static void strbuf_append_char(strbuf *sb, const char c);
static void strbuf_ensure_capacity(strbuf *sb, int len);
static const char *strbuf_get_str(strbuf *sb);
static void strbuf_reset(strbuf *sb);

#define scan_errmsg(msg) _scan_errmsg(msg, &yyextra)
static int _scan_errmsg(const char *msg, const core_yy_extra *extra);
#define scan_errposition() _scan_errposition(yyextra.last_loc, &yyextra)
static int _scan_errposition(const int location, const core_yy_extra *extra);
%}

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
UNWIND      { return UNWIND;     }
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

[ \t\r\f]       ;
[\n]			;

    /* comments */
"#"[^\n]*	;
"//".*	        ;
"/*"            {oldstate = YY_START; BEGIN COMMENT;}
<COMMENT>"*/"   {BEGIN oldstate;}
<COMMENT>.|\n   ;

%%

static void 
strbuf_init(strbuf *sb, int capacity)
{
    sb->buffer = malloc(capacity);
    sb->capacity = capacity;
    sb->length = 0;
}

static void 
strbuf_cleanup(strbuf *sb)
{
    if (sb->buffer)
        free(sb->buffer);
}

static void 
strbuf_append_buf(strbuf *sb, const char *b, const int len)
{
    strbuf_ensure_capacity(sb, sb->length + len);
    memcpy(sb->buffer + sb->length, b, len);
    sb->length += len;
}

static void 
strbuf_append_char(strbuf *sb, const char c)
{
    strbuf_ensure_capacity(sb, sb->length + 1);
    sb->buffer[sb->length] = c;
    sb->length += 1;
}

/*
 * len cannot be greater than MaxAllocSize because ReadCommand() reads
 * a message and places the message body in StringInfo.
 */
static void 
strbuf_ensure_capacity(strbuf *sb, int len)
{
    // consider additional 1 byte for the last '\0' character
    if (len < sb->capacity)
        return;

    do
    {
        sb->capacity *= 2;
    } while (sb->capacity <= len);

    sb->buffer = realloc(sb->buffer, sb->capacity);
}

static const char *
strbuf_get_str(strbuf *sb)
{
    sb->buffer[sb->length] = '\0';
    return sb->buffer;
}

static void 
strbuf_reset(strbuf *sb)
{
    sb->length = 0;
}

static int 
_scan_errmsg(const char *msg, const core_yy_extra *extra)
{
    const char *t = extra->scan_buf + extra->last_loc;

    if (t[0] == YY_END_OF_BUFFER_CHAR)
        return fprintf(stderr, "%s at end of input", msg);
    else
        return fprintf(stderr, "%s at or near \"%s\"", msg, t);
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
    int ret;

    // The last two YY_END_OF_BUFFER_CHAR are required by flex.
    len = strlen(s);
    buf = malloc(len + 2);
    memcpy(buf, s, len);
    buf[len] = YY_END_OF_BUFFER_CHAR;
    buf[len + 1] = YY_END_OF_BUFFER_CHAR;

    ret = module_yylex_init(&yyscanner);
    if (ret)
        fprintf(stderr, "module_yylex_init() failed: %m");

    strbuf_init(&extra.literal_buf, 1024);
    extra.high_surrogate = 0;
    extra.start_cond = INITIAL;
    extra.scan_buf = buf;
    extra.last_loc = 0;
    module_yyset_extra(extra, yyscanner);

    module_yy_scan_buffer(buf, len + 2, yyscanner);

    return yyscanner;
}

void 
module_scanner_destroy(core_yyscan_t scanner)
{
    core_yy_extra extra;

    extra = module_yyget_extra(scanner);
    strbuf_cleanup(&extra.literal_buf);

    module_yylex_destroy(scanner);
}

int 
module_scanner_errmsg(const char *msg, core_yyscan_t *scanner)
{
    core_yy_extra extra;

    extra = module_yyget_extra(scanner);

    return _scan_errmsg(msg, &extra);
}

int 
module_scanner_errposition(const int location, core_yyscan_t *scanner)
{
    core_yy_extra extra;

    extra = module_yyget_extra(scanner);

    return _scan_errposition(location, &extra);
}