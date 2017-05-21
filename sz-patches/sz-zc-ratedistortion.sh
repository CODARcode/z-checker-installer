#!/bin/bash

if [[ $# < 3 ]]; then
	echo "Usage: $0 [data type (-f or -d)] [data directory] [dimension sizes....]"
	echo "Example: $0 -f /home/shdi/CESM-testdata/1800x3600 3600 1800"
	exit
fi

datatype=$1
dataDir=$2
#dataDir=/home/fti/SZ_C_version/CESM-testdata/1800x3600

dim1=$3
dim2=$4
dim3=$5
dim4=$6

#Note: If you run this script by z-checker-installer, SZ_Err_Bounds will be overwritten by ../../errBounds.cfg as follows.
SZ_Err_Bounds="1E-1 1E-2 1E-3 1E-4"

if [ -f ../../errBounds.cfg ]; then
	sz_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep SZ_ERR_BOUNDS`"
	echo "export $sz_err_env" > env.tmp
	source env.tmp
	rm env.tmp
	SZ_Err_Bounds="`echo $SZ_ERR_BOUNDS`"
fi

for errBound in $SZ_Err_Bounds
do
	if [[ $datatype == "-f" ]]; then
		./testfloat_CompDecomp.sh $errBound "$dataDir" $dim1 $dim2 $dim3 $dim4
	elif [[ $datatype == "-d" ]]; then
		./testdouble_CompDecomp.sh $errBound "$dataDir" $dim1 $dim2 $dim3 $dim4
	else
		echo "Error: datatype = $datatype . "
		echo "Note: datatype can only be either -f or -d."
		exit
	fi
done

