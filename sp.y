/*
 * Bison specification for tprsp
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
#include <stdio.h>
#include <string.h>
#include <jansson.h>
#include "sp.c"

#define YYDEBUG 0

extern int yylineno;

extern char wordbuf[];

extern char * yytext;

extern json_t *json;
extern json_t *itemlist;

void yyerror(const char *str)
{
        //fprintf(stderr, "Error: %s \ton lineno: %d\n", str, yylineno);

	json_t *err = json_pack(
		"{s: s, s: i}",
		"error", str,
		"lineno", yylineno
	);

	json_array_append(json, err);
}
 
int yywrap()
{
        return 1;
} 
  
main()
{
	json = json_array();
        yyparse();
	json_dumpf(json, stdout, JSON_INDENT(2));
	printf("\n");
} 

%}

%token<str> NUMBER
%token<str> WORD
%token<str> COMMA
%token<str> TIMESPEC
%token<str> OPARENS EPARENS
%token<str> QUOTE
%token<str> CHAR

%token<str> WEEK_HEADING
%token<str> WEEK_TITLE

%token<str> FEATURE_HEADING
%token<str> FEATURE_MISC

%token<str> AIRDATE_HEADING

%token<str> TEASE_HEADING

%token<str> INTRO_HEADING

%token<str> CLIP_HEADING

%token<str> BRIDGE_HEADING

%token<str> WRAP_HEADING

%token<str> AGES_HEADING
%token<str> CATEGORIES_HEADING CATEGORY
%token<str> AGES_OR_CATEGORY_CODE

%union {
	char * str;
}

%type<str> itemlist week airdate words

%error-verbose

%%

script:		/* empty script */
		|
		sections
		;

sections: 	section
		|
		sections section
		;

section: 	'\n' 
		| 
		week feature airdate tease intro clip bridge clip wrap ages categories
		| 
		week feature airdate tease intro clip bridge clip wrap 
		|
		week feature airdate tease intro clip wrap ages categories
		|
		week feature airdate tease intro clip wrap 
		;

categories:	CATEGORIES_HEADING itemlist '\n' 
		{
			Dprintf("(yacc) Category list: %s", wordbuf);

			json_t * categories = json_pack(
				"{s: {s: o}}",	
				"categories", 
				"items", itemlist
			);

			json_array_append(json, categories);

			wordbuf[0] = 0;
		}
		|
		CATEGORIES_HEADING error '\n'
		{
			json_t * err = json_pack(
				"{s: s}",
				"error",
				"Categories group list error. Codes must be one or two uppercase letters."
			);
			json_array_append(json, err);
		}
		;

ages:		AGES_HEADING itemlist '\n'
		{
			Dprintf("(yacc) Age list: %s", wordbuf);

			json_t * ages = json_pack(
				"{s: {s:o}}",	
				"ages", 		
				"items", itemlist
			);

			json_array_append(json, ages);

			wordbuf[0] = 0;
		}
		|
		AGES_HEADING error '\n'
		{
			json_t * err = json_pack(
				"{s: s}",
				"error",
				"Age group list error. Codes must be one or two uppercase letters."
			);
			json_array_append(json, err);
		}
		;

itemlist:	AGES_OR_CATEGORY_CODE	
		{
			strcat(wordbuf, $1);

			itemlist = json_array();
			json_t *item = json_pack( "s", $1);
			json_array_append(itemlist, item);
		}
		|
		itemlist COMMA AGES_OR_CATEGORY_CODE
		{
			strcat(wordbuf, ","); strcat(wordbuf, $3);
			json_t *item = json_pack( "s", $3);
			json_array_append(itemlist, item);
		}
		;

wrap:		WRAP_HEADING words TIMESPEC
		{
			Dprintf("(yacc) Wrap: %s", wordbuf);
			
			json_t * wrap = json_pack(
				"{s: {s:s}}",
				"wrap",
				"text", wordbuf
			);
			
			json_array_append(json, wrap);

			wordbuf[0] = 0;
		}
		;

