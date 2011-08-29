%{
#include <stdio.h>
#include <string.h>
#include "sp.c"

#define YYSTYPE char *

#define YYDEBUG 1
	
extern int yydebug;
yydebug = 0;

extern char wordbuf[];

void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
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

%token WORD COLON JOANNETOK TEASETOK TIME UNRECOGNIZED 

%%

script:	/* empty script */
	|
	lines
	;

lines: 	line 
	| lines line
	;

line:	tease {  
		printf("TEASE: %s\n", wordbuf);
		wordbuf[0] = 0;
	}
	|	
	words '\n' 
	| 
	'\n' /* empty line */ 
	;

tease:	JOANNETOK TEASETOK COLON words TIME '\n' 
	;


words:	WORD {
		strcat(wordbuf, $1);
	}
	|
	words WORD {
		strcat(wordbuf, $2);
	}
	|
	words WORD UNRECOGNIZED {
		strcat(wordbuf, " ");
		strcat(wordbuf, $2);
		strcat(wordbuf, $3);
	}
	;















