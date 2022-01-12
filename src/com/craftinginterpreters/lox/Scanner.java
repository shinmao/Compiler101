// lex, flex also give you a completed scanner
// but here we want to implement scanner by ourselves
package com.craftinginterpreters.lox;

import java.util.ArrayList;
import java.util.List;

// import static can help us not need to type package for each time
// but there might be a name conflict
import static com.craftinginterpreters.lox.TokenType.*;

public class Scanner {
	private final String source;
	private final List<Token> tokens = new ArrayList<>();
	private int start = 0;
	private int current = 0;
	private int line = 1;
	
	Scanner(String source) {
		this.source  = source;
	}
	
	List<Token> scanTokens() {
		// TODO Auto-generated method stub
		while (!isAtEnd()) {
			start = current;
			scanTokens();
		}
		
		tokens.add(new Token(EOF, "", null, line));
		return tokens;
	}

	private boolean isAtEnd() {
		return current >= source.length();
	}
}
