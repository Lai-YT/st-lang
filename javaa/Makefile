CCFLAGS = -g
BUILD =  utils.o symbol.o gen.o
BIN   =  /home/cec/class/cs431/bin
CC     = g++
CFLAGS = $(CCFLAGS)


javaa:	gram.o newlex.l lex.o main.o $(BUILD) Makefile
	$(CC) $(CFLAGS) -o javaa main.o gram.o lex.o $(BUILD)

gram.o:	javaa.y
	bison -d -t javaa.y
	mv javaa.tab.c gram.c
	cmp -s javaa.tab.h gram.h || cp javaa.tab.h gram.h
	$(CC) $(CFLAGS) -c gram.c

gram.o:	build.h types.h utils.h protos.h

lex.o:	javaa.l
	flex javaa.l
	mv lex.yy.c lex.c
	$(CC) $(CFLAGS) -c lex.c

lex.o:	types.h gram.h utils.h build.h listing.h protos.h

$(BUILD):	types.h build.h utils.h listing.h

sem.o:	gram.h

newlex.l:	beginlex.l middlelex.l endlex.l
	cat beginlex.l middlelex.l endlex.l > newlex.l
	cmp -s newlex.l javaa.l || cp newlex.l javaa.l

clean:
	/bin/rm -f *.o newlex.l javaa.l
	/bin/rm -f gram.h javaa.tab.h javaa.tab.c lex.yy.c lex.c gram.c
	/bin/rm -f javaa.output

distrib:
	shar -o SHAR *.c Makefile *.h beginlex.l middlelex.l endlex.l *.y
