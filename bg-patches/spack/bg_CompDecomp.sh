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

dims=$(($#-6))

echo ./pressio_compdecomp_zc -z bitgrooming -c "$zc_cfgFile" -V $varName -S "$cmpCase" $datatype -i "$filePath" -$dims $dim1 $dim2 $dim3 $dim4 -A $ErrBound
./pressio_compdecomp_zc -z bitgrooming -c "$zc_cfgFile" -V $varName -S "$cmpCase" $datatype -i "$filePath" -$dims $dim1 $dim2 $dim3 $dim4 -A $ErrBound
