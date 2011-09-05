%{

#include <stdio.h>
#include <string.h>
#include <jansson.h>
#include "sp.c"

#define YYSTYPE char *

#define YYDEBUG 0
	
extern int yydebug;
yydebug = 0;

extern int yylineno;

extern char wordbuf[];

extern char * yytext;

extern json_t *json;
extern json_t *itemlist;

void yyerror(const char *str)
{

        fprintf(stderr, "Error: %s \ton lineno: %d\n", str, yylineno);
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

%token NUMBER
%token WORD
%token COMMA
%token TIMESPEC
%token OPARENS EPARENS
%token QUOTE
%token CHAR

%token WEEK_HEADING
%token WEEK_TITLE

%token FEATURE_HEADING
%token FEATURE_MISC

%token AIRDATE_HEADING

%token TEASE_HEADING

%token INTRO_HEADING

%token CLIP_HEADING

%token BRIDGE_HEADING

%token WRAP_HEADING

%token AGES_HEADING
%token CATEGORIES_HEADING CATEGORY

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
		week feature airdate tease intro clip bridge clip wrap ages 
		| 
		week feature airdate tease intro clip bridge clip wrap 
		|
		week feature airdate tease intro clip wrap ages categories
		|
		week feature airdate tease intro clip wrap ages 
		|
		week feature airdate tease intro clip wrap 
		;

categories:	CATEGORIES_HEADING itemlist '\n' 
		{
			Dprintf("(yacc) Category list: %s", wordbuf);

			json_t * categories = json_pack(
				"{s: o}",	
				"categories", itemlist
			);

			json_array_append(json, categories);

			wordbuf[0] = 0;
		}
		;

ages:		AGES_HEADING itemlist '\n'
		{
			Dprintf("(yacc) Age list: %s", wordbuf);

			json_t * ages = json_pack(
				"{s: o}",	
				"ages", itemlist
			);

			json_array_append(json, ages);

			wordbuf[0] = 0;
		}
		;

itemlist:	WORD
		{
			strcat(wordbuf, $1);

			itemlist = json_array();
			json_t *item = json_pack( "s", $1);
			json_array_append(itemlist, item);
		}
		|
		itemlist COMMA WORD 
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
		CLIP_HEADING error  
		{
			yyerrok;
			yyclearin;
			Dputs("(yacc) Missing Closing Parentheses for Clip");
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

feature:	FEATURE_HEADING NUMBER '-' NUMBER QUOTE words QUOTE FEATURE_MISC 
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


