#!/bin/bash

if [ $# != 1 ] 
then
	echo Usage: $0 [dataSetName]
	echo Example: $0 CESM-ATM-Tylor-Data
	exit
fi

dataSetName=$1
patch -p0 < ../../zc-patches/zc-compare.config.patch

echo ./generateGNUPlot zc.config
./generateGNUPlot zc.config

mkdir compareCompressors
mv *.eps compareCompressors/

mkdir compareCompressors/data
mv *_*.txt compareCompressors/data

mkdir compareCompressors/gnuplot_scripts
mv *.p compareCompressors/gnuplot_scripts 

echo ./generateReport zc.config $dataSetName
./generateReport zc.config $dataSetName

patch -RE -p0 < ../../zc-patches/zc-compare.config.patch
