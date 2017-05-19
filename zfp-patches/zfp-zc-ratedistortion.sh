#!/bin/bash

if [[ $# < 2  ]]; then
	echo Usage: $0 [data directory] [dimension sizes....]
	echo Example: $0 /home/shdi/CESM-testdata/1800x3600 3600 1800
	exit
fi

dataDir="$1"
dim1=$2
dim2=$3
dim3=$4
dim4=$5

#Note: If you run this script by z-checker-installer, ZFP_Err_Bounds will be overwritten by ../../errBounds.cfg as follows.
ZFP_Err_Bounds="1E-1 1E-2 1E-3 1E-4"

if [ -f ../../errBounds.cfg ]; then
	zfp_err_env="`cat ../../errBounds.cfg | grep ZFP`"
	echo "export $zfp_err_env" > env.tmp
	source env.tmp
	rm env.tmp
	ZFP_Err_Bounds="`echo $ZFP_ERR_BOUNDS`"
fi

for errBound in $ZFP_Err_Bounds
do
	./zfp-zc-dir.sh $errBound "$dataDir" $dim1 $dim2 $dim3 $dim4
done

