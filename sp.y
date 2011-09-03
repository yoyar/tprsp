%{

#include <stdio.h>
#include <string.h>
#include "sp.c"

#define YYSTYPE char *

#define YYDEBUG 1
	
extern int yydebug;
yydebug = 0;

extern int yylineno;

extern char wordbuf[];

extern char * yytext;

extern int tprsp_lineno;

void yyerror(const char *str)
{

        fprintf(stderr, "Error: %s\n\ton line: %s lineno: %d\n", str, linebuf, tprsp_lineno);
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

%token WEEK_HEADING
%token WEEK_TITLE

%token FEATURE_TITLE_CHAR
%token FEATURE_HEADING
%token FEATURE_MISC

%token AIRDATE_HEADING

%token TEASE_HEADING
%token TEASE_CHAR

%token INTRO_HEADING
%token INTRO_CHAR

%token CLIP_HEADING
%token CLIP_CHAR 

%token BRIDGE_HEADING
%token BRIDGE_CHAR

%token WRAP_HEADING
%token WRAP_CHAR

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
 
section:	'\n'
		|
		week  
		|
		feature
		|
		airdate 
		|
		tease 
		|
		intro
		|
		clip
		|
		bridge
		|
		wrap
		|
		ages
		|
		categories
		;

categories:	CATEGORIES_HEADING categorylist 
		{
			Dprintf("Category list: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;

categorylist:	category
		{
			strcat(wordbuf, $1);
		}
		|
		categorylist COMMA category 
		{
			strcat(wordbuf, ","); strcat(wordbuf, $3);
		}
		;

category:	CATEGORY 
		|
		error 
		{
			/* FIXME fix error handling */
			yyerrok;
			Dputs("An invalid category was found, but I don't know what it was FIXME...");
		}
		;



ages:		AGES_HEADING agelist
		{
			Dprintf("Age list: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;

agelist:	age
		{
			strcat(wordbuf, $1);
		}
		|
		agelist	COMMA age
		{
			strcat(wordbuf, ","); strcat(wordbuf, $3);
		}
		;

age:		WORD
		;

wrap:		WRAP_HEADING wrapwords TIMESPEC
		{
			Dprintf("(yacc) Wrap: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;

bridge:		BRIDGE_HEADING bridgewords TIMESPEC
		{
			Dprintf("(yacc) Bridge: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;	

clip:		CLIP_HEADING OPARENS clipwords EPARENS
		{
			Dprintf("(yacc) Clip: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;	

intro:		INTRO_HEADING introwords TIMESPEC 
		{
			Dprintf("(yacc) INTRO: %s", wordbuf);
			wordbuf[0] = 0;
		}
		;

feature:	FEATURE_HEADING NUMBER '-' NUMBER QUOTE feature_titlewords QUOTE FEATURE_MISC 
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

tease:		TEASE_HEADING teasewords TIMESPEC 
		{
       			Dprintf("(yacc) Tease: %s", wordbuf);
       			wordbuf[0] = 0;
		}
		;

feature_titlewords:
		FEATURE_TITLE_CHAR 
		{
			strcat(wordbuf, $1);
		}
		|
		feature_titlewords FEATURE_TITLE_CHAR
		{
			strcat(wordbuf, $2);
		}
		;

teasewords:	TEASE_CHAR 
		{
			strcat(wordbuf, $1);
		}	
		|
		teasewords TEASE_CHAR 
		{
			strcat(wordbuf, $2);
		}
		;

introwords:	INTRO_CHAR
		{
			strcat(wordbuf, $1);
		}
		|
		introwords INTRO_CHAR 
		{
			strcat(wordbuf, $2);
		}
		;

clipwords:	CLIP_CHAR
		{
			strcat(wordbuf, $1);
		}
		|
		clipwords CLIP_CHAR 
		{
			strcat(wordbuf, $2);
		}
		;

bridgewords:	BRIDGE_CHAR
		{
			strcat(wordbuf, $1);
		}
		|
		bridgewords BRIDGE_CHAR 
		{
			strcat(wordbuf, $2);
		}
		;

wrapwords:	WRAP_CHAR
		{
			strcat(wordbuf, $1);
		}
		|
		wrapwords WRAP_CHAR 
		{
			strcat(wordbuf, $2);
		}
		;







