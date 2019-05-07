#!/bin/bash

if [ $# != 1 ]
then
        echo Usage: $0 [workspace name]
        echo Example: $0 CESM-ATM
        exit
fi

workspace=$1

rootDir=`pwd`

#copy results to sz_workspace
sz_workspace=SZ/${workspace}_deft
mkdir -p $sz_workspace/compressionResults
echo mv compressionResults/sz_d* $sz_workspace/compressionResults
mv compressionResults/sz_d* $sz_workspace/compressionResults

#copy results to zfp_workspace
zfp_workspace=zfp/${workspace}
mkdir -p $zfp_workspace/compressionResults
echo mv compressionResults/zfp* $zfp_workspace/compressionResults
mv compressionResults/zfp* $zfp_workspace/compressionResults

#create scripts for Z-checker workspace
cd Z-checker
if [ ! -d $workspace ];then
	./createNewCase.sh $workspace
	mkdir -p $workspace/dataProperties
	echo mv dataProperties* $workspace/dataProperties
	mv $rootDir/dataProperties/* $workspace/dataProperties
else
	echo Error: $workspace already exits!
	echo Please remove it using removeZCCase.sh.

	rm -rf $rootDir/compressionResults
	rm -rf $rootDir/dataProperties
	exit
fi

#modify zc.config based on compression cases
cd $workspace
./modifyZCConfig zc.config compressors "sz_d:../../SZ/${workspace}_deft zfp:../../zfp/${workspace}"

############## as follows, it's comparison ##############

sz_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep comparisonCases`"

echo "export $sz_err_env" > env.tmp
source env.tmp
rm env.tmp
SZ_Err_Bounds="`echo $comparisonCases`"

echo comparisonCases=$comparisonCases
./modifyZCConfig zc.config comparisonCases "$comparisonCases"

zc_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep numOfErrorBoundCases`"

echo "export $zc_err_env" > env.tmp
source env.tmp
rm env.tmp
ZC_Err_Bounds="`echo $numOfErrorBoundCases`"

echo numOfErrorBoundCasess=$numOfErrorBoundCases
./modifyZCConfig zc.config numOfErrorBoundCases "$numOfErrorBoundCases"

testcase=$workspace
if [[ $errBoundMode == "PW_REL" ]]; then
        echo ./generateReport.sh ${testcase} with PW_REL
        ./generateReport.sh "${testcase} with PW_REL"
else
        echo ./generateReport.sh ${testcase}
        ./generateReport.sh "${testcase}"
fi

#remove useless files
cd $rootDir
rm -rf compressionResults
rm -rf dataProperties

if [ -f Z-checker/${workspace}/report/z-checker-report.pdf ];then
	ln -f -s Z-checker/${workspace}/report/z-checker-report.pdf z-checker-report.pdf
	echo "The z-checker report has been generated (z-checker-report.pdf)"
fi

echo done
