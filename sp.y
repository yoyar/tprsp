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
        yyparse();
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
			wordbuf[0] = 0;
		}
		;

ages:		AGES_HEADING itemlist '\n'
		{
			Dprintf("(yacc) Age list: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;

itemlist:	WORD
		{
			strcat(wordbuf, $1);
		}
		|
		itemlist COMMA WORD 
		{
			strcat(wordbuf, ","); strcat(wordbuf, $3);
		}
		;

wrap:		WRAP_HEADING words TIMESPEC
		{
			Dprintf("(yacc) Wrap: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;

bridge:		BRIDGE_HEADING words TIMESPEC
		{
			Dprintf("(yacc) Bridge: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;	

clip:		CLIP_HEADING  clipwords 
		{
			Dprintf("(yacc) Clip: %s", wordbuf);
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

			json_t *tprjson = json_array();

			json_error_t *error;

			json_t *intro = json_pack_ex(
				error,
				0,
				"{s:s}", "intro", wordbuf 
			);

			if( error ) Dprintf("Json error: %s", (char *)error);

			json_array_append(tprjson, intro);

			json_dumpf(tprjson, stdout, 0);

			wordbuf[0] = 0;
		}
		;

feature:	FEATURE_HEADING NUMBER '-' NUMBER QUOTE words QUOTE FEATURE_MISC 
		{
                        Dprintf("(yacc) Feature title: %s " , wordbuf);
			wordbuf[0] = 0;
                }
		;

week:		WEEK_HEADING NUMBER '-' WEEK_TITLE  
		{
			Dprintf("(yacc) WEEK  number:%s title:%s", $2, $4); 
		}
		;

airdate:	AIRDATE_HEADING WORD NUMBER COMMA NUMBER '\n' 
		{
                        Dprintf("(yacc) Airdate: %s %s, %s", $2, $3, $5);
                }
		;

tease:		TEASE_HEADING words TIMESPEC 
		{
       			Dprintf("(yacc) Tease: %s", wordbuf);
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


