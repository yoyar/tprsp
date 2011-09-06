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
%x inclipparens
%x infeature
%x infeaturetitle
%x infeaturetext
%x initemlist
%x inwords

%option yylineno

NUMBER		[0-9]
WORD		[a-zA-Z][a-zA-Z0-9]*
CODE		[A-Z][A-Z]?
WHITESPACE	[ \t]
W		[ \t]*
BANNER		"THE PARENT REPORT"
INSERT_COM	"- INSERT COMMERCIAL -"
INSERT_COM2	"[ \t]*-INSERTCOMMERCIAL-"
JOANNE		"^(J|j)oanne"
TIMESPEC	\(:?[0-9]+(\.[0-9]+)?\) 
DASH		-|–
DBLQUOTE	“|”|\"

%%

^WEEK {
	Dputs("WEEK HEADING");
	BEGIN inweek;
	return WEEK_HEADING;
}

<inweek>{

	({NUMBER})+ {
		Dprintf("WEEK NUMBER: %s\n", yytext);
		yylval.str = strdup( yytext);
		return NUMBER;
	}

	({DASH}) {
		Dputs("DASH");	
		yylval.str = strdup(yytext);
		BEGIN inweektext;
		return '-';
	}
}

<inweektext>.+ {
	Dprintf("WEEK TEXT: %s\n", yytext);
	yylval.str = strdup(yytext);
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
		yylval.str = strdup(yytext);
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
		yylval.str = strdup(yytext);
		return NUMBER;
	}

	({DASH}) {
		Dputs("DASH");
		return '-';
	}

	({DBLQUOTE}) {
		BEGIN infeaturetitle;
		return QUOTE;
	}
}

<infeaturetitle>{
	[^“”\"\n] {
		yylval.str = strdup(yytext);
		return CHAR;
	}
	({DBLQUOTE}) {
		BEGIN infeaturetext;
		return QUOTE;
	}

	\n {
		BEGIN 0;
	}
}

<infeaturetext>{
	.+ {
		Dprintf("Feature Misc Text: %s", yytext);
		//yylval = strdup(yytext);
		//return FEATURE_MISC;
	}

	\n {
		BEGIN 0;
	}
}

^(C|c)lip:?.+\n({WHITESPACE}) {
	Dprintf("Clip Heading Line: %s \n", yytext);
	BEGIN inclip;
	return CLIP_HEADING;
}

<inclip>{

	\( {
		return '(';
	}

	\) {
		return ')';
	}

	. {
		yylval.str = strdup(yytext);
		return CHAR;
	}

	\n {
		BEGIN 0;
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
		yylval.str = strdup(yytext);
		return WORD;
	}

	({NUMBER})+ {
		Dprintf("Date Number: %s", yytext);
		yylval.str = strdup(yytext);
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
	({CODE}) {
		Dprintf("List Item: %s", yytext); 
		yylval.str = strdup(yytext); 
		return AGES_OR_CATEGORY_CODE;
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

({BANNER}|{INSERT_COM}|{INSERT_COM2}) {
	Dputs("Line Ingored...");
	;
}

\n {
	;
}

[ \t] {
	;
}

. {
	;
}

%%
