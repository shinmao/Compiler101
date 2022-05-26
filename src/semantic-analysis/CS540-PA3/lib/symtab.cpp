#include <iostream>
#include <string>
#include <unordered_map>
#include "symtab.h"

using namespace std;

/**
The name is just a joke
now this symbol table can be used for all types
function: { type: "function", argc: argc }
array: { type: "array", argc: size }
variable: { type: "int/bool", argc: 0 }
**/
void Symtab::scope_add_func(string name, string type, string ret_type, int argc) {
	Symbol sym;
	sym.type = type;
	sym.ret_type = ret_type;
	sym.argc = argc;
	symbol_table[name] = sym;
}

void Symtab::scope_add_others(string name, string type, int argc) {
	Symbol sym;
	sym.type = type;
	sym.ret_type = "";
	sym.argc = argc;
	symbol_table[name] = sym;
}

// search in current symbol table
Symbol Symtab::search_symbol_by_name(string name) {
	return symbol_table[name];
}

// print current symbol table
void Symtab::print_symtab() {
	for(auto it = symbol_table.begin(); it != symbol_table.end(); ++it) {
		cout << "Name: " << it->first << "\n";
		cout << "Type: " << it->second.type << "\n";
		cout << "argc: " << it->second.argc << "\n";
	}
}
