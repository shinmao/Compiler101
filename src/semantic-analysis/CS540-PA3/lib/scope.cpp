#include <iostream>
#include <string>
#include <vector>
#include "scope.h"

using namespace std;

void Scope::enter_new_scope() {
	Symtab symbol_table;
	scope_stack.push_back(symbol_table);
}

// should be called following enter_new_scope when leaving the current scope
void Scope::leave_cur_scope() {
	scope_stack.pop_back();
}

Symtab Scope::ret_cur_scope() {
	return scope_stack.back();	
}

void Scope::add_func_to_gtable(string name, string type, string ret_type, int argc) {
	Symtab stable = scope_stack.front();
	stable.scope_add_func(name, type, ret_type, argc);
	scope_stack.front() = stable;
}

void Scope::add_symbol_to_gtable(string name, string type, int argc) {
	Symtab stable = scope_stack.front();
	stable.scope_add_others(name, type, argc);
	scope_stack.front() = stable;
}

// add symbol to the current symbol table which is at the top of stack
void Scope::add_symbol_to_cur_table(string name, string type, int argc) {
	// get cur symbol table
	Symtab stable = scope_stack.back();
    stable.scope_add_others(name, type, argc);
	// update cur scope symbol table
	scope_stack.back() = stable;
}

// when declare, check dup
bool Scope::check_dup(string name, string type) {
	// return true if dup
	if(type == "fun" || type == "arr") {
		// check function or array
		return (scope_stack.front().symbol_table.count(name) != 0);
	}else {
		// check others
		return (scope_stack.back().symbol_table.count(name) != 0);
	}
	return false;
}

// when call, check whether it is defined
bool Scope::check_undefined(string name, string type) {
	// return true if undefined
	if(type == "fun" || type == "arr") {
		// check function or array
		return (scope_stack.front().symbol_table.count(name) == 0);
	}else {
		// check others
		for(auto it = scope_stack.rbegin(); it != scope_stack.rend(); ++it) {
			if(it->symbol_table.count(name) != 0)
				return false;
		}
		return true;
	}
	return false;
}

// check whether the index of arr is out of bound or not
bool Scope::check_arr_index(string name, int index) {
	// return true if out of bound
	return (index >= scope_stack.front().search_symbol_by_name(name).argc);
}


// check type for variable if defined
string Scope::check_type(string name) {
	for(auto it = scope_stack.rbegin(); it != scope_stack.rend(); ++it) {
		if(it->symbol_table.count(name) != 0)
			return it->search_symbol_by_name(name).type;
	}
	return "int";
}

// check ret type for function
string Scope::check_ret_type(string name) {
	// return int or bool
	return (scope_stack.front().search_symbol_by_name(name).ret_type);
}

// assign ret type to function
void Scope::assign_ret_type(string name, string type) {
	Symtab stable = scope_stack.front();
	stable.search_symbol_by_name(name).ret_type = type;
	scope_stack.front() = stable;
}

// check whether parameters count match
bool Scope::check_actual_list_num(string name, int actual_cnt) {
	// return true if match
	return (actual_cnt == scope_stack.front().search_symbol_by_name(name).argc);
}

// try to print information from all scopes
void Scope::print_all_scopes() {
	// start from top of the stack
	for(auto it = scope_stack.rbegin(); it != scope_stack.rend(); ++it) {
		cout << "===================\n";
		it->print_symtab();
	}
}
