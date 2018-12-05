#!/bin/bash

rootDir="`pwd`/../"
dataDir="$rootDir/travis-ci/SZ-travis-testdata-master/travis-testdata"
export PATH=$rootDir:.:$PATH

cd $rootDir

compileMode='update'
if [ ! -d SZ ]
then
	compileMode='install'
fi

echo compileMode=$compileMode

if [[ $compileMode == 'install' ]]
then
	./z-checker-install.sh	
else
	./z-checker-update.sh
fi


echo ------------------------------- CESM-ATM-Tylor --------------------------------
app=CESM-ATM-Tylor

echo ./createZCCase.sh $app
./createZCCase.sh $app

echo ./runZCCase.sh -f REL $app $dataDir/$app f32 3600 1800
./runZCCase.sh -f REL $app $dataDir/$app f32 3600 1800

echo ls -al Z-checker/$app/report
ls -al Z-checker/$app/report/*.pdf
pdfinfo Z-checker/$app/report/z-checker-report.pdf 

echo ------------------------------- CESM-ATM-Tylor --------------------------------
app=HACC

echo ./createZCCase.sh $app
./createZCCase.sh $app

echo ./runZCCase.sh -f REL $app $dataDir/$app f32 131072
./runZCCase.sh -f REL $app $dataDir/$app f32 131072 

echo ls -al Z-checker/$app/report
ls -al Z-checker/$app/report/*.pdf
pdfinfo Z-checker/$app/report/z-checker-report.pdf 

echo ------------------------------- CESM-ATM-Tylor --------------------------------
app=Hurricane

echo ./createZCCase.sh $app
./createZCCase.sh $app

echo ./runZCCase.sh -f REL $app $dataDir/$app f32 500 500 100
./runZCCase.sh -f REL $app $dataDir/$app f32 500 500 100

echo ls -al Z-checker/$app/report
ls -al Z-checker/$app/report/*.pdf
pdfinfo Z-checker/$app/report/z-checker-report.pdf 

