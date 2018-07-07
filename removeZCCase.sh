#!/bin/bash

if [[ $# < 1 ]]; then
	echo "Usage: $0 ([errBoundMode]) [testcase name]"
	exit
fi

if [[ $# == 1 ]]; then
	testcase=$1
fi

if [[ $# == 2 ]]; then
	errBoundMode=$1
	testcase=$2
fi

if [[ $# == 1 || $errBoundMode == "ABS" || $errBoundMode == "REL" ]]; then
	if [ -d Z-checker/$testcase ]; then
		rm -rf Z-checker/$testcase
##begin: Compressor sz_d
		rm -rf SZ/${testcase}_deft
##end: Compressor sz_d
##begin: Compressor zfp
		rm -rf zfp/${testcase}
##end: Compressor zfp
##begin: Compressor sz_f
	rm -rf ./SZ/${testcase}_fast
##end: Compressor sz_f
##New compressor to be added here
	else
		echo No such testcase: $testcase
		exit
	fi
elif [[ $errBoundMode == "PW_REL" ]]; then
	if [ -d Z-checker/${testcase} ]; then
		rm -rf Z-checker/$testcase
		rm -rf SZ/${testcase}_fast
		rm -rf SZ/${testcase}_deft
		rm -rf zfp/${testcase}
	else
		echo No such testcase: $testcase
		exit
	fi
else
	echo Error: wrong errBoundMode.
	exit
fi
