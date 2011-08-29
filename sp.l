%{
#include "y.tab.h"
#include "sp.c";
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
	strcat(wordbuf, " ");
;
//	yylval = strdup(yytext);
//	return WHITESPACE;
}

\n {
	return yytext[0];
}

. {
	/* to handle punctuation */
	yylval = strdup(yytext);
	return UNRECOGNIZED;
}



%%
