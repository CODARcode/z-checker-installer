#!/bin/bash

rootDir="`pwd`/../"
dataDir="$rootDir/travis-ci/SZ-travis-testdata-master/travis-testdata"
export PATH=$rootDir:.:$PATH

cd $rootDir

echo ------------------------------- CESM-ATM-Tylor --------------------------------
app=CESM-ATM-Tylor
compileMode=update
if [ ! -d SZ ]
then
	compileMode=install
fi

if [[ compileMode == install ]]
then
	./z-checker-install.sh	
else
	./z-checker-update.sh
fi

echo ./createZCCase.sh $app
./createZCCase.sh $app

echo ./runZCCase.sh -f REL $app $dataDir/CESM-ATM-Tylor f32 3600 1800
./runZCCase.sh -f REL $app $dataDir/CESM-ATM-Tylor f32 3600 1800

echo ls -al Z-checker/$app/report
ls -al Z-checker/$app/report
