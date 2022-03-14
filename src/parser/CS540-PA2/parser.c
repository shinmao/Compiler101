#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "lib/dict.h"

extern char *yytext;
extern int yylex();
int lookahead;
int prod_cnt = 0;
// start state and final state
Dictionary* state_dict;
char* start;
char* final;
// point to the index of current parsed str
int parsed_idx = 0;
char** parsed;

void input(), gram(), gram_p(), prod(), prod_p(char* lhs_state), strs(), strs_p(), str(), str_p();
void match(int token, int validated_str), error(char *where);
int nfa();

int main() {
	state_dict = Dictionary_new();
	parsed = (char**)malloc(sizeof(char*)*100);
	parsed[0] = malloc(sizeof(char)*255);
	lookahead = yylex();
	input();
	/**
	if (lookahead == 0) {
		printf("accepted\n");
	} else {
		printf("The grammar for input file might be wrong\n");
		return 0;
	}**/
	//printf("Start state: %s, Final state: %s\n", start, final);
	// print NFA table
	//Dictionary_print(state_dict);
	for(int i = 0; i < parsed_idx; i++) {
		if(nfa(start, parsed[i], 0, strlen(parsed[i])) == 0) {
			printf("Accept %s\n", parsed[i]);
		}else {
			printf("Reject %s\n", parsed[i]);
		}
	}
	return 0;
}

/* return 0 for accept
 * return 1 for reject
 */
int nfa(char* cur_state, char* input_str, int cur_idx, int input_strlen) {
	if( (cur_idx == input_strlen) && strcmp(cur_state, final) == 0)
		return 0;
	if( (cur_idx == input_strlen) && strcmp(cur_state, final) != 0)
		return 1;
	
	char* input_char = (char*)malloc(sizeof(char)*2);
	char** trans1 = Dictionary_get(state_dict, cur_state, strncpy(input_char, &input_str[cur_idx], 1));
	if(trans1 != NULL){
		/**
		int c = 0;
		char* t = trans1[c];
		while(trans1[c]) {
			if(nfa(trans1[c], input_str, cur_idx + 1, input_strlen) == 0)
				return 0;
		}**/

		for(int i = 0; i < 10; i++) {
			char* next = trans1[i];
			if(next != NULL) {
				if(nfa(next, input_str, cur_idx + 1, input_strlen) == 0)
					return 0;
			}
		}
	}
	
	char** trans2 = Dictionary_get(state_dict, cur_state, "ep");
	if(trans2 == NULL) {
		return 1;
	}
	for(int i = 0; i < 10; i++) {
		char* next = trans2[i];
		if(next != NULL) {
			if(nfa(next, input_str, cur_idx, input_strlen) == 0)
				return 0;
		}
	}

	return 1;
}

// second argument: validated_str
// if value is 1, then the matched str should be the one we want to validate
void match(int token, int validated_str) {
	if(token == lookahead) {
		if(validated_str == 0) {
			// production should be started with NT and ARROW
			//printf(yytext);
		}else {
			if(token == EOL) {
				parsed_idx++;
				parsed[parsed_idx] = malloc(sizeof(char)*255);
			}else {
				strcat(parsed[parsed_idx], yytext);
			}
		}

		lookahead = yylex();
	} else {
		error("match");
	}
}

void error(char *where) {
	//printf("Syntax error line %s\n", where);
	//printf("Token seen: %d\n", lookahead);
	exit(10);
}

void input() {
	if(lookahead == NT) {
		gram();
		strs();
	} else {
		error("input");
	}
}

void gram() {
	if(lookahead == NT) {
		prod();
		gram_p();
	}else {
		error("gram");
	}
}

void gram_p() {
	if(lookahead == NT) {
		prod();
		gram_p();
	}else if(lookahead == T || lookahead == EOL) {
		return;
	}
}

void prod() {
	if(lookahead == NT) {
		char* lhs = (char*)malloc(sizeof(char)*10);

		strcpy(lhs, yytext);
		match(NT, 0);
		
		match(ARROW, 0);
		
		prod_p(lhs);
	}else {
		return;
	}
}

void prod_p(char* lhs_state) {
	if(lookahead == T) {
		// lhs -> T NT
		char* T_str = (char*)malloc(sizeof(char)*1);
		char* NT_str = (char*)malloc(sizeof(char)*10);

		strcpy(T_str, yytext);
		match(T, 0);
		strcpy(NT_str, yytext);
		match(NT, 0);

		if(prod_cnt == 0) {
			start = (char*)malloc(sizeof(char)*10);
			strcpy(start, lhs_state);
		}

		Dictionary_put(state_dict, lhs_state, T_str, NT_str);
		prod_cnt++;
		match(EOL, 0);
	} else if(lookahead == NT) {
		// lhs -> NT
		char* NT_str = (char*)malloc(sizeof(char)*10);
		
		strcpy(NT_str, yytext);
		match(NT, 0);

		if(prod_cnt == 0) {
			start = (char*)malloc(sizeof(char)*10);
			strcpy(start, lhs_state);
		}
		
		Dictionary_put(state_dict, lhs_state, "ep", NT_str);
		prod_cnt++;
		match(EOL, 0);
	} else if(lookahead == EOL) {
		// find the final state
		final = (char*)malloc(sizeof(char)*10);
		strcpy(final, lhs_state);
		//printf(final);
		prod_cnt++;
		match(EOL, 0);
	}
}

void strs() {
	if(lookahead == T || lookahead == EOL) {
		str();
		match(EOL, 1);
		strs_p();
	}else {
		error("strs");
	}
}

void strs_p() {
	if(lookahead == T || lookahead == EOL) {
		str();
		match(EOL, 1);
		strs_p();
	}else if(lookahead == 0) {
		// what should i do for epislon
		return;
	}
}

void str() {
	if(lookahead == T || lookahead == EOL) {
		str_p();
	}else {
		error("str");
	}
}

void str_p() {
	if(lookahead == T) {
		match(T, 1);
		str_p();
	} else if(lookahead == EOL) {
		// what should i do for epislon
		return;
	}
}

