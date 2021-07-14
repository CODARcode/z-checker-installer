#!/bin/bash

zc_cfgFile=$1
cmpCase=$2
datatype=$3
varName=$4
errBoundMode=$5
ErrBound=$6
filePath=$7
dim1=$8
dim2=$9
dim3=${10}
dim4=${11}

dims=$(($#-7))

if [ $errBoundMode = "ABS" ]; then
        mode="-A"
else
        mode="-R"
fi

echo ./pressio_compdecomp_zc -z zfp -c "$zc_cfgFile" -V $varName -S "$cmpCase" $datatype -i "$filePath" -$dims $dim1 $dim2 $dim3 $dim4 $mode $ErrBound
./pressio_compdecomp_zc -z zfp -c "$zc_cfgFile" -V $varName -S "$cmpCase" $datatype -i "$filePath" -$dims $dim1 $dim2 $dim3 $dim4 $mode $ErrBound
