#!/bin/bash

if [ "$#" -lt 1 ];
	then echo "Usage:"
	echo "./LEX_SHELL.sh <Input Folder name>"
	
	
else

	flex 1905119.l
	g++ lex.yy.c
	./a.out "$1"
	
fi

