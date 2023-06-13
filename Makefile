.PHONY: clean

st:
	@make -C lexer
	@make -C parser
	@make -C codegen
	@make -C javaa

clean:
	@make -C lexer clean
	@make -C parser clean
	@make -C codegen clean
	@make -C javaa clean
	rm -f *.jasm *.class
