## Introduction
The purpose of this project is to do semantic analysis on programming language MinLisp, and it can be separated to three tasks. There are specific features about MinLisp our parser needs to fulfill. But the most important part in this project is to do scope and type checking based on symbol table.

## User guide
Use `make` command in the root directory will generate parser with name `mlparser`.  
To parse the input file,
```
./mlparser < inputfile
```

## Firsk task: parse the program
Return token in `lexer.l` and parse the program with yacc in `ml.y`. Parser should tell us whether the program has any syntactic error.

## Figure out what is yacc
```yacc
%{
// header
%}
// ARR is the token received from lexer
%token ARR

// define the type of token
%union
{
    int type;
}

// which means we would receive this token as an integer in yacc
%type <type> ARR;

%%
// start yacc
// left handside should be non-terminal with lowercase letters
// while right handside can consist of non-terminal and terminal(with uppercase)
// following grammar means that expr can be transferred to NUM or LP ARR ID NUM RP
// we can use {action} to separate the single grammar
// $$ means the value of LHS, which is expr in this case
// RHS starts from $N depends on the Nth position
expr: NUM
    {
        $$ = 1;
    }
    | LP ARR
    {
        // after LP and ARR are parsed
        // expr value is assigned as value of ARR, which is defined as integer on above
        $$ = $2;
    }
    ID
    {
        // after LP, ARR, ID are parsed
        // Here is a tricky place
        // How to get the value of ID?
        // NOTICE: action would also count for one position, which means
        // $3 means the codeblock which include {$$ = $2;}
        // therefore, $4 represents ID!
        $$ = $4;
    }
    NUM RP
    {
        // after everything is parsed
    }
    ;

%%

int main() {
    // use yyparse to start parsing
    yyparse();
}

// yyerror would be triggered when the yacc grammar above cannot parse the input
// in other words, syntax error
void yyerror(char *s) {
    cout << "Error";
}
```

## Second task: scope checking with symbol table
In this task, I need to implement the data structure of symbol table and do scope checking based on it.

## Third task: type checking with symbol table
In this task, I need to do type checking based on symbol table previously built.