%{
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"
%}

lower [a-z]
alnum [A-Za-z0-9]

%%
{lower}	{ return T; }
[A-Z]+{alnum}*	{ return NT; }
->	{ return ARROW; }
[ \t]	;
\n	{ return EOL; }
%%
