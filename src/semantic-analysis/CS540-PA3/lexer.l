%{
#include <iostream>
#include "ml.tab.h"

using namespace std;

// start from first line
int lineno = 1;
%}

%%
[#][^\n]*[\n]	{ lineno++; }
array	{ return ARR; }
seq	{ return SEQ; }
define	{ return DEF; }
if	{ return IF; }
while	{ return WHILE; }
write	{ return WRITE; }
writeln	{ return WRITELN; }
read	{ return READ; }
and	{ return AND; }
or	{ return OR; }
not	{ return NOT; }
set	{ return SET; }
let	{ return LET; }
true	{ return TR; }
false	{ return FAL; }
main    { return MAIN_NAME; }
\(	{ return LP; }
\)	{ return RP; }
\+	{ return '+'; }
\-	{ return '-'; }
\*	{ return '*'; }
\/	{ return '/'; }
\<	{ return '<'; }
\<\=	{ return LE; }
\<\>	{ return NE; }
\>	{ return '>'; }
\>\=	{ return GE; }
\=	{ return '='; }
\[	{ return LB; }
\]	{ return RB; }
\&	{ return AMP; }
\|	{ return '|'; }
\!	{ return '!'; }
[1-9]+[0-9]*	{ return NUM; }
[0]	{ return NUM; }
[A-Za-z][A-Za-z0-9_]*	{ yylval.str = strdup(yytext); return ID; }
[\n]	{ lineno++; }
[ \t]	{ ; }
.	{ ; }
%%
