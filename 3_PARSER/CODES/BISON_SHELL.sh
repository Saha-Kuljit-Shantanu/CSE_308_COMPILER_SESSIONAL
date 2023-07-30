#!/bin/bash

if [ "$#" -lt 1 ];
	then echo "Usage:"
	echo "./BISON_SHELL.sh <Input Folder name>"
	
	
else

	yacc -d -y 1905119.y
	echo 'Generated the parser C file as well the header file'
	g++ -w -c -o y.o y.tab.c
	echo 'Generated the parser object file'
	flex 1905119.l
	echo 'Generated the scanner C file'
	g++ -fpermissive -w -c -o l.o lex.yy.c
	echo 'Generated the scanner object file'
	g++ y.o l.o -lfl -o bisonofl
	echo 'All ready, running'
	./bisonofl
	
fi
