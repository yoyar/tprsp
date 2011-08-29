%{
#include <stdio.h>
#define YYSTYPE char *

#define YYDEBUG 1
	
extern int yydebug;
yydebug = 0;

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

%token WORD COLON JOANNETOK TEASETOK TIME

%%

script:	/* empty script */
	|
	lines
	;

lines: 	line 
	| lines line
	;

line:	tease { printf("Tease: %s\n", $1); }
	|	
	words '\n' 
	| 
	'\n' /* empty line */ 
	;

tease:	JOANNETOK TEASETOK COLON words TIME '\n' { $$ = $4; }
	;

words:	WORD
	|
	words WORD
	;















