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


/*
void yyerror(char *s)
    {
          printf("%d: %s at %s\n", yylineno, s, yytext);
    }
*/
 
int yywrap()
{
        return 1;
} 
  
main()
{
        yyparse();
} 

%}

%token WORD NUMBER TEASE_HEADING INTRO_HEADING BRIDGE_HEADING WRAP_HEADING FEATURE_HEADING WEEK_HEADING CLIP_HEADING AIRDATE_HEADING CATEGORIES_HEADING AGES_HEADING TIME PUNCTUATION DASH QUOTE

%%

script:	/* empty script */
	|
	lines
	;

lines: 	line 
	| lines line
	;
 
line:	WEEK_HEADING NUMBER DASH words '\n' {
		//strcat(wordbuf, $2);
		Dprintf("WEEK NUMBER: %s WORDS: %s\n", $2, wordbuf);
		wordbuf[0] = 0;
	}
	|
	FEATURE_HEADING NUMBER DASH NUMBER quotedstring words '\n' {
		Dprintf(" *********** Feature title: %s\n", $5);
	}
	|	
	words '\n' {
		wordbuf[0] = 0;
	}
	|
	'\n' /* empty line */ {
		Dputs("yacc: Newline");
		wordbuf[0] = 0;
	}
	;


quotedstring:	QUOTE words QUOTE {
		$$ = strdup(wordbuf);
		Dprintf("Quoted: %s\n", $$);
	}
	;



words:	/* empty words */	
	|	
	WORD {
		Dprintf("yacc: %s\n", $1);
		strcat(wordbuf, $1);
	}
	|
	words WORD {
		Dprintf("yacc: %s\n", $2);
		strcat(wordbuf, $2);
	}
	|
	words NUMBER {
		Dprintf("yacc: %s\n", $2);
		strcat(wordbuf, $2);
	}
	|
	words PUNCTUATION {
		Dprintf("yacc: %s\n", $2);
		strcat(wordbuf, $2);
	}

	;















