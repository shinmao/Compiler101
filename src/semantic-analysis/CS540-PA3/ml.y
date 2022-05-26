%{
#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include "lib/scope.h"

using namespace std;

Scope scp;

// if true, need to check array out of bound
bool arr_ofb_check;
int arr_size;
int seq_cnt;
string cur_function;
bool recursive;

extern int yylex();
extern int lineno;
void yyerror(char *s);

/**
type information for expr
integer: 1
boolean: 0
**/
%}
%token ARR SEQ DEF IF WHILE WRITE WRITELN READ
%token AND OR NOT SET LET TR FAL
%token LE NE GE LP RP LB RB NUM ID MAIN_NAME AMP

%union
{
	int type;
	char *str;
}

%type <type> ARR SEQ DEF IF WHILE WRITE WRITELN READ
%type <type> AND OR NOT SET LET TR FAL
%type <type> LE NE GE LP RP LB RB AMP
%type <type> NUM
%type <str> ID MAIN_NAME

%type <type> param_list function expr expr_list actual_list id_list assign_list
%%

ml: arrays mainprogram
  ;
arrays: arrays array
      |
      ;
array: LP ARR ID NUM RP
	{
		// put array name into global scope
		if(scp.check_dup($3, "arr")) {
			cout << "Line " << lineno << ": " << $3 << " is already declared\n";
		}else {
			scp.add_symbol_to_gtable($3, "array", $4);
		}
	}
     ;
mainprogram: program main
	{ ; }
	| program
	{
		cout << "Line " << lineno << ": Last function must be main\n";
	}
	| program main program
	{
		cout << "Line " << lineno << ": Last function must be main\n";
	}
	;
main: LP DEF MAIN_NAME param_list expr RP
	;
program: program function
       | function
	;
function: LP DEF ID
	{ 
		if(scp.check_dup($3, "fun")) {
			cout << "Line " << lineno << ": " << $3 << " is already declared\n";
		}
		cur_function = $3;
		// enter local scope of function
		scp.enter_new_scope();
	}
	param_list
	{
		//cout << $5 << "\n";
		scp.add_func_to_gtable($3, "function", "", $5);
	}
	expr RP
	{
		// put function name into global scope
		if($7 == 0) {
			scp.assign_ret_type($3, "bool");
		} else if(recursive) {
			scp.assign_ret_type($3, "int");
		}else {
			scp.assign_ret_type($3, "int");
		}
		//scp.print_all_scopes();
		scp.leave_cur_scope();
		cur_function = "";
		recursive = false;
		$$ = $7;
	}
	;
param_list: LP RP
	{
		$$ = 0;
	}
	| LP id_list RP
	{
		$$ = $2;
	}
	;
id_list: id_list ID
	   {
		   // parameters for function
		   if(scp.check_dup($2, "param")) {
			   cout << "Line " << lineno << ": " << $2 << " is already declared\n";
		   }else{
				scp.add_symbol_to_cur_table($2, "int", 0);
		   }
		   $$ = $1 + 1;
	   }
       | ID
	   {
		   // parameters for function
		   if(scp.check_dup($1, "param")) {
			   cout << "Line " << lineno << ": " << $1 << " is already declared\n";
		   }else {
		   		scp.add_symbol_to_cur_table($1, "int", 0);
		   }
		   $$ = 1;
	   }
	;
