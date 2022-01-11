%option noyywrap yylineno case-insensitive

%{
//#include "glrmysql.tab.h"
#include <stdarg.h>
#include <string.h>

void yyerror(char *s, ...);

int oldstate;

%}

%x COMMENT
%s BTWMODE

%%



  /* Hack for BETWEEN ... AND ... 
   * return special AND token if BETWEEN seen
   */
ADD         { printf(" ADD ");       }
ALL         { printf(" ALL ");       }
AS          { printf(" AS ");        }
ASC         { printf(" ASC ");       }
ANY			{ printf( "ANY ");		 }
ASCENDING   { printf(" ASCENDING "); }
BY          { printf(" BY ");        }
CASE        { printf(" CASE ");      }
CONSTRAINT  { printf(" CONSTRAINT ");}
CONTAINS    { printf(" CONTAINS ");  }
CREATE      { printf(" CREATE ");    }
DELETE      { printf(" DELETE ");    }
DESC        { printf(" DESC ");      }
DESCENDING  { printf(" DESCENDING ");}
DETACH      { printf(" DETACH ");    }
DISTINCT    { printf(" DISTINCT ");  }
DO          { printf(" DO ");        }
DROP        { printf(" DROP ");      }
ELSE        { printf(" ELSE ");      }
END         { printf(" END ");       }
ENDS        { printf(" ENDS ");      }
EXISTS      { printf(" EXISTS ");    }
FOR         { printf(" FOR ");       }
IN          { printf(" IN ");        }
IS          { printf(" IS ");        }
LIMIT       { printf(" LIMIT ");     }
MANDATORY   { printf(" MANDATORY "); }
MATCH       { printf(" MATCH ");     }
MERGE       { printf(" MERGE ");     }
OF          { printf(" OF ");        }
ON          { printf(" ON ");        }
OPTIONAL    { printf(" OPTIONAL ");  }
ORDER       { printf(" ORDER ");     }
REMOVE      { printf(" REMOVE ");    }
REQUIRE     { printf(" REQUIRE ");   }
RETURN      { printf(" RETURN ");    }
SCALAR      { printf(" SCALAR ");    }
SET         { printf(" SET ");       }
SKIP        { printf(" SKIP ");      }
STARTS      { printf(" STARTS ");    }
THEN        { printf(" THEN ");      }
UNION       { printf(" UNION ");     }
UNIQUE      { printf(" UNIQUE ");    }
UNWIND      { printf(" UNWIND ");    }
WHEN        { printf(" WHEN ");      }
WHERE       { printf(" WHERE ");     }
WITH        { printf(" WITH ");      }

AND			{ printf("AND ");		}	
OR			{ printf("OR ");		}	
XOR			{ printf("XOR ");		}	
NOT			{ printf("NOT ");		}	

COUNT	{ printf("COUNT"); }
TRUE	{ printf("BOOL "); }
UNKNOWN	{ printf("BOOL ");	}
FALSE	{ printf("BOOL "); }

[A-Za-z][A-Za-z0-9_]*	{ printf("NAME"); }

   /* numbers */
[0-9]*	        { printf("NUMBER "); } 

[0-9]+"."[0-9]+([Ee][-+]?[0-9]+)?	{ printf("APPROXNUM "); }


   /* strings */
'(\\.|''|[^'\n])*'	|
\"(\\.|\"\"|[^"\n])*\"  { printf("STRING "); }

'(\\.|[^'\n])*$	        { printf("Unterminated string %s ", yytext); }
\"(\\.|[^"\n])*$	{ printf("Unterminated string %s ", yytext); }


   /* operators */
[-+*/%\^(){}.:;,\[\]]   { printf("%c", yytext[0]); }


"="	    { printf(" = "); }
">="	{ printf(" >= "); }
">"	    { printf(" > "); }
"<="	{ printf(" <= "); }
"<"	    { printf(" < "); }
"<>"	{ printf(" <> "); }


	/* comments */   
#.*		;
"//"[ \t].*	;

	/* everything else */
[ \t\n]	;	
.               { printf("mystery character "); }


%%

main()
{
  yylex();
}

