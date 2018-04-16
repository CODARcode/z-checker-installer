#!/bin/bash

rootDir=`pwd`

git pull

if [ ! -d Z-checker ]; then
	echo "Error: no Z-checker directory."
	echo "Please use z-checker-installer.sh to perform the installation first."
	exit
fi

#---------- download Z-checker --------------
cd $rootDir

#backup zc.config
cp Z-checker/examples/zc.config ./zc.config.bk

#pull Z-checker
cd Z-checker
cd examples
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ../zc

git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ../template

git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ..

./configure --prefix=$rootDir/Z-checker/zc-install
make clean
make
make install
cp ../zc-patches/generateReport.sh ./examples/

cd examples
make clean
make

#--------- compile codes in zc-patches-------
cd $rootDir/zc-patches
gcc -O3 -o queryVarList queryVarList.c
gcc -g -O3 -o manageCompressor manageCompressor.c -I../Z-checker/zc-install/include ../Z-checker/zc-install/lib/libzc.a -lm
mv manageCompressor ..

#---------- download ZFP and set the configuration -----------
cd $rootDir
cd zfp
git pull

cd -
cp zfp-patches/zfp-zc.c zfp/utils
#cp zfp-patches/*.sh zfp/utils

cd zfp
make
cd utils

cp ../../Z-checker/examples/zc.config .
patch -p0 < ../../zc-patches/zc-probe.config.patch

make clean
make
cd ..

#---------- download SZ and set the configuration -----------
cd $rootDir
cd SZ
cd sz
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd src
#patch -p1 < ../../../sz-patches/sz-src-hacc.patch

cd ../../
./configure --prefix=$rootDir/SZ/sz-install
make
make install

cd example
patch -p0 < ../../sz-patches/Makefile-zc.bk.patch
make clean -f Makefile.bk
make -f Makefile.bk

cp ../../Z-checker/examples/zc.config .
patch -p0 < ../../zc-patches/zc-probe.config.patch
cp ../../sz-patches/sz-zc-ratedistortion.sh .
cp ../../sz-patches/testfloat_CompDecomp.sh .
cp ../../sz-patches/testdouble_CompDecomp.sh .

cd $rootDir
#cp zc.config.bk Z-checker/examples/zc.config
if [ ! -f zc.config ]
then
	ln -s $rootDir/Z-checker/examples/zc.config zc.config
fi
