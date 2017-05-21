#!/bin/bash

datatype=$1
echo "$datatype"
if [[ $# < 4 || ( $datatype != "-f" && $datatype != "-d" ) ]]
then
	echo "Usage: $0 [datatype (-f or -d)] [testcase] [data dir] [dimensions....]"
	echo "Example: $0 -f testcase1 CESM-testdata/1800x3600 3600 1800"
	exit
fi 

testcase=$2
dataDir=`cd "$3"; pwd`
dim1=$4
dim2=$5
dim3=$6
dim4=$7

rootDir=`pwd`

if [ ! -d "Z-checker/$testcase" ]; then
	echo "Error: Testcase $testcase doesn't exist!"
	exit
fi

if [ ! -d "$dataDir" ]; then
	echo "Error: $dataDir doesn't exist!"
	exit
fi

envConfigPath="$rootDir/Z-checker/examples/env_config.sh"
GNUPLOT_EXE_PATH=`which gnuplot`
if [ ! -x "$GNUPLOT_EXE_PATH" ]; then
	if [ -f $envConfigPath ]; then
		source $envConfigPath
	else
		echo "Error: gnuplot is not executable and cannot find Z-checker/examples/env_config.sh either."
		exit
	fi
fi

LATEXMK_EXE_PATH=`which latexmk`
if [ ! -x "$LATEXMK_EXE_PATH" ]; then
	if [ -z "$GNUPLOT_PATH" ]; then
		if [ -f $envConfigPath ]; then
			source $envConfigPath
		else
			echo "Error: latexmk is not executable and cannot find Z-checker/examples/env_config.sh either."
			exit
		fi
	fi
fi

cd SZ/${testcase}_fast
echo ./sz-zc-ratedistortion.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4
./sz-zc-ratedistortion.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4

cd $rootDir
cd SZ/${testcase}_deft
echo ./sz-zc-ratedistortion.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4
./sz-zc-ratedistortion.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4

cd $rootDir
cd zfp/${testcase}
echo ./zfp-zc-ratedistortion.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4
./zfp-zc-ratedistortion.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4

cd $rootDir
cd Z-checker/${testcase}
echo ./analyzeDataProperty.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4
./analyzeDataProperty.sh $datatype $dataDir $dim1 $dim2 $dim3 $dim4

sz_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep comparisonCases`"
echo "export $sz_err_env" > env.tmp
source env.tmp
rm env.tmp
SZ_Err_Bounds="`echo $comparisonCases`"

echo comparisonCases=$comparisonCases
./modifyZCConfig zc.config comparisonCases "$comparisonCases"

echo ./generateReport.sh ${testcase}
./generateReport.sh ${testcase} 
