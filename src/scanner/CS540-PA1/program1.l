%{
#include <stdio.h>
#include <string.h>

int charCount = 0;
// 1 means the first line of paragraph, while 0 means not
int startParagh = 1;
// 0 means currently not in list, while 1 means in list
int liststate = 0;
// 0 means previous is not start sign, this status is only used for list case
int prevstar = 0;
// 0 means previous word is not blank
int prevBlank = 0;
// 1 means previous line is blank, 0 means there is still no any blank line previously
int prevBlkLine = 1;      // we don't need to add blank line at first
// hyidx shows the index of hyphen in string
int hyidx = 0;
%}

word [A-Za-z0-9]+
startsym [("']
endsym [.?!;,:)"']
withinsym [@.']
allsym [()"'.?!;,:@]
wd {startsym}*{word}{withinsym}*{word}{endsym}*
singlewd {startsym}*{word}{endsym}*
blank [ ]+
blankline [ \t]*\n
%%
{wd}\-{wd}	{ return 1; }
{wd}|{singlewd}	{ charCount += yyleng; return 2; }
{allsym}	{ charCount += yyleng; return 2; }
^\*	{ return 7; }
%[^\n]*	{ return 8; }
\n{blankline}+	{ return 3; }
\n	{ return 4; }
{blank}	{ return 5; }
.	{ return 6; }
%%


int main(int argc, char *argv[]) {
	int rule;
	while(rule = yylex()) {
		switch(rule) {
			case 1:
				//printf("(1)");
				if(startParagh == 1 && liststate == 0) {
					charCount += 5;
					printf("     ");
					startParagh = 0;
				}
				hyidx = strstr(yytext, "-") - yytext;
				if(charCount + yyleng <= 60) {
					charCount += yyleng;
					printf("%s", yytext);
				}else if(charCount + hyidx + 1 <= 60) {
					printf("%.*s", hyidx + 1, yytext);
					charCount = yyleng - 1 - hyidx;
					printf("\n%s", yytext + hyidx + 1);
				}else if(charCount + yyleng > 60) {
					charCount = yyleng;
					printf("\n%s", yytext);
				}
				prevBlank = 0;
				break;
			case 2:
				//printf("(2)");
				//printf("%d", charCount);
				if(liststate == 1) {
					// current word is in list item
					if(prevstar == 1 && prevBlank == 0) {
						// if current word is start of the list, then we should add blank first
						charCount++;
						printf(" ");
						prevstar = 0;
					}

					if(charCount < 60) {
						printf("%s", yytext);
						prevBlank = 0;
					} else if(charCount == 60) {
						charCount = 7;
						printf("%s\n       ", yytext);
						prevBlank = 1;
					} else {
						charCount = yyleng + 7;
						printf("\n       %s", yytext);
						prevBlank = 0;
					}
				} else {
					if(startParagh == 1) {
						charCount += 5;
						printf("     ");
						startParagh = 0;
					}
					if(charCount > 60) {
						charCount = yyleng;
						printf("\n%s", yytext);
					}else if(charCount <= 60) {
						printf("%s", yytext);
					}
					prevBlank = 0;
				}
				break;
			case 3:
				//printf("(3)");
				charCount = 0;
				printf("\n\n");
				startParagh = 1;
				liststate = 0;
				prevBlkLine = 1;
				break;
			case 4:
				//printf("(4)");
				// if in list
				if(liststate == 1) {
					// EOL should be the end of list
					printf("\n");
					liststate = 0;
					prevBlkLine = 0;
				}else if(prevBlank != 1) {
					charCount++;
					printf(" ");
					prevBlank = 1;
				}
				break;
			case 5:
				//printf("(5)");
				//printf("%d", charCount);
				if(charCount + 1 > 60) {
					charCount = 0;
					printf("\n");
				}else if(charCount + 1 <= 60) {
					// if prev is not blank, then we should add one more blank before adding word
					if(prevBlank != 1) {
						charCount++;
						printf(" ");
					}
				}
				prevBlank = 1;
				break;
			case 6:
				//printf("(6)");
				// remove unlisted symbols
				if(prevBlank != 1) {
					// if prev is not blank, then just discard it
					charCount++;
					printf(" ");
					prevBlank = 1;
				}else if(prevBlank == 1) {
					// if prev is blank, duplicate space would happens if next is also blank
					// don't worry, it would go to case 5
				}
				break;
			case 7:
				if(prevBlkLine == 1) {
					printf("     *");
				} else {
					printf("\n     *");
				}
				// start list
				liststate = 1;
				prevstar = 1;
				prevBlank = 0;
				charCount = 6;
				break;
			case 8:
				//printf("(8)");
				// remove anything start from % to one character before EOL
				break;
			default:
				printf("Not found");
		}
	}
	return 0;
}
