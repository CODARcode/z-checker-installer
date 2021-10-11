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

if [[ $datatype == "-f" ]];then
	echo testfloat_CompDecomp $sz_cfgFile $zc_cfgFile $cmpCase $varName $errBoundMode $absErrBound $filePath $dim1 $dim2 $dim3 $dim4
	testfloat_CompDecomp $sz_cfgFile $zc_cfgFile $cmpCase $varName $errBoundMode $absErrBound "$filePath" $dim1 $dim2 $dim3 $dim4
else
	echo testdouble_CompDecomp $sz_cfgFile $zc_cfgFile $cmpCase $varName $errBoundMode $absErrBound $filePath $dim1 $dim2 $dim3 $dim4
	testdouble_CompDecomp $sz_cfgFile $zc_cfgFile $cmpCase $varName $errBoundMode $absErrBound "$filePath" $dim1 $dim2 $dim3 $dim4
fi
