#!/bin/bash

if [[ $# < 3  ]]; then
	echo Usage: $0 [data directory] [dimension sizes....]
	echo Example: $0 /home/shdi/CESM-testdata/1800x3600 3600 1800
	exit
fi

dataDir="$1"
dim1=$2
dim2=$3
dim3=$4
dim4=$5

./zfp-zc-dir.sh 1E-8 "$dataDir" $dim1 $dim2 $dim3 $dim4
./zfp-zc-dir.sh 1E-7 "$dataDir" $dim1 $dim2 $dim3 $dim4
./zfp-zc-dir.sh 1E-6 "$dataDir" $dim1 $dim2 $dim3 $dim4
./zfp-zc-dir.sh 1E-5 "$dataDir" $dim1 $dim2 $dim3 $dim4
./zfp-zc-dir.sh 1E-4 "$dataDir" $dim1 $dim2 $dim3 $dim4
./zfp-zc-dir.sh 1E-3 "$dataDir" $dim1 $dim2 $dim3 $dim4
./zfp-zc-dir.sh 1E-2 "$dataDir" $dim1 $dim2 $dim3 $dim4
./zfp-zc-dir.sh 1E-1 "$dataDir" $dim1 $dim2 $dim3 $dim4
