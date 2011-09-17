
BASEURL_LOCAL=/web/vhosts/legacy.theparentreport.com/www/html/admin/radio

all:
	flex sp.l 
	bison -d sp.y 
	cc lex.yy.c sp.tab.c -o tprsp -ljansson

clean:
	rm tprsp sp.tab.* lex.yy.c

install:
	cp ./tprsp /usr/local/bin

deploy.local:
	cp -a ./php/* ./php/.htaccess $(BASEURL_LOCAL)
	sed -i 's/##word2json.url##/http:\/\/localhost:8082\/admin\/radio\/word2json.php/' \
		$(BASEURL_LOCAL)/validate.php $(BASEURL_LOCAL)/handlezip.php 




