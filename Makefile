.PHONY: clean

CC := cc
CFLAGS := -g -O0 -U_YYDEBUG

run: parser.tab.o scanner.o ast.o module.o main.o
	$(CC) -g -o $@ $+

clean:
	rm -f run *.o parser.tab* scanner.[ch] *.output .*.swp

parser.tab.o: scanner.c

scanner.c: scanner.l
	flex -d --header-file=scanner.h --outfile=scanner.c scanner.l

parser.tab.c: parser.y
	bison -d parser.y
