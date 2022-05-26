all: parser

parser: ml.tab.c lex.yy.c
	g++ -x c++ -o mlparser ml.tab.c lex.yy.c lib/scope.cpp lib/symtab.cpp -ly -ll

ml.tab.c:
	bison -vd ml.y

lexer: lex.yy.c
	g++ lex.yy.c -ll

lex.yy.c:
	flex lexer.l

clean:
	rm lex.yy.c ml.output ml.tab.c ml.tab.h mlparser
