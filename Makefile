# $Header: /home/johnl/flnb/code/RCS/Makefile.ch1,v 2.2 2009/11/08 02:52:21 johnl Exp $
# Companion source code for "flex & bison", published by O'Reilly
# Media, ISBN 978-0-596-15597-1
# Copyright (c) 2009, Taughannock Networks. All rights reserved.
# See the README file for license conditions and contact info.

# programs in chapter 1
CFLAGS:=-g -O0

all:	test

test:main.c  test.tab.o test.lex.o testfuncs.o
	cc -g -O0 -o $@ $^ -lfl

test.tab.c:test.y
	bison -d $^

test.lex.c:test.l
	flex --header-file=test.lex.h -b -CF -p  -o $@ $^


.PHONY: clean

clean:
	rm -f test \
	*.lex.c *.lex.h *.tab.h *.tab.c \
	*.output *.o *.backup

