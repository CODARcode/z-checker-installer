#!/bin/bash

if [[ $# < 3 ]]; then
	echo "Usage - option 1: $0 [datatype (-f or -d)] [errorBoundMode] [data directory] [extension] [dimension sizes....]"
	echo "      - option 2: $0 [datatype (-f or -d)] [errorBoundMode] [varListFile]"
	echo Example: $0 -f ABS /home/shdi/CESM-testdata/1800x3600 3600 1800
	exit
fi

datatype=$1
errBoundMode=$2

if [ -d $3 ]; then
	option=1
else
	option=0
fi

if [[ $option == 1 ]]; then
	dataDir="$3"
	extension=$4
	dim1=$5
	dim2=$6
	dim3=$7
	dim4=$8
else
	varListFile=$3
fi

#Note: If you run this script by z-checker-installer, ZFP_Err_Bounds will be overwritten by ../../errBounds.cfg as follows.
ZFP_Err_Bounds="1E-1 1E-2 1E-3 1E-4"

#echo errBoundMode=$errBoundMode dataDir=$dataDir
if [ -f ../../errBounds.cfg ]; then
	if [[ $errBoundMode == "PW_REL" ]]; then
		zfp_err_env="`cat ../../errBounds_pwr.cfg | grep -v "#" | grep zfp_ERR_BOUNDS`"
	else
		zfp_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep zfp_ERR_BOUNDS`"
	fi
	echo "export $zfp_err_env" > env.tmp
	source env.tmp
	rm env.tmp
	ZFP_Err_Bounds="`echo $zfp_ERR_BOUNDS`"
	echo $ZFP_Err_Bounds
fi

for errBound in $ZFP_Err_Bounds
do
	if [[ $option == 1 ]]; then
		echo ./zfp-zc-dir.sh $datatype $errBoundMode $errBound "$dataDir" $extension $dim1 $dim2 $dim3 $dim4
		./zfp-zc-dir.sh $datatype $errBoundMode $errBound "$dataDir" $extension $dim1 $dim2 $dim3 $dim4
	else
		echo ./zfp-zc-dir.sh $datatype $errBoundMode $errBound $varListFile
		./zfp-zc-dir.sh $datatype $errBoundMode $errBound $varListFile
	fi	
done

