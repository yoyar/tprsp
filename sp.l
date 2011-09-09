/*
 * Lex specification for tprsp
 *
 * ----------------------------------------------------------------------
 * Copyright (c) 2011 Matt Friedman  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * ----------------------------------------------------------------------
 */
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

%x categorylist
%x ageslist

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

N		"N"
I		"I"
IT		"IT"
PS		"PS"
ES		"ES"
PT		"PT"
T		"T"
B		"B"
D		"D"
SF		"SF"
E		"E"
F		"F"
H		"H"
LS		"LS"
KC		"KC"
SL		"SL"

INVALIDCODE	[^,\n \t]+

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
	Dprintf("Found Joanne on line: %d", yylineno);
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

^(C|c)lip:?.+ {
	/* the clip heading line starts with Clip: and then continues until the end of the line */
	Dprintf("Clip Heading Line: %s \n", yytext);
	BEGIN inclip;
	return CLIP_HEADING;
}

<inclip>{

 	\n[ \t]*\( {
		/* the opening parens start after the clip heading, then some whitespace, then an open paren */
		return CLIP_OPEN_PARENTHESES;
	}


	\)\n\n {
		/* the final closing paren appears at the end with two line breaks afterwards */
		BEGIN 0;
		return CLIP_CLOSE_PARENTHESES;
	}

	. {
		yylval.str = strdup(yytext);
		return CHAR;
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
	BEGIN categorylist;
	return CATEGORIES_HEADING;
}

^(A|a)ges: {
	Dputs("Ages Heading");
	BEGIN ageslist;
	return AGES_HEADING;
}

<ageslist>{
	{N}|{I}|{IT}|{PS}|{ES}|{PT}|{T} {
                Dprintf("List Item: %s", yytext);
                yylval.str = strdup(yytext);
                return AGES_OR_CATEGORY_CODE;
        }
	{INVALIDCODE} {
		char err[50];
		sprintf(err, "Invalid Ages code found: > %s <", yytext);
		yyerror( err );
		return INVALID_CODE;
	}
	, { 
		Dputs(","); 
		return COMMA;
	}
	\n {
		BEGIN 0;
		yylval.str = strdup(yytext);
		return NEWLINE;
	}
}

<categorylist>{
	{B}|{D}|{SF}|{E}|{N}|{F}|{H}|{LS}|{KC}|{SL}|{F} {
                Dprintf("List Item: %s", yytext);
                yylval.str = strdup(yytext);
                return AGES_OR_CATEGORY_CODE;
        }

	{INVALIDCODE} {
		char err[50];
		sprintf(err, "Invalid Category code found: > %s <", yytext);
		yyerror( err );
		return INVALID_CODE;
	}
	, { 
		Dputs(","); 
		return COMMA;
	}
	\n {
		BEGIN 0;
		yylval.str = strdup(yytext);
		return NEWLINE;
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
