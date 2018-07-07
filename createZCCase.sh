#!/bin/bash

if [ $# != 1 ]
then
        echo Usage: please specify a unique case directory name.
        echo Example: $0 case1 
        exit
fi

caseName=$1

rootDir=`pwd`

if [ ! -d Z-checker ]; then
	echo "Error: missing Z-checker directory. "
	echo "Please run z-checker-install.sh first."
	exit
fi

echo Create a new case $caseName for Z-checker
if [ -d Z-checker/$caseName ]; then
	echo "Conflict: the case $caseName already exists."
	echo "Please remove the existing case using removeZCCase.sh before creating the same one."
	exit
fi
cd Z-checker
./createNewCase.sh $caseName
cp ../zc-patches/queryVarList $caseName
cd ..

##begin: Compressor sz_f
echo Create a new case for sz_f
cd $rootDir
cd ./SZ
sz_fast_caseName=${caseName}_fast
mkdir -p $sz_fast_caseName
cd $sz_fast_caseName
cp $rootDir/zc-patches/test_CompDecomp.sh .
cp $rootDir/zc-patches/zc-ratedistortion.sh .
ln -s $rootDir/errBounds.cfg errBounds.cfg
ln -s $rootDir/manageCompressor-sz-f.cfg manageCompressor.cfg
ln -s $rootDir/manageCompressor manageCompressor
cp $rootDir/Z-checker/examples/zc.config ./SZ/$sz_fast_caseName
./manageCompressor -z sz_f -c ./manageCompressor-sz-f.cfg
cd $rootDir
cp ./SZ/example/./testfloat_CompDecomp ./SZ/$sz_fast_caseName/./testfloat_CompDecomp
cp sz-patches/sz.config.fast_mode .SZ/$sz_fast_caseName/sz.config
cd ./SZ/$sz_fast_caseName
patch -p0 < $rootDir/zc-patches/zc-probe.config.patch
cp $rootDir/zc-patches/queryVarList .
##end: Compressor sz_f

##begin: Compressor sz_d
echo Create a new case for sz_d
cd $rootDir
cd SZ
sz_deft_caseName=${caseName}_deft
mkdir -p $sz_deft_caseName
cd $sz_deft_caseName
cp $rootDir/zc-patches/test_CompDecomp.sh .
cp $rootDir/zc-patches/zc-ratedistortion.sh .
ln -s $rootDir/errBounds.cfg errBounds.cfg
ln -s $rootDir/manageCompressor-sz-d.cfg manageCompressor.cfg
ln -s $rootDir/manageCompressor manageCompressor
cp $rootDir/Z-checker/examples/zc.config ./$sz_deft_caseName
./manageCompressor -z sz_d -c ./manageCompressor-sz-d.cfg
cd $rootDir
cp SZ/example/./testfloat_CompDecomp SZ/$sz_deft_caseName/./testfloat_CompDecomp
cp sz-patches/sz.config.default_mode SZ/$sz_deft_caseName/sz.config
cd SZ/$sz_deft_caseName
patch -p0 < $rootDir/zc-patches/zc-probe.config.patch
cp $rootDir/zc-patches/queryVarList .
##end: Compressor sz_d

##begin: Compressor zfp
cd $rootDir
echo Create a new case for ZFP
cd zfp
zfp_caseName=${caseName}
if [ ! -d $zfp_caseName ]; then
        mkdir $zfp_caseName
fi
cp ../zfp-patches/*.sh $zfp_caseName
cp utils/zc.config $zfp_caseName
cp $rootDir/zc-patches/queryVarList $zfp_caseName
##end: Compressor zfp

##New compressor to be added here

cd $rootDir/zc-patches

echo Modify Z-checker/$caseName/zc.config
cd ../Z-checker/$caseName
./modifyZCConfig zc.config compressors " sz_f:/home/sdi/Development/z-checker-installer/z-checker-installer/SZ/${sz_fast_caseName} sz_d:/home/sdi/Development/z-checker-installer/z-checker-installer/SZ/${sz_deft_caseName} zfp:/home/sdi/Development/z-checker-installer/z-checker-installer/zfp/${zfp_caseName}"
