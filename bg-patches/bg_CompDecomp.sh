#!/bin/bash

zc_cfgFile=$1
cmpCase=$2
datatype=$3
varName=$4
ErrBound=$5
filePath=$6
dim1=$7
dim2=${8}
dim3=${9}
dim4=${10}

if [[ $datatype == "-f" ]];then
	echo processing bgfloat_CompDecomp on "$filePath"
	./bgfloat_CompDecomp $zc_cfgFile $cmpCase $varName $ErrBound "$filePath" $dim1 $dim2 $dim3 $dim4
else
	echo processing bgdouble_CompDecomp on "$filePath"
	./bgdouble_CompDecomp $zc_cfgFile $cmpCase $varName $ErrBound "$filePath" $dim1 $dim2 $dim3 $dim4
fi
