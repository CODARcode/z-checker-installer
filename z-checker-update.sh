#!/bin/bash

rootDir=`pwd`

#---------- download Z-checker --------------
cd Z-checker
git pull
make
make install
cp ../zc-patches/generateReport.sh ./examples/

cd examples
make clean
make

#---------- download ZFP and set the configuration -----------
cd $rootDir
cd zfp
git pull
make

cd -
cp zfp-patches/zfp-zc.c zfp/utils
cp zfp-patches/*.sh zfp/utils

make

#---------- download SZ and set the configuration -----------
cd $rootDir
cd SZ
git pull
make
make install

cd example
cp ../../Z-checker/examples/zc.config .
cp ../../sz-patches/sz-zc-ratedistortion.sh .
cp ../../sz-patches/testfloat_CompDecomp.sh .

make clean
make
