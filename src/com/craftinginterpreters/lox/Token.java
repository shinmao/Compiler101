package com.craftinginterpreters.lox;

public class Token {
	final TokenType type;
	// lexeme is the substring unit we identify as a token
	final String lexeme;
	// literals can be identifier, number or string
	final Object literal;
	// in error handling, we would like to show location in report
	final int line;
	
	Token(TokenType type, String lexeme, Object literal, int line) {
		this.type = type;
		this.lexeme = lexeme;
		this.literal = literal;
		this.line = line;
	}
	
	public String toString() {
		return type + " " + lexeme + " " + literal + " at line: " + String.valueOf(line);
	}
}
