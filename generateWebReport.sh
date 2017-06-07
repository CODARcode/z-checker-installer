#!/bin/bash

if [[ $# < 1 ]]
then
	echo "Usage: $0 <casename>"
	exit
fi 

testcase=$1

rootDir=`pwd`

export PATH=$rootDir/node-v6.11.0-install-bin:$PATH

node $rootDir/z-checker-web/generate-report.js $rootDir/Z-checker/$testcase

echo "Please use your web browser to open this webpage:"
echo "file://"$rootDir/Z-checker/$testcase/report/web/index.htm
