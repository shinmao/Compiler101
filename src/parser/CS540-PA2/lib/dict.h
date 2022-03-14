#include "node.h"

#ifndef DICTIONARY_H
#define DICTIONARY_H

#define DICT_SIZE 501

typedef struct Nxt_state {
    // receive input of terminal
    char *key;
    // transition to NT state
    char** nxt;
    struct Nxt_state *next;
} Nxt_state;

typedef struct Entry {
    char *key;
    unsigned size;
    Nxt_state *table[DICT_SIZE];
    struct Entry *next;
} Entry;

typedef struct Dictionary {
    unsigned size;
    Entry *table[DICT_SIZE];
} Dictionary;

extern Dictionary* Dictionary_new();
extern char** Dictionary_get(Dictionary *d, char *key, char *value);
extern void Dictionary_put(Dictionary *d, char *key, char *value, char *value2);
extern void Dictionary_print(Dictionary *d);

#endif
