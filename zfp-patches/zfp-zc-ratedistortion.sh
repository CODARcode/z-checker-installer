#!/bin/bash

if [[ $# < 3 ]]; then
	echo "Usage: $0 [datatype (-f or -d)] [data directory] [dimension sizes....]"
	echo Example: $0 -f /home/shdi/CESM-testdata/1800x3600 3600 1800
	exit
fi

datatype=$1
dataDir="$2"
dim1=$3
dim2=$4
dim3=$5
dim4=$6

#Note: If you run this script by z-checker-installer, ZFP_Err_Bounds will be overwritten by ../../errBounds.cfg as follows.
ZFP_Err_Bounds="1E-1 1E-2 1E-3 1E-4"

if [ -f ../../errBounds.cfg ]; then
	zfp_err_env="`cat ../../errBounds.cfg | grep -v "#" | grep ZFP_ERR_BOUNDS`"
	echo "export $zfp_err_env" > env.tmp
	source env.tmp
	rm env.tmp
	ZFP_Err_Bounds="`echo $ZFP_ERR_BOUNDS`"
fi

for errBound in $ZFP_Err_Bounds
do
	./zfp-zc-dir.sh $datatype $errBound "$dataDir" $dim1 $dim2 $dim3 $dim4
done

