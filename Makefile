# $Header: /home/johnl/flnb/code/RCS/Makefile.ch1,v 2.2 2009/11/08 02:52:21 johnl Exp $
# Companion source code for "flex & bison", published by O'Reilly
# Media, ISBN 978-0-596-15597-1
# Copyright (c) 2009, Taughannock Networks. All rights reserved.
# See the README file for license conditions and contact info.

# programs in chapter 1

all:	test

test:	test.l test.y test.h testfuncs.c
	bison -d test.y
	flex -o test.lex.c test.l
	cc -g -O0 -o $@ test.tab.c test.lex.c testfuncs.c

clean:
	rm -f test \
	test.lex.c test.tab.h test.tab.c \
	*.output

