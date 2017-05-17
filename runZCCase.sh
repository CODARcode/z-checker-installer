#!/bin/bash

if [[ $# < 3 ]]
then
	echo Usage: $0 [testcase] [data dir] [dimensions....]
	echo Example: $0 testcase1 CESM-testdata/1800x3600 3600 1800
	exit
fi 

testcase=$1
dataDir=$2
dim1=$3
dim2=$4
dim3=$5
dim4=$6

rootDir=`pwd`

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
echo ./sz-zc-ratedistortion.sh $dataDir $dim1 $dim2 $dim3 $dim4
#./sz-zc-ratedistortion.sh $dataDir $dim1 $dim2 $dim3 $dim4

cd $rootDir
cd SZ/${testcase}_deft
echo ./sz-zc-ratedistortion.sh $dataDir $dim1 $dim2 $dim3 $dim4
#./sz-zc-ratedistortion.sh $dataDir $dim1 $dim2 $dim3 $dim4

cd $rootDir
cd zfp/${testcase}
echo ./zfp-zc-ratedistortion.sh $dataDir $dim1 $dim2 $dim3 $dim4
#./zfp-zc-ratedistortion.sh $dataDir $dim1 $dim2 $dim3 $dim4

cd $rootDir
cd Z-checker/${testcase}
echo ./analyzeDataProperty.sh $dataDir $dim1 $dim2 $dim3 $dim4
#./analyzeDataProperty.sh $dataDir $dim1 $dim2 $dim3 $dim4

echo ./generateReport.sh ${testcase}
./generateReport.sh ${testcase}
