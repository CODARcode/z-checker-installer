#!/bin/bash

sz_cfgFile=$1
zc_cfgFile=$2
cmpCase=$3
datatype=$4
varName=$5
errBoundMode=$6
absErrBound=$7
filePath=$8
dim1=$9
dim2=${10}
dim3=${11}
dim4=${12}

dims=$(($#-8))

if [ $errBoundMode = "ABS" ]; then
	mode="-A"
else
	mode="-R"
fi

echo pressio_compdecomp_zc -z sz -c $zc_cfgFile -V $varName -S "$cmpCase" $datatype -i "$filePath" -$dims $dim1 $dim2 $dim3 $dim4 $mode $absErrBound
pressio_compdecomp_zc -z sz -c "$zc_cfgFile" -V $varName -S "$cmpCase" $datatype -i "$filePath" -$dims $dim1 $dim2 $dim3 $dim4 $mode $absErrBound
