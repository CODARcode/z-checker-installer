#!/bin/bash

if [[ $# < 5 ]]
then
	echo "Usage: $0 [datatype (-f or -d)] [dataFilePath] [varName] [errBound] [dimension sizes....]"
	echo Example: $0 -f CESM-testdata/CLDLOW_1_1800_3600.dat CLDLOW 1E-4 3600 1800
	exit
fi

cmdDir=../bin

datatype=$1
dataFilePath=$2
varName=$3
errBound=$4
let dim=$#-4

if [[ $dim == 1 ]]
then
	echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
elif [[ $dim == 2 ]]
then
	echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $4 $5 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $4 $5 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
elif [[ $dim == 3 ]]
then
	echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $4 $5 $6 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $4 $5 $6 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
fi
