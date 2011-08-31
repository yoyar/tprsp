%{
#include "y.tab.h"
#include "sp.c"


int tprsp_lineno = 1;

%}

%start joanne 
%start air

%%

^(J|j)oanne {
	BEGIN joanne;
}

<joanne>(T|t)ease:? {
	Dputs("HEADING: Joanne Tease Heading Matched"); 
	BEGIN 0;

	return TEASE_HEADING;
}

<joanne>(I|i)ntro:? {
	Dputs("HEADING: Joanne Intro Heading Matched");
	BEGIN 0;

	return INTRO_HEADING;
}

<joanne>(B|b)ridge:? {
	Dputs("HEADING: Joanne Bridge Heading Matched ");
	BEGIN 0;

	return BRIDGE_HEADING;
}

<joanne>(W|w)rap:? {
	Dputs("HEADING: Wrap Heading Matched");
	BEGIN 0;

	return WRAP_HEADING;
}

^(F|f)eature:? {
	Dputs("HEADING: Feature Heading Matched");

	return FEATURE_HEADING;
}

^WEEK {
	Dputs("HEADING: WEEK Heading Matched");
	yylval = strdup(yytext); 
	return WEEK_HEADING;
}

^(C|c)lip:? {
	Dputs("HEADING: Clip Heading Matched");

	return CLIP_HEADING;
}

^(A|a)ir {
	BEGIN air;
}

<air>(D|d)ate:? {
	Dputs("HEADING: Air Date Heading Matched");
	BEGIN 0;
	return AIRDATE_HEADING;
}

^(C|c)ategories:? {
	Dputs("HEADING: Categories Heading Matched");

	return CATEGORIES_HEADING;
}

^(A|a)ges:? {
	Dputs("HEADING: Ages Heading Matched");

	return AGES_HEADING;
}

\(:?[0-9]+(\.[0-9]+)?\) {

	Dputs("TIME specification matched.....");
	return TIME;
}


([a-zA-Z][a-zA-Z0-9]*)+ {  /* WORD */

	Dprintf("%s", yytext);
	yylval = strdup(yytext); 
	return WORD;
}

[0-9]+ { /* NUMBER */
	yylval = strdup(yytext);
	Dprintf("%s\n", yytext);
	return NUMBER;
}

[ \t]+ { 
 	strcat(wordbuf, " ");
	;
}

 /* \n.+  { 

	// error handling 
	// see: http://oreilly.com/linux/excerpts/9780596155971/error-reporting-recovery.html 

	strncpy(linebuf, yytext+1, sizeof(linebuf)); // save the next line 

	yyless(1);      // give back all but the \n to rescan 

} */


\n {
	tprsp_lineno++;
	return yytext[0]
	;
}

\" {
	Dprintf("%s\n", yytext);
	yylval = strdup(yytext);
	return QUOTE;
}

- {
	Dprintf("%s\n", yytext);
	yylval = strdup(yytext);
	return DASH;
}

[^a-zA-Z0-9 \t\n"\-] {      /* ! (word | number | whitespace | newline)  */
	/* punctuation */
	Dprintf("%s\n", yytext);
	yylval = strdup(yytext);
	return PUNCTUATION;
}



%%
