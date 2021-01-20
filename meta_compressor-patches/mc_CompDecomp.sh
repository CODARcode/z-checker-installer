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
	echo processing mcfloat_CompDecomp on "$filePath"
	./mcfloat_CompDecomp $zc_cfgFile $cmpCase $varName $ErrBound "$filePath" $dim1 $dim2 $dim3
	echo done
else
	echo processing mcdouble_CompDecomp on "$filePath"
	./mcdouble_CompDecomp $zc_cfgFile $cmpCase $varName $ErrBound "$filePath" $dim1 $dim2 $dim3
	echo done
fi
