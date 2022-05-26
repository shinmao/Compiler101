#include <iostream>
#include <string>
#include <unordered_map>

using namespace std;

class Symbol {
public:
	string type;
	string ret_type;
	int argc;
	Symbol() {};
};

class Symtab {
public:
	unordered_map<string, Symbol> symbol_table;
	Symtab() {}
	virtual ~Symtab() {}
	void scope_add_func(string name, string type, string ret_type, int argc);
	void scope_add_others(string name, string type, int argc);
	Symbol search_symbol_by_name(string name);
	void print_symtab();
};
