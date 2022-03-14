pa2: lex.yy.c lib/dict.c parser.c tokens.h
	gcc -g -o pa2 parser.c lex.yy.c lib/dict.c -ll

lex.yy.c:	lexer.l
	flex lexer.l
