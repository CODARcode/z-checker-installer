#!/bin/bash

if [[ $# < 1 ]]; then
	echo Usage: $0 [testcase name]
	exit
fi

testcase=$1
if [ -d Z-checker/$testcase ]; then
	rm -rf Z-checker/$testcase
	rm -rf SZ/${testcase}_fast
	rm -rf SZ/${testcase}_deft
	rm -rf zfp/${testcase}
else
	echo No such testcase: $testcase
	exit
fi
