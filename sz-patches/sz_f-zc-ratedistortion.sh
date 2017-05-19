#!/bin/bash

if [[ $# < 2  ]]; then
	echo Usage: $0 [data directory] [dimension sizes....]
	echo Example: $0 /home/shdi/CESM-testdata/1800x3600 3600 1800
	exit
fi

dataDir=$1
#dataDir=/home/fti/SZ_C_version/CESM-testdata/1800x3600

dim1=$2
dim2=$3
dim3=$4
dim4=$5

#Note: If you run this script by z-checker-installer, SZ_Err_Bounds will be overwritten by ../../errBounds.cfg as follows.
SZ_Err_Bounds="1E-1 1E-2 1E-3 1E-4"

if [ -f ../../errBounds.cfg ]; then
	sz_err_env="`cat ../../errBounds.cfg | grep sz_f_ERR_BOUNDS`"
	echo "export $sz_err_env" > env.tmp
	source env.tmp
	rm env.tmp
	SZ_Err_Bounds="`echo $sz_f_ERR_BOUNDS`"
fi

for errBound in $SZ_Err_Bounds
do
	./testfloat_CompDecomp.sh $errBound "$dataDir" $dim1 $dim2 $dim3 $dim4
done

