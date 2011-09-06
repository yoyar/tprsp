
all:
	flex sp.l 
	bison -d sp.y 
	cc lex.yy.c sp.tab.c -o tprsp -ljansson

clean:
	rm tprsp sp.tab.* lex.yy.c

install:
	cp ./tprsp /usr/local/bin