expr: NUM
	{ 
		$$ = 1; 
	}
    | ID
	{
		if(scp.check_undefined($1, "var")) {
			cout << "Line " << lineno << ": " << $1 << " is undefined\n";
			$$ = 1;
		}else {
			// if defined, whether function or variable
			if(scp.check_type($1) == "array") {
				cout << "Line " << lineno << ": Array used incorrectly: " << $1 << "\n"; 
				$$ = 1;
			}else if(scp.check_type($1) == "function") {
				$$ = (scp.check_ret_type($1) == "int" ? 1 : 0);
			}else if(scp.check_type($1) == "bool") {
				$$ = 0;
			}else {
				$$ = 1;
			}
		}
	}
    | ID LB expr RB
	{
		// check array is declared or not
		if(scp.check_undefined($1, "arr")) {
			   cout << "Line " << lineno << ": " << $1 << " is undefined\n";
		}else {
			// check index out of bound or not
			
			// check whether index is integer
			if($3 != 1) {
				cout << "Line " << lineno << ": Index is not integer for Array " << $1 << "\n";
			}
		}
		// should be integer array
		$$ = 1;
	}
    | TR
	{ $$ = 0; }
    | FAL
	{ $$ = 0; }
    | LP IF expr expr expr RP
	{
		if($3 != 0) {
			cout << "Line " << lineno << ": The first expr of if expects a boolean type\n";
		}else if(!((($4 == 0) && ($5 == 0)) || (($4 == 1) && ($5 == 1)))) {
			cout << "Line " << lineno << ": Non-matching types used in if statements clauses\n";
		}
		$$ = $4;
	}
    | LP WHILE expr expr RP
	{
		if($3 != 0) {
			cout << "Line " << lineno << ": The first expr of while expects boolean type\n";
		}
		$$ = $4;
	}
    | LP ID actual_list
	{
		if($2 == cur_function) {
			// recursive
			recursive = true;
		}else if(scp.check_undefined($2, "fun")) {
			cout << "Line " << lineno << ": " << $2 << " is undefined\n";
		}
	}
	RP
	{
		//cout << "actual cnt: " << $3 << "\n";
		//cout << "func cnt: " << scp.scope_stack.front().search_symbol_by_name($2).argc << "\n";
		if(!scp.check_undefined($2, "fun") && !scp.check_actual_list_num($2, $3)){
			// check actual_list matches number of parameters?
			cout << "Line " << lineno << ": " << $2 << " count of parameters passed in not correct\n";
		}
		if(scp.check_ret_type($2) == "bool") {
			$$ = 0;
		}else {
			$$ = 1;
		}
	}
    | LP WRITE expr RP
	{
		if($3 != 1) {
			cout << "Line " << lineno << ": write expects an integer expression\n";
		}
		$$ = 1;
	}
    | LP WRITELN expr RP
	{
		if($3 != 1) {
			cout << "Line " << lineno << ": writeln expects an integer expression\n";
		}
		$$ = 1;
	}
    | LP READ RP
	{
		$$ = 1;
	}
    | LP LET
	{
		// new scope for let
		scp.enter_new_scope();
	}
	LP assign_list RP expr
	{ ; }
	RP
	{
		$$ = 1;
		scp.leave_cur_scope();
	}
    | LP SET ID expr RP
	{
		// assign int/bool to variable, this variable can only be parameters?
		if(!scp.check_undefined($3, "var")) {
			if(($4 == 1) && (scp.check_type($3) == "int")) {
				// this is valid
			}else if(($4 == 0) && (scp.check_type($3) == "bool")) {
				// this is valid
			}else {
				cout << "Line " << lineno << ": Type mismatch in set statement\n";
			}
		}else {
			cout << "Line " << lineno << ": Undeclared variable " << $3 << "\n";
		}
		// overall type of expr
		$$ = $4;
	}
    | LP SET ID LB expr RB expr RP
	{
		// check whether array is declared
		if(scp.check_undefined($3, "arr")) {
			cout << "Line " << lineno << ": Undeclared array name " << $3 << "\n";
		}else if($5 != 1) {
			// check whether index not integer
			cout << "Line " << lineno << ": Index is not integer for Array " << $3 << "\n";
		}else if($7 != 1) {
			cout << "Line " << lineno << ": Integer value should be assigned to elements of array " << $3 << "\n";
		}
		// overall type of expr
		$$ = $7;
	}
    | LP '=' expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": = expects integer as operands\n";
		}
		$$ = 0;
	}
    | LP '<' expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": < expects integer as operands\n";
		}
		$$ = 0;
	}
    | LP '>' expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": > expects integer as operands\n";
		}
		$$ = 0;
	}
    | LP LE expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": <= expects integer as operands\n";
		}
		$$ = 0;
	}
    | LP GE expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": >= expects integer as operands\n";
		}
		$$ = 0;
	}
    | LP NE expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": <> expects integer as operands\n";
		}
		$$ = 0;
	}
    | LP '+' expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": + expects integer as operands\n";
		}
		$$ = 1;
	}
    | LP '-' expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": - expects integer as operands\n";
		}
		$$ = 1;
	}
    | LP '-' expr RP
	{
		if($3 != 1) {
			cout << "Line " << lineno << ": Negation expects integer as operand\n";
		}
		$$ = 1;
	}
    | LP '*' expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": * expects integer as operands\n";
		}
		$$ = 1;
	}
    | LP '/' expr expr RP
	{
		if(($3 != 1) || ($4 != 1)) {
			cout << "Line " << lineno << ": / expects integer as operands\n";
		}
		$$ = 1;
	}
    | LP AND expr expr RP
	{
		if(($3 != 0) || ($4 != 0)) {
			cout << "Line " << lineno << ": & expects boolean as operands\n";
		}
		$$ = 0;
	}
    | LP AMP expr expr RP
	{
		if(($3 != 0) || ($4 != 0)) {
			cout << "Line " << lineno << ": and expects boolean as operands\n";
		}
		$$ = 0;
	}
    | LP OR expr expr RP
	{
		if(($3 != 0) || ($4 != 0)) {
			cout << "Line " << lineno << ": or expects boolean as operands\n";
		}
		$$ = 0;
	}
    | LP '|' expr expr RP
	{
		if(($3 != 0) || ($4 != 0)) {
			cout << "Line " << lineno << ": | expects boolean as operands\n";
		}
		$$ = 0;
	}
    | LP NOT expr RP
	{
		if($3 != 0) {
			cout << "Line " << lineno << ": not expects boolean as operands\n";
		}
		$$ = 0;
	}
    | LP '!' expr RP
	{
		if($3 != 0) {
			cout << "Line " << lineno << ": ! expects boolean as operands\n";
		}
		$$ = 0;
	}
    | LP SEQ expr_list 
	{ ; }
	RP
	{ 
		seq_cnt = 0;
		$$ = $3;
	}
	;
