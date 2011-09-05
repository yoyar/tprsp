%{
#include "sp.tab.h"
#include "sp.c"
%}

%start joanne 
%start air

%x inairdate
%x inweek
%x inweektext
%x inclip
%x infeature
%x infeaturetitle
%x infeaturetext
%x initemlist
%x inwords

%option yylineno

TIMESPEC	\(:?[0-9]+(\.[0-9]+)?\) 
NUMBER		[0-9]
WORD		[a-zA-Z][a-zA-Z0-9]*
WHITESPACE	[ \t]
BANNER		"THE PARENT REPORT"
INSERT_COM	"- INSERT COMMERCIAL -"

%%

^WEEK {
	Dputs("WEEK HEADING");
	BEGIN inweek;
	return WEEK_HEADING;
}

<inweek>{

	({NUMBER})+ {
		Dprintf("WEEK NUMBER: %s\n", yytext);
		yylval = strdup(yytext);
		return NUMBER;
	}

	\- {
		Dputs("DASH");	
		yylval = strdup(yytext);
		BEGIN inweektext;
		return '-';
	}
}

<inweektext>.+\n {
	Dprintf("WEEK TEXT: %s\n", yytext);
	yylval = strdup(yytext);
	BEGIN 0;
	return WEEK_TITLE;
}

^(J|j)oanne {
	BEGIN joanne;
}

<joanne>{
	(T|t)ease:? {
		Dputs("Joanne Tease Heading"); 
		BEGIN inwords;
		return TEASE_HEADING;
	}

	(I|i)ntro:? {
		Dputs("Joanne Intro Heading");
		BEGIN inwords;
		return INTRO_HEADING;
	}

	(B|b)ridge:? {
		Dputs("Bridge Heading");
		BEGIN inwords;
		return BRIDGE_HEADING;
	}

	(W|w)rap:? {
		Dputs("Wrap Heading");
		BEGIN inwords;
		return WRAP_HEADING;
	}
}

<inwords>{
	. {
		yylval = strdup(yytext);
		return CHAR;
	}
	({TIMESPEC}) {
		BEGIN 0;
		return TIMESPEC;
	}
}

^(F|f)eature:? {
	Dputs("Feature Heading");
	BEGIN infeature;
	return FEATURE_HEADING;
}

<infeature>{
	({NUMBER})+ {
		Dprintf("Feature Number: %s", yytext);	
		yylval = strdup(yytext);
		return NUMBER;
	}

	\- {
		Dputs("DASH");
		return '-';
	}

	\" {
		BEGIN infeaturetitle;
		return QUOTE;
	}
}

<infeaturetitle>{
	[^"] {
		yylval = strdup(yytext);
		return CHAR;
	}
	\" {
		BEGIN infeaturetext;
		return QUOTE;
	}
}

<infeaturetext>.+\n {
	Dprintf("Feature Misc Text: %s\n", yytext);
	yylval = strdup(yytext);
	BEGIN 0;
	return FEATURE_MISC;
}

^(C|c)lip:?.+\n {
	Dprintf("Clip Heading Line: %s \n", yytext);
	BEGIN inclip;
	return CLIP_HEADING;
}

<inclip>{
	^({WHITESPACE})*\( {
		Dputs("Clip open brace");
		BEGIN inclip;
		return OPARENS;
	}

	. {
		yylval = strdup(yytext);
		return CHAR;
	}

	\){WHITESPACE}*\n {
		Dputs("Clip Close Brace");
		BEGIN 0;
		return EPARENS;
	}
}

^(A|a)ir {
	BEGIN air;
}

<air>(D|d)ate:? {
	Dputs("Air Date Heading");
	BEGIN inairdate;
	return AIRDATE_HEADING;
}

<inairdate>{
	({WORD})+ {
		Dprintf("Month: %s", yytext);
		yylval = strdup(yytext);
		return WORD;
	}

	({NUMBER})+ {
		Dprintf("Date Number: %s", yytext);
		yylval = strdup(yytext);
		return NUMBER;
	}

	, {
		Dputs("COMMA");	
		return COMMA;
	}

	\n {
		BEGIN 0;
		return '\n';
	}
}

^(C|c)ategories: {
	Dputs("Categories Heading");
	BEGIN initemlist;
	return CATEGORIES_HEADING;
}

^(A|a)ges: {
	Dputs("Ages Heading");
	BEGIN initemlist;
	return AGES_HEADING;
}

<initemlist>{
	({WORD}) {
		Dprintf("List Item: %s", yytext); 
		yylval = strdup(yytext); 
		return WORD;
	}
	, { 
		Dputs(","); 
		return COMMA;
	}
	\n {
		BEGIN 0;
		return '\n';
	}
}

({BANNER}|{INSERT_COM}) {
	Dputs("Line Ingored...");
	;
}

%%
