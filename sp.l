%{
#include "y.tab.h"
%}

%%


Joanne|joanne {
	return JOANNETOK;
}

Tease|tease {
	return TEASETOK;
}

\(:?[0-9]+\.?[0-9]*\) {
	return TIME;
}

[a-zA-Z][a-zA-Z0-9]+ {
	yylval = strdup(yytext); 
	return WORD;
}

: {
	yylval = strdup(yytext); 
	return COLON;
}

[ \t]+ { 
	/* ignore whitespace */
	;
}

\n {
	return yytext[0];
}

. {
	/* ignore unrecognized characters */
	;
}

%%