actual_list: actual_list expr
		{
			// expr is the parameter for function
			// check whether expr is integer type
			if($2 != 1) {
				cout << "Line " << lineno << ": function needs parameters of integer type\n";
			}
			$$ = $1 + 1;
		}
	   |
	   {
		   $$ = 0;
	   }
		;
assign_list: assign_list LP ID expr RP
		{
			if(scp.check_dup($3, "var")) {
				cout << "Line " << lineno << ": " << $3 << " is already declared\n";
			}
			if($4 == 1) {
				scp.add_symbol_to_cur_table($3, "int", 0);
			}else if($4 == 0) {
				scp.add_symbol_to_cur_table($3, "bool", 0);
			}
		}
	   | LP ID expr RP
	   {
		   if(scp.check_dup($2, "var")) {
				cout << "Line " << lineno << ": " << $3 << " is already declared\n";
			}
			if($3 == 1) {
				scp.add_symbol_to_cur_table($2, "int", 0);
			}else if($3 == 0) {
				scp.add_symbol_to_cur_table($2, "bool", 0);
			}
	   }
		;
expr_list: expr_list expr
	{
		seq_cnt += 1;
		if(seq_cnt == 1) {
			// the rightmost expression
			$$ = $2;
		}
	}
	 | expr
	 {
		 seq_cnt += 1;
		 if(seq_cnt == 1) {
			 // the rightmost expression
			 $$ = $1;
		 }
	 }
	;

%%

int main() {
	// initialize flag
	arr_ofb_check = false;
	arr_size = 0;
	seq_cnt = 0;
	recursive = false;

	// global scope
	scp.enter_new_scope();

	yyparse(); 
	return 0; 
}

void yyerror(char *s) {
	cout << "Error: " << s << " at line: " << lineno << endl;
}
