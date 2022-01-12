package com.craftinginterpreters.lox;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.charset.Charset;
import java.util.List;

public class Lox {
	static boolean hadError = false;
	
	public static void main(String[] args) throws IOException {
		if (args.length > 1) {
			System.out.println("Usage: jlox [script]");
			System.exit(64);
		} else if (args.length == 1) {
			runFile(args[0]);
		} else {
			runPrompt();
		}
	}

	private static void runPrompt() throws IOException {
		// pop up an interactive prompt
		InputStreamReader input = new InputStreamReader(System.in);
		BufferedReader reader = new BufferedReader(input);
		
		for (;;) {
			System.out.print("> ");
			String source = reader.readLine();
			if (source == null)
				break;
			run(source);
			// even though last source had error
			// next source might not have error, we should reset the flag
			hadError = false;
		}
	}

	private static void runFile(String path) throws IOException {
		// read file bytes and run it
		byte[] bytes = Files.readAllBytes(Paths.get(path));
		run(new String(bytes, Charset.defaultCharset()));
		if (hadError)
			System.exit(65);
	}

	private static void run(String source) {
		// execute the file
		Scanner scanner = new Scanner(source);
		List<Token> tokens = scanner.scanTokens();
		
		for (Token token : tokens) {
			System.out.println(token);
		}
	}
	
	// Error handling is important
	// An interpreter should indicate error when user has syntax error
	static void error(int line, String msg) {
		report(line, "", msg);
	}

	private static void report(int line, String where, String msg) {
		System.err.println("[line " + line + "] Error" + where + ": " + msg);
		hadError = true;
	}

}
