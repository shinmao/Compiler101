#include <iostream>
#include <string.h>
#include <assert.h>
#include "scope.h"

using namespace std;

int main() {
	// scope can point to 
	Scope scope;
	scope.enter_new_scope();
	scope.add_symbol_to_cur_table("func1", "function", 4);
	scope.add_symbol_to_cur_table("func2", "function", 0);
	scope.enter_new_scope();
	scope.add_symbol_to_cur_table("func10", "function", 0);
	scope.add_symbol_to_cur_table("func11", "function", 1);
	scope.print_all_scopes();
	scope.leave_cur_scope();
	scope.leave_cur_scope();
	return 0;
}
