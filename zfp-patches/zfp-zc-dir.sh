#!/bin/bash

if [[ $# < 4 ]]
then
	echo "Usage - option 1: $0 [datatype (-f or -d)] [errBoundMode] [error bound] [data directory] [extension] [dimension sizes....]"
	echo "      - option 2: $0 [datatype (-f or -d)] [errBoundMode] [error bound] [varListFile]"
	echo "Example: $0 -f ABS 1E-4 /home/fti/SZ_C_version/CESM-testdata/1800x3600 3600 1800"
	exit
fi

datatype=$1
errBoundMode=$2
absErrBound=$3
if [ -d $4 ]; then
	option=1
else
	option=0
fi

if [[ $option == 1 ]]; then
	dataDir="$4"
	extension=$5
	dim1=$6
	dim2=$7
	dim3=$8
	dim4=$9
else
	varListFile=$4
fi

if [[ $option == 1 ]]; then
	fileList=`cd "$dataDir";ls *.${extension}`
	for file in $fileList
	do
		echo ./zfp-zc.sh $datatype $errBoundMode ${dataDir}/${file} ${file} $absErrBound $dim1 $dim2 $dim3 $dim4
		./zfp-zc.sh $datatype $errBoundMode "${dataDir}/${file}" ${file} $absErrBound $dim1 $dim2 $dim3 $dim4
	done
else
	nbVars=`./queryVarList -n -i $varListFile`
	for (( i = 0; i < nbVars; i++)); do
		varName=`./queryVarList -m -I $i -i $varListFile`
		file=`./queryVarList -f -I $i -i $varListFile`
		dims=`./queryVarList -d -I $i -i $varListFile`
        	echo ./zfp-zc.sh $datatype $errBoundMode "$file" $varName $absErrBound $dims
        	./zfp-zc.sh $datatype $errBoundMode "$file" $varName $absErrBound $dims
	done
fi

echo "complete"

