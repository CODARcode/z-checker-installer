#!/bin/bash

if [[ $# < 4 ]]
then
	echo Usage: $0 [dataFilePath] [varName] [errBound] [dimension sizes....]
	echo Example: $0 CESM-testdata/CLDLOW_1_1800_3600.dat CLDLOW 1E-4 3600 1800
	exit
fi

cmdDir=../bin

dataFilePath=$1
varName=$2
errBound=$3
let dim=$#-3

if [[ $dim == 1 ]]
then
	echo ${cmdDir}/zfp-zc -s -f -a ${errBound} -${dim} $4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	${cmdDir}/zfp-zc -s -f -a ${errBound} -${dim} $4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
elif [[ $dim == 2 ]]
then
	echo ${cmdDir}/zfp-zc -s -f -a ${errBound} -${dim} $4 $5 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	${cmdDir}/zfp-zc -s -f -a ${errBound} -${dim} $4 $5 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
elif [[ $dim == 3 ]]
then
	echo ${cmdDir}/zfp-zc -s -f -a ${errBound} -${dim} $4 $5 $6 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	${cmdDir}/zfp-zc -s -f -a ${errBound} -${dim} $4 $5 $6 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
fi