bridge:		BRIDGE_HEADING words TIMESPEC
		{
			Dprintf("(yacc) Bridge: %s", wordbuf);

			json_t * bridge = json_pack(
				"{s: {s:s}}",
				"bridge",
				"text", wordbuf
			);
			
			json_array_append(json, bridge);

			wordbuf[0] = 0;
		}
		;	

clip:		CLIP_HEADING  clipwords 
		{
			Dprintf("(yacc) Clip: %s", wordbuf);

			json_t * clip = json_pack(
				"{s: {s:s}}",
				"clip",
				"text", wordbuf
			);
			
			json_array_append(json, clip);

			wordbuf[0] = 0;
		}
		|
		CLIP_HEADING error '\n' 
		{
			Dputs("(yacc) Missing Closing Parentheses for Clip");

			json_t * clip = json_pack(
				"{s: {s:s}}",
				"clip",
				"error", "Missing closing parentheses (clip)"
			);

			json_array_append(json, clip);
		}
		;	

clipwords:	'(' words ')' 
		;

intro:		INTRO_HEADING words TIMESPEC 
		{
			Dprintf("(yacc) INTRO: %s", wordbuf);
			
			json_t *intro = json_pack(
				"{s:{s:s}}", "intro", "text", wordbuf 
			);

			json_array_append(json, intro);

			wordbuf[0] = 0;
		}
		;

feature:	FEATURE_HEADING NUMBER '-' NUMBER QUOTE words QUOTE 
		{
                        Dprintf("(yacc) Feature title: %s " , wordbuf);
			
			json_t *feature = json_pack(
				"{s: {s:s}}",
				"feature",
				"title", wordbuf
			);

			json_array_append(json, feature);

			wordbuf[0] = 0;
                }
		|
	 	FEATURE_HEADING NUMBER '-' NUMBER QUOTE words error
		{
			json_t * err = json_pack(
				"{s:s}", "error", 
				"Invalid Feature line format. Missing end quote."
			);
			json_array_append(json, err);
		}
		;

week:		WEEK_HEADING NUMBER '-' WEEK_TITLE   
		{
			Dprintf("(yacc) WEEK  number:%s title:%s", $2, $4); 

			json_t *week = json_pack(
				"{s: {s:s, s:s}}",
				"week",
				"number", $2,
				"title", $4	
			);

			json_array_append(json, week);
		}
		|
		WEEK_HEADING NUMBER '-' error '\n' 
		{
			json_t * err = json_pack(
				"{s: s}",
				"error",
				"Invalid Week line format. "
			);
			json_array_append(json, err);
		}
		;

airdate:	AIRDATE_HEADING WORD NUMBER COMMA NUMBER '\n' 
		{
                        Dprintf("(yacc) Airdate: %s %s, %s", $2, $3, $5);

			json_t * airdate = json_pack(
				"{s: {s:s, s:s, s:s}}",
				"airdate",
				"month", $2,
				"date", $3,
				"year", $5
			);
			
			json_array_append(json, airdate);
                }
		|	
		AIRDATE_HEADING error '\n'
		{
			json_t * err = json_pack(
				"{s: {s:s}}",
				"airdate",		
				"error", "Invalid date format. "
			);
			json_array_append(json, err);
		}
		;

tease:		TEASE_HEADING words TIMESPEC 
		{
       			Dprintf("(yacc) Tease: %s", wordbuf);

			json_t *tease = json_pack(
				"{s: {s:s}}",
				"tease",
				"text", wordbuf 
			);

			json_array_append(json, tease);

       			wordbuf[0] = 0;
		}
		|
		TEASE_HEADING words error '\n'
		{
			yyclearin;
			json_t * err = json_pack(
				"{s: {s:s}}",
				"tease",		
				"error", "Invalid Tease format. Failed to find time specification at end. "
			);
			json_array_append(json, err);

		}
		;

words:		CHAR 
		{
			strcat(wordbuf, $1);
		}	
		|
		words CHAR 
		{
			strcat(wordbuf, $2);
		}
		;


