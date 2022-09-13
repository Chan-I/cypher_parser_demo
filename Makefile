.PHONY: clean

CC := gcc

OBJS := parser.o scanner.o ast.o print.o delete.o module.o main.o

OPTIONS := -Wmissing-prototypes -Wpointer-arith \
			-Wendif-labels -Wmissing-format-attribute \
			-Wformat-security -Wformat

DEBUG := -g -O0

CFLAGS := ${DEBUG} -U_YYDEBUG -U__YYEMIT ${OPTIONS}

run: ${OBJS}
	$(CC) ${CFLAGS} -g -o $@ $+ 

clean:
	rm -f run *.o *.backup parser.[ch] scanner.[ch] *.output .*.swp

parser.o: scanner.c

scanner.c: scanner.l
	flex -b -CF -p -p --header-file=scanner.h --outfile=$@ $^

parser.c: parser.y
	bison -Wno-deprecated -vd $^ -o $@
