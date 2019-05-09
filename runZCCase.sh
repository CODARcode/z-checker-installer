#!/bin/bash

datatype=$1
if [[ $# < 4 || ( $datatype != "-f" && $datatype != "-d" ) ]]
then
	echo " Usage: option 1: $0 [datatype (-f or -d)] [errBoundMode] [testcase] [data dir] [extension] [dimensions....]"
	echo "        option 2: $0 [datatype (-f or -d)] [errBoundMode] [testcase] [varInfo.txt]"
	echo " Example: $0 -f ABS testcase1 CESM-testdata/1800x3600 dat 3600 1800"
	echo "          $0 -f REL testcase2 varList.txt"
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
	varListFile=`readlink -f $4`

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
	if [ ! -d "Z-checker/$testcase" ]; then
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
SAM2P_EXE_PATH=`which sam2p`
if [ ! -x "$GNUPLOT_EXE_PATH" ]; then
	if [ -f $envConfigPath ]; then
		source $envConfigPath
	else
		echo "Error: gnuplot or sam2p is not executable and cannot find Z-checker/examples/env_config.sh either."
		exit
	fi
fi
if [ ! -x "$SAM2P_EXE_PATH" ]; then
	if [ -f $envConfigPath ]; then
		source $envConfigPath
	else
		echo "Error: gnuplot or sam2p is not executable and cannot find Z-checker/examples/env_config.sh either."
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




##begin: Compressor sz_d
cd $rootDir
cd SZ/${testcase}_deft
if [[ $option == 1 ]]; then
	echo ./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
	./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
else
	echo ./zc-ratedistortion.sh $datatype $errBoundMode $varListFile
	./zc-ratedistortion.sh $datatype $errBoundMode $varListFile
fi
##end: Compressor sz_d

##begin: Compressor zfp
cd $rootDir
cd zfp/${testcase}

if [[ $option == 1 ]]; then
        echo ./zfp-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
        ./zfp-zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4
else
        echo ./zfp-zc-ratedistortion.sh $datatype $errBoundMode $varListFile
        ./zfp-zc-ratedistortion.sh $datatype $errBoundMode "$varListFile"
fi
##end: Compressor zfp

##New compressor to be added here

cd $rootDir
cd Z-checker/${testcase}

if [[ $option == 1 ]]; then
	echo ./analyzeDataProperty.sh $datatype $dataDir $extension $dim1 $dim2 $dim3 $dim4
	./analyzeDataProperty.sh $datatype $dataDir $extension $dim1 $dim2 $dim3 $dim4
else
	echo ./analyzeDataProperty.sh $datatype $varListFile
	./analyzeDataProperty.sh $datatype "$varListFile"
fi

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

if [[ $errBoundMode == "PW_REL" ]]; then
	echo ./generateReport.sh ${testcase} with PW_REL
	./generateReport.sh "${testcase} with PW_REL"
else
	echo ./generateReport.sh ${testcase}
	./generateReport.sh "${testcase}"
fi
