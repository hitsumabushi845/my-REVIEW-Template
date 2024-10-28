#!/bin/bash -xe

if [ $# -eq 0 ]; then
	./node_modules/.bin/textlint articles/main/
	exit 0
fi

./node_modules/.bin/textlint $1
