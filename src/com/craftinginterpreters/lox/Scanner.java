// lex, flex also give you a completed scanner
// but here we want to implement scanner by ourselves
package com.craftinginterpreters.lox;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// import static can help us not need to type package for each time
// but there might be a name conflict
import static com.craftinginterpreters.lox.TokenType.*;

public class Scanner {
	private static final Map<String, TokenType> keywords;
	
	static {
		keywords = new HashMap<>();
		keywords.put("and",    AND);
	    keywords.put("class",  CLASS);
	    keywords.put("else",   ELSE);
	    keywords.put("false",  FALSE);
	    keywords.put("for",    FOR);
	    keywords.put("fun",    FUN);
	    keywords.put("if",     IF);
	    keywords.put("nil",    NIL);
	    keywords.put("or",     OR);
	    keywords.put("print",  PRINT);
	    keywords.put("return", RETURN);
	    keywords.put("super",  SUPER);
	    keywords.put("this",   THIS);
	    keywords.put("true",   TRUE);
	    keywords.put("var",    VAR);
	    keywords.put("while",  WHILE);
	}
	
	private final String source;
	private final List<Token> tokens = new ArrayList<>();
	// start points to the first character in the lexeme being scanned
	private int start = 0;
	// currently scanned on
	private int current = 0;
	private int line = 1;
	
	Scanner(String source) {
		this.source  = source;
	}
	
	List<Token> scanTokens() {
		// TODO Auto-generated method stub
		while (!isAtEnd()) {
			start = current;
			scanToken();
		}
		
		tokens.add(new Token(EOF, "", null, line));
		return tokens;
	}
	
	private void scanToken() {
		// advance can move pointer to the next char
		char c = advance();
		switch(c) {
		  case '(': addToken(LEFT_PAREN); break;
	      case ')': addToken(RIGHT_PAREN); break;
	      case '{': addToken(LEFT_BRACE); break;
	      case '}': addToken(RIGHT_BRACE); break;
	      case ',': addToken(COMMA); break;
	      case '.': addToken(DOT); break;
	      case '-': addToken(MINUS); break;
	      case '+': addToken(PLUS); break;
	      case ';': addToken(SEMICOLON); break;
	      case '*': addToken(STAR); break;
	      case '!':
	    	  addToken(advance_match('=')? BANG_EQUAL : BANG);
	    	  break;
	      case '=':
	    	  addToken(advance_match('=')? EQUAL_EQUAL : EQUAL);
	    	  break;
	      case '<':
	    	  addToken(advance_match('=')? LESS_EQUAL : LESS);
	    	  break;
	      case '>':
	    	  addToken(advance_match('=')? GREATER_EQUAL : GREATER);
	    	  break;
	      case '/':
	    	  // handle the case of comments
	    	  if(advance_match('/')) {
	    		  // read until the end of the line
	    		  while(lookahead() != '\n' && !isAtEnd()) advance();
	    	  } else {
	    		  addToken(SLASH);
	    	  }
	    	  break;
	      case ' ':
	      case '\r':
	      case '\t':
	    	  // ignore
	    	  break;
	      case '\n':
	    	  line++;
	    	  break;
	      case '"':   // case of string literal
	    	  scanStr();
	    	  break;
	      // in addition, we also should report error if no defined char
	      default:
	    	  if (isDigit(c)) {
	    		  number();
	    	  } else if (isAlpha(c)) {
	    		  identifier();
	    	  } else {
	    		  Lox.error(line,  "Unexpected character.");
	    	  }
	    	  break;
		}
	}
	
	private void identifier() {
		while (isAlphaNumeric(lookahead()))
			advance();
		
		// check whether the lexeme is keyword or not
		String text = source.substring(start, current);
		TokenType type = keywords.get(text);
		if (type == null)
			type = IDENTIFIER;
		addToken(type);
	}

	private boolean isAlphaNumeric(char c) {
		return isAlpha(c) || isDigit(c);
	}

	// identify the start letter of identifier
	private boolean isAlpha(char c) {
		return (c >= 'a' && c <= 'z') ||
				(c >= 'A' && c <= 'Z') ||
				c == '_';
	}

	// handle with number float point
	private void number() {
		while(isDigit(lookahead()))
			advance();
		
		// look for the part after .
		if(lookahead() == '.' && isDigit(looknxt())) {
			advance();
			
			while(isDigit(lookahead()))
				advance();
		}
		
		addToken(NUMBER, Double.parseDouble(source.substring(start, current)));
	}

	private char looknxt() {
		if(current + 1 >= source.length()) return '\0';
		return source.charAt(current + 1);
	}

	private boolean isDigit(char c) {
		return c >= '0' && c <= '9';
	}

	private void scanStr() {
		while(lookahead() != '"' && !isAtEnd()) {
			if(lookahead() == '\n') line++;
			advance();
		}
		
		if(isAtEnd()) {
			Lox.error(line, "string doesn't have terminated quote");
			return;
		}
		
		// point to the closing "
		advance();
		
		// the string inside the ""
		String value = source.substring(start + 1, current -1);
		addToken(STRING, value);
	}

	private boolean advance_match(char expected_char) {
		// e.g. the token less_equal is for '<='
		// first, at the case of '<', the current is already pointed to '=' in advance()
		if(isAtEnd()) return false;
		if(source.charAt(current) != expected_char) return false;
		current++;
		return true;
	}
	
	private char lookahead() {
		// lookahead
		if(isAtEnd()) return '\0';
		return source.charAt(current);
	}

	private char advance() {
		// get next character
		return source.charAt(current++);
	}
	
	private void addToken(TokenType type) {
		addToken(type, null);
	}
	
	private void addToken(TokenType type, Object literal) {
		// get lexeme = substring unit
		String text = source.substring(start, current);
		tokens.add(new Token(type, text, literal, line));
	}

	private boolean isAtEnd() {
		return current >= source.length();
	}
}
