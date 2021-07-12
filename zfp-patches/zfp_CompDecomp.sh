#!/bin/bash

if [ $# -lt 5 ]
then
	echo "Usage: $0 [zc_cfgFile] cmpCase datatype varName errBoundMode errBound filePath dim1 dim2 dim3 dim4 ...."
	exit
fi

cmdDir=../bin

zc_cfgFile=$1
cmpCase=$2
datatype=$3
varName=$4
errBoundMode=$5
errBound=$6
dataFilePath=$7
dim1=$8
dim2=$9
dim3=${10}
dim4=${11}

dim=$(($#-7))

if [[ $errBoundMode == "ABS" ]]; then
	if [[ $dim == 1 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	elif [[ $dim == 2 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	elif [[ $dim == 3 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	elif [[ $dim == 4 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 $dim4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 $dim4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	fi
elif [[ $errBoundMode == "REL" ]]; then
	if [[ $dim == 1 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
	elif [[ $dim == 2 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
	elif [[ $dim == 3 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
	elif [[ $dim == 4 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 $dim4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
		${cmdDir}/zfp-zc -s $datatype -a ${errBound} -${dim} $dim1 $dim2 $dim3 $dim4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}" -l
	fi
elif [[ $errBoundMode == "PW_REL" ]]; then
	if [[ $dim == 1 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	elif [[ $dim == 2 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 $dim2 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 $dim2 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	elif [[ $dim == 3 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 $dim2 $dim3 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 $dim2 $dim3 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	elif [[ $dim == 4 ]]
	then
		echo ${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 $dim2 $dim3 $dim4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
		${cmdDir}/zfp-zc -s $datatype -p ${errBound} -${dim} $dim1 $dim2 $dim3 $dim4 -i ${dataFilePath} -k "zfp(${errBound})" -v "${varName}"
	fi
fi
