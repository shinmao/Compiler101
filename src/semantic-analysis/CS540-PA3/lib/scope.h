#include <iostream>
#include <string>
#include <vector>
#include "symtab.h"

using namespace std;

class Scope {
public:
	vector<Symtab> scope_stack;
	Scope() {}
	virtual ~Scope() {}
	void enter_new_scope();
	void leave_cur_scope();
	Symtab ret_cur_scope();
	void add_func_to_gtable(string name, string type, string ret_type, int argc);
	void add_symbol_to_gtable(string name, string type, int argc);
	void add_symbol_to_cur_table(string name, string type, int argc);
	bool check_dup(string name, string type);
	bool check_undefined(string name, string type);
	bool check_arr_index(string name, int index);
	string check_type(string name);
	string check_ret_type(string name);
	void assign_ret_type(string name, string type);
	bool check_actual_list_num(string name, int actual_cnt);
	void print_all_scopes();
};
