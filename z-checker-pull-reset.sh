#!/bin/bash

rootDir=`pwd`

#---------- download tif22pnm ---------------
TIF22PNM_URL="https://github.com/pts/tif22pnm.git"
TIF22PNM_SRC_DIR=$rootDir/tif22pnm

TIF22PNM_EXE_PATH=`which png22pnm`
if [ ! -x "$TIF22PNG_EXE_PATH" ]; then
        if [ ! -d "$TIF22PNG_SRC_DIR" ]; then
                # download tif22pnm source
                git clone $TIF22PNM_URL
                if [ ! -d "$TIF22PNM_SRC_DIR" ] ; then
                        echo "FATAL: cannot download and extract tif22pnm source."
                        exit
                fi

                # compile tif22pnm
                cd $TIF22PNM_SRC_DIR
                ./configure
                ./do.sh compile
                cd $rootDir
                echo "export PNG22PNM_HOME=$TIF22PNM_SRC_DIR" > $rootDir/env_config.sh
                echo "export PATH=\$PATH:\$PNG22PNM_HOME" >> $rootDir/env_config.sh
        fi

fi

#---------- download sam2p --------------------
SAM2P_URL="https://github.com/pts/tif22pnm.git"
SAM2P_SRC_DIR=$rootDir/sam2p

SAM2P_EXE_PATH=`which sam2p`
if [ ! -x "$SAM2P_EXE_PATH" ]; then
        if [ ! -d "$SAM2P_SRC_DIR" ]; then
                # download sam2p source
                git clone $SAM2P_URL
                if [ ! -d "$SAM2P_SRC_DIR" ] ; then
                        echo "FATAL: cannot download and extract sam2p source."
                        exit
                fi

                # compile sam2p
                cd $SAM2P_SRC_DIR
                ./compile.sh
                cd $rootDir
                echo "export SAM2P_HOME=$SAM2P_SRC_DIR" > $rootDir/env_config.sh
                echo "export PATH=\$PATH:\$SAM2P_HOME" >> $rootDir/env_config.sh
        fi

fi

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
gcc -g -O3 -o manageCompressor manageCompressor.c -I../Z-checker/zc-install/include -L../Z-checker/zc-install/lib -lzc -lm -Wl,-rpath $rootDir/Z-checker/zc-install/lib
mv manageCompressor ..

#---------- download ZFP and set the configuration -----------
cd $rootDir
cd zfp/src

git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ../lib
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ../util
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull


cd ../..
cp zfp-patches/zfp-zc.c zfp/utils
#cp zfp-patches/*.sh zfp/utils

cd zfp
make
cd utils

cp ../../zc-patches/zc.config .
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

cp ../../zc-patches/zc.config .
patch -p0 < ../../zc-patches/zc-probe.config.patch
#cp ../../sz-patches/sz*-zc-ratedistortion.sh .
cp ../../sz-patches/testfloat_CompDecomp.sh .
cp ../../sz-patches/testdouble_CompDecomp.sh .

cd $rootDir
#cp zc.config.bk Z-checker/examples/zc.config
if [ ! -f zc.config ]
then
	ln -s $rootDir/zc-patches/zc.config zc.config
fi
