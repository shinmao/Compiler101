#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "dict.h"

/*
 * Hash function for hashing a string to an integer value
 *
 * Modified version of the djb2 hash function by Dan Bernstein
 * (http://www.cse.yorku.ca/~oz/hash.html)
 *
 * Limits the range of output to between (0, DICT_SIZE)
 */
unsigned hash_string(unsigned char *str) {
    unsigned hash = 5381;
    int c;
 
    while ((c = (*str++)))
        hash = ((hash << 5) + hash) + c;
 
    return hash % DICT_SIZE;
}

/*
 * Create and return a new Nxt_state object
 */
Nxt_state* Nxt_state_create(char *key) {
	Nxt_state *ns = malloc(sizeof(Nxt_state));
	ns->key = key;
	ns->nxt = (char**)malloc(sizeof(char*)*10);
	ns->next = NULL;
	return ns;
}

/*
 * Create and return a new Entry object
 */
Entry* Entry_create(char *key) {
    Entry *e = malloc(sizeof(Entry));
    e->key = key;
    for(int i = 0; i < DICT_SIZE; i++)
	    e->table[i] = NULL;
    e->next = NULL;
    return e;
}

/**********************************************************
 * Public Interface
 *********************************************************/

/*
 * Create and return a new object for Entry
 */
Dictionary* Dictionary_new() {
    Dictionary *d = malloc(sizeof(Dictionary));
    for (int i = 0; i < DICT_SIZE; i++)
        d->table[i] = NULL;
    return d;
}

/*
 * Bind value to a given key in the dictionary
 */
void Dictionary_put(Dictionary *d, char *key, char *value, char *value2) {
    assert(d);
    unsigned hash = hash_string((unsigned char *) key);
    unsigned hash2 = hash_string((unsigned char *) value);

    if (!d->table[hash]) {
	// key not exists
	Entry *e = Entry_create(key);
	Nxt_state *nxt_st = Nxt_state_create(value);
	nxt_st->nxt[0] = malloc(sizeof(char)*10);
	strcpy(nxt_st->nxt[0], value2);
	e->table[hash2] = nxt_st;
        d->table[hash] = e;
        return;
    }
    
    // if the entry key already exists
    for (Entry *i = d->table[hash]; i; i = i->next) {
        if (strcmp(key, i->key) == 0) {
	    // find the entry
	    
	    if(!i->table[hash2]) {
		    // T still not exists in key
		    Nxt_state *nxt_st = Nxt_state_create(value);
		    nxt_st->nxt[0] = malloc(sizeof(char)*10);
		    strcpy(nxt_st->nxt[0], value2);
		    i->table[hash2] = nxt_st;
		    return;
	    }
	    
	    // if T already exists in key
	    for(Nxt_state *j = i->table[hash2]; j; j = j->next) {
		    if(strcmp(value, j->key) == 0) {
			    for(int k = 0; k < 10; k++) {
				if(j->nxt[k] == NULL) {
					j->nxt[k] = malloc(sizeof(char)*10);
					strcpy(j->nxt[k], value2);
					break;
				}
			    }
			    return;
		    }
		    if(j->next == NULL) {
			    j->next = Nxt_state_create(value);
			    return;
		    }
	    }
	    return;
        }
        if (i->next == NULL) {
            i->next = Entry_create(key);
            return;
        }        
    }

}

/*
 * Get and return the string array (nxt) stored at
 * a given key
 *
 * Returns NULL if key is not found
 */
char** Dictionary_get(Dictionary *d, char *key, char *value) {
    assert(d);
    unsigned hash = hash_string((unsigned char *) key);
    unsigned hash2 = hash_string((unsigned char *) value);
    for (Entry *i = d->table[hash]; i; i = i->next) {
        if (strcmp(key, i->key) == 0) {
		for (Nxt_state *j = i->table[hash2]; j; j->next) {
			if(strcmp(value, j->key) == 0)
				return j->nxt;
		}
	}else {
		printf("%s not found in Entry\n", key);
	}
    }
    return NULL;
}

/*
 * print out whole dictionary table
 */
void Dictionary_print(Dictionary *d) {
    for(int i = 0; i < DICT_SIZE; i++) {
	    if(d->table[i]) {
		    Entry *e = d->table[i];
		    printf("%s ", e->key);
		    for(int j = 0; j < DICT_SIZE; j++) {
			    if(e->table[j]) {
				Nxt_state *ns = e->table[j];
				printf("with %s ", ns->key);
				for(int k = 0; k < 10; k++) {
					if(ns->nxt[k] != NULL)
						printf("->%s ", ns->nxt[k]);
				}
			    }
		    }
		    printf("\n");
	    }
    }
}
