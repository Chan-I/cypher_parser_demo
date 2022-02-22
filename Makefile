.PHONY: clean

CC := gcc
OPTIONS := -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat
DEBUG := -g -O0
CFLAGS := ${DEBUG} -U_YYDEBUG -D__YYEMIT ${OPTIONS}

run: parser.o scanner.o ast.o print.o delete.o module.o main.o 
	$(CC) ${CFLAGS} -g -o $@ $+ 

clean:
	rm -f run *.o parser.[ch] scanner.[ch] *.output .*.swp

parser.o: scanner.c

scanner.c: scanner.l
	flex -d --header-file=scanner.h --outfile=$@ $^

parser.c: parser.y
	bison -Wno-deprecated -vd $^ -o $@
