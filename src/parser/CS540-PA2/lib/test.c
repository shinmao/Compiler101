#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "dict.h"

int print(char **state) {
	for(int i = 0; i < 10; i++) {
		if(state[i] != NULL)
			printf("%s\n", state[i]);
	}
	printf("\n");
}

int main() {
	char* str = "abb";
	Dictionary* d = Dictionary_new();
	
	Dictionary_put(d, "A1", "a", "A1");
	Dictionary_put(d, "A2", "b", "A3");
	Dictionary_put(d, "A1", "a", "A3");
	Dictionary_put(d, "A1", "b", "A0");
	Dictionary_put(d, "A2", "b", "A1");
	
	char* new = (char*)malloc(sizeof(char)*2);
	char **state = Dictionary_get(d, "A1", strncpy(new, &str[0], 1));
	print(state);

	return 0;
}
