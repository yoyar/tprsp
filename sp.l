%{
#include "y.tab.h"
#include "sp.c"

int tprsp_lineno = 1;
%}

%start joanne 
%start air

%x inairdate
%x inweek
%x inweektext
%x intease
%x inintro
%x inclip
%x infeature
%x infeaturetitle
%x infeaturetext
%x inwrap
%x inbridge

%x incategorylist
%x inagelist

TIMESPEC	\(:?[0-9]+(\.[0-9]+)?\) 
NUMBER		[0-9]
WORD		[a-zA-Z][a-zA-Z0-9]*
WHITESPACE	[ \t]
BANNER		"THE PARENT REPORT"
INSERT_COM	"- INSERT COMMERCIAL -"
CATEGORIES	B|D|SF|E|N|F|H|LS|KC|SL|F 
AGES		I|IT|PS|ES|PT|T

%%

({BANNER}|{INSERT_COM}) {
	Dputs("Line Ingored...");
	;
}

^WEEK {
	Dputs("WEEK HEADING");
	BEGIN inweek;
	return WEEK_HEADING;
}

<inweek>({NUMBER})+ {
	Dprintf("WEEK NUMBER: %s\n", yytext);
	yylval = strdup(yytext);
	return NUMBER;
}

<inweek>\- {
	Dputs("DASH");	
	yylval = strdup(yytext);
	BEGIN inweektext;
	return '-';
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




<joanne>(T|t)ease:? {
	Dputs("HEADING: Joanne Tease Heading Matched\n"); 
	BEGIN intease;
	return TEASE_HEADING;
}

<intease>. {
	yylval = strdup(yytext);
	return TEASE_CHAR;
}

<intease>({TIMESPEC}) {

	BEGIN 0;
	return TIMESPEC;
}





<joanne>(I|i)ntro:? {
	Dputs("HEADING: Joanne Intro Heading Matched");
	BEGIN 0;
	BEGIN inintro;

	return INTRO_HEADING;
}

<inintro>. {
	return INTRO_CHAR;
}

<inintro>({TIMESPEC}) {
	Dputs("Done matching intro");
	BEGIN 0;
	return TIMESPEC;
}




<joanne>(B|b)ridge:? {
	Dputs("Bridge Heading");
	BEGIN inbridge;
	return BRIDGE_HEADING;
}

<inbridge>. {
	yylval = strdup(yytext);
	return BRIDGE_CHAR;
}

<inbridge>({TIMESPEC}) {
	BEGIN 0;
	return TIMESPEC;
}





<joanne>(W|w)rap:? {
	Dputs("HEADING: Wrap Heading Matched");
	BEGIN inwrap;
	return WRAP_HEADING;
}

<inwrap>. {
	yylval = strdup(yytext);
	return WRAP_CHAR;
}

<inwrap>({TIMESPEC}) {
	BEGIN 0;
	return TIMESPEC;
}




^(F|f)eature:? {
	Dputs("HEADING: Feature Heading Matched");
	BEGIN infeature;
	return FEATURE_HEADING;
}

<infeature>({NUMBER})+ {
	Dprintf("Feature Num: %s\n", yytext);	
	yylval = strdup(yytext);
	return NUMBER;
}

<infeature>\- {
	Dputs("DASH");
	return '-';
}

<infeature>\" {
	BEGIN infeaturetitle;
	return QUOTE;
}

<infeaturetitle>[^"] {
	yylval = strdup(yytext);
	return FEATURE_TITLE_CHAR;
}

<infeaturetitle>\" {
	BEGIN infeaturetext;
	return QUOTE;
}

<infeaturetext>.+\n {
	Dprintf("Feature TEXT: %s\n", yytext);
	yylval = strdup(yytext);
	BEGIN 0;
	return FEATURE_MISC;
}






^(C|c)lip:?.+\n {
	Dprintf("CLIP LINE: %s \n", yytext);
	BEGIN inclip;
	return CLIP_HEADING;
}

<inclip>^({WHITESPACE})*\( {
	Dputs("Clip open brace");
	BEGIN inclip;
	return OPARENS;
}

<inclip>. {
	yylval = strdup(yytext);
	return CLIP_CHAR;
}

<inclip>\){WHITESPACE}*\n {
	Dputs("Clip Close Brace");
	BEGIN 0;
	return EPARENS;
}






^(A|a)ir {
	BEGIN air;
}

<air>(D|d)ate:? {
	Dputs("HEADING: Air Date Heading Matched");
	BEGIN inairdate;
	return AIRDATE_HEADING;
}

<inairdate>({WORD})+ {
	Dprintf("Month: %s", yytext);
	yylval = strdup(yytext);
	return WORD;
}

<inairdate>({NUMBER})+ {
	Dprintf("NUM: %s", yytext);
	yylval = strdup(yytext);
	return NUMBER;
}

<inairdate>, {
	Dputs("comma ,");	
	return COMMA;
}

<inairdate>\n {
	BEGIN 0;
	return '\n';
}
	


^(C|c)ategories:? {
	Dputs("HEADING: Categories Heading Matched");
	BEGIN incategorylist;
	return CATEGORIES_HEADING;
}

<incategorylist>{
	({CATEGORIES}) Dprintf("Category: %s", yytext); yylval=strdup(yytext); return CATEGORY;
	, Dputs(","); return COMMA;
	\n BEGIN 0;
}

^(A|a)ges:? {
	Dputs("HEADING: Ages Heading Matched");
	BEGIN inagelist;
	return AGES_HEADING;
}

<inagelist>{
	, Dputs(","); return COMMA;
	({WORD}) Dprintf("Age: %s", yytext); yylval=strdup(yytext); return WORD;
	\n BEGIN 0;
}



 /* [ \t]+ { 
 	strcat(wordbuf, " ");
	;
}*/


 /* .+\n {
	Dprintf("Unmatched line: %s \n", yytext);
}*/

%%
