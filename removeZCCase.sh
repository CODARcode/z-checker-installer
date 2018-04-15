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
##begin: Compressor sz_f		
		rm -rf SZ/${testcase}_fast
##end: Compressor sz_f
##begin: Compressor sz_d
		rm -rf SZ/${testcase}_deft
##end: Compressor sz_d
##begin: Compressor zfp
		rm -rf zfp/${testcase}
##end: Compressor zfp
##New compressor to be added here
	else
		echo No such testcase: $testcase
		exit
	fi
elif [[ $errBoundMode == "PW_REL" ]]; then
	if [ -d Z-checker/${testcase}-pwr ]; then
		rm -rf Z-checker/$testcase-pwr
		rm -rf SZ/${testcase}-pwr_fast
		rm -rf SZ/${testcase}-pwr_def
		rm -rf zfp/${testcase}-pwr
	else
		echo No such testcase: $testcase-pwr
		exit
	fi
else
	echo Error: wrong errBoundMode.
	exit
fi
