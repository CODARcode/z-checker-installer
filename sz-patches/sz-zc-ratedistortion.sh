#!/bin/bash

if [[ $# < 4 ]]; then
	echo "Usage: $0 [data type (-f or -d)] [errBoundMode] [data directory] [extension] [dimension sizes....]"
	echo "Example: $0 -f ABS /home/shdi/CESM-testdata/1800x3600 3600 1800"
	exit
fi

datatype=$1
errBoundMode=$2
if [ -d $3 ]; then
	option=1
else
	option=2
fi

if [[ $option == 1 ]]; then
	dataDir=$3
	extension=$4
	dim1=$5
	dim2=$6
	dim3=$7
	dim4=$8
else
	varListFile=$3
fi

#Note: If you run this script by z-checker-installer, SZ_Err_Bounds will be overwritten by ../../errBounds.cfg as follows.
SZ_Err_Bounds="1E-1 1E-2 1E-3 1E-4"

if [ -f ../../errBounds.cfg ]; then
	if [[ $errBoundMode == "PW_REL" ]];then
		sz_err_env="`cat ../../errBounds_pwr.cfg | grep -v "#" | grep SZ_ERR_BOUNDS`"
	else
		sz_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep SZ_ERR_BOUNDS`"
	fi
	echo "export $sz_err_env" > env.tmp
	source env.tmp
	rm env.tmp
	SZ_Err_Bounds="`echo $SZ_ERR_BOUNDS`"
fi

for errBound in $SZ_Err_Bounds
do
	if [[ $datatype == "-f" ]]; then
		if [[ $option == 1 ]]; then
			./testfloat_CompDecomp.sh $errBoundMode $errBound "$dataDir" $extension $dim1 $dim2 $dim3 $dim4
		else
			./testfloat_CompDecomp.sh $errBoundMode $errBound "$varListFile"
		fi
	elif [[ $datatype == "-d" ]]; then
		if [[ $option == 1 ]]; then
			./testdouble_CompDecomp.sh $errBoundMode $errBound "$dataDir" $extension $dim1 $dim2 $dim3 $dim4
		else
			./testdouble_CompDecomp.sh $errBoundMode $erBound "$varListFile"
		fi
	else
		echo "Error: datatype = $datatype . "
		echo "Note: datatype can only be either -f or -d."
		exit
	fi
done

