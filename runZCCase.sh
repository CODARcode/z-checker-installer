#!/bin/bash

datatype=$1
if [[ $# < 4 || ( $datatype != "-f" && $datatype != "-d" ) ]]
then
	echo "Usage: option 1: $0 [datatype (-f or -d)] [errBoundMode] [testcase] [data dir] [extension] [dimensions....]"
	echo "       option 2: $0 [datatype (-f or -d)] [errBoundMode] [testcase] [varInfo.txt]"
	echo "Example: $0 -f ABS testcase1 CESM-testdata/1800x3600 dat 3600 1800"
	echo "         $0 -f REL testcase2 varList.txt"
	exit
fi 

errBoundMode=$2
testcase=$3

if [ -d "$4" ]; then
	option=1
else
	option=0
fi

if [[ $option == 1 ]]; then
	dataDir=`cd "$4"; pwd`
	extension=$5
	dim1=$6
	dim2=$7
	dim3=$8
	dim4=$9
else
	varListFile=`realpath $4`

	if [ ! -f "$varListFile" ]; then
		echo "Error: $varListFile does not exist!\n";
		exit
	fi
fi

rootDir=`pwd`

if [[ $errBoundMode == "ABS" ]]; then
	if [ ! -d "Z-checker/$testcase" ]; then
		echo "Error: Testcase $testcase doesn't exist!"
		exit
	fi
elif [[ $errBoundMode == "REL" ]]; then
	if [ ! -d "Z-checker/$testcase" ]; then
		echo "Error: Testcase $testcase doesn't exist!"
		exit
	fi
elif [[ $errBoundMode == "PW_REL" ]]; then
	if [ ! -d "Z-checker/$testcase-pwr" ]; then
		echo "Error: Testcase $testcase for PW_REL doesn't exist!"
		exit
	fi
fi

if [[ $option == 1 ]]; then
if [ ! -d "$dataDir" ]; then
	echo "Error: $dataDir doesn't exist!"
	exit
fi
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

if [[ $errBoundMode == "PW_REL" ]]; then
	cd SZ/${testcase}-pwr_fast
else
	cd SZ/${testcase}_fast
fi
if [[ $option == 1 ]]; then
	echo ./sz-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
	./sz-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
else
	echo ./sz-zc-ratedistortion.sh $datatype $errBoundMode $varListFile
	./sz-zc-ratedistortion.sh $datatype $errBoundMode "$varListFile"
fi

cd $rootDir
if [[ $errBoundMode == "PW_REL" ]]; then
	cd SZ/${testcase}-pwr_deft
else
	cd SZ/${testcase}_deft
fi

if [[ $option == 1 ]]; then
	echo ./sz-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
	./sz-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
else
	echo ./sz-zc-ratedistortion.sh $datatype $errBoundMode $varListFile
	./sz-zc-ratedistortion.sh $datatype $errBoundMode "$varListFile"
fi

cd $rootDir
if [[ $errBoundMode == "PW_REL" ]]; then
	cd zfp/${testcase}-p
else
	cd zfp/${testcase}
fi

if [[ $option == 1 ]]; then
	echo ./zfp-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
	./zfp-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
else
	echo ./zfp-zc-ratedistortion.sh $datatype $errBoundMode $varListFile
	./zfp-zc-ratedistortion.sh $datatype $errBoundMode "$varListFile"
fi

cd $rootDir
if [[ $errBoundMode == "PW_REL" ]]; then
	cd Z-checker/${testcase}-pwr
else
	cd Z-checker/${testcase}
fi

if [[ $option == 1 ]]; then
	echo ./analyzeDataProperty.sh $datatype $dataDir $extension $dim1 $dim2 $dim3 $dim4
	./analyzeDataProperty.sh $datatype $dataDir $extension $dim1 $dim2 $dim3 $dim4
else
	echo ./analyzeDataProperty.sh $datatype $varListFile
	./analyzeDataProperty.sh $datatype "$varListFile"
fi

############## as follows, it's comparison ##############

if [[ $errBoundMode == "PW_REL" ]]; then
	sz_err_env="`cat ../../errBounds_pwr.cfg | grep -v "#" | grep comparisonCases`"
else
	sz_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep comparisonCases`"
fi
echo "export $sz_err_env" > env.tmp
source env.tmp
rm env.tmp
SZ_Err_Bounds="`echo $comparisonCases`"

echo comparisonCases=$comparisonCases
./modifyZCConfig zc.config comparisonCases "$comparisonCases"

if [[ $errBoundMode == "PW_REL" ]]; then
	zc_err_env="`cat ../../errBounds_pwr.cfg | grep -v "#" | grep numOfErrorBoundCases`"
else
	zc_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep numOfErrorBoundCases`"
fi
echo "export $zc_err_env" > env.tmp
source env.tmp
rm env.tmp
ZC_Err_Bounds="`echo $numOfErrorBoundCases`"

echo numOfErrorBoundCasess=$numOfErrorBoundCases
./modifyZCConfig zc.config numOfErrorBoundCases "$numOfErrorBoundCases"

if [[ $errBoundMode == "PW_REL" ]]; then
	echo ./generateReport.sh ${testcase}-pwr
	./generateReport.sh "${testcase} with PW_REL"
else
	echo ./generateReport.sh ${testcase}
	./generateReport.sh "${testcase}"
fi
