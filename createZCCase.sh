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
cp ../zc-patches/zc.config ./examples
./createNewCase.sh $caseName
cp ../zc-patches/queryVarList $caseName
cp ./examples/delCompressorZCConfig $caseName
cd ..

cp ./zc-patches/zc.config zc.config.tmp
Z-checker/examples/modifyZCConfig ./zc.config.tmp checkingStatus PROBE_COMPRESSOR

##begin: Compressor sz_d
echo Create a new case for sz_d
cd $rootDir
cd SZ
cp example/sz-zc-vis $rootDir/Z-checker/$caseName
sz_deft_caseName=${caseName}_deft
mkdir -p $sz_deft_caseName
cd $sz_deft_caseName
ln -s $rootDir/errBounds.cfg errBounds.cfg
cp $rootDir/zc.config.tmp ./zc.config

#cp $rootDir/sz-patches/*.sh .
cp $rootDir/sz-patches/test_CompDecomp.sh .
cp $rootDir/zc-patches/exe_CompDecomp.sh .
cp $rootDir/zc-patches/zc-ratedistortion.sh .
ln -s $rootDir/manageCompressor-sz-d.cfg manageCompressor.cfg
ln -s $rootDir/manageCompressor manageCompressor
./manageCompressor -z sz_d -c ./manageCompressor.cfg
cd $rootDir
cp SZ/example/./testfloat_CompDecomp_libpressio SZ/$sz_deft_caseName/./testfloat_CompDecomp
cp SZ/example/./testdouble_CompDecomp_libpressio SZ/$sz_deft_caseName/./testdouble_CompDecomp
cp sz-patches/sz.config.default_mode SZ/$sz_deft_caseName/sz.config
cd SZ/$sz_deft_caseName
cp $rootDir/zc-patches/queryVarList .
##end: Compressor sz_d

##begin: Compressor zfp
cd $rootDir
echo Create a new case for ZFP
cd zfp
cp bin/zfp-zc-vis $rootDir/Z-checker/$caseName
zfp_caseName=${caseName}
if [ ! -d $zfp_caseName ]; then
        mkdir $zfp_caseName
fi
cp ../zfp-patches/*.sh $zfp_caseName
cp $rootDir/zc.config.tmp $zfp_caseName/zc.config
cp $rootDir/zc-patches/queryVarList $zfp_caseName
##end: Compressor zfp

##New compressor to be added here

cd $rootDir/zc-patches

echo Modify Z-checker/$caseName/zc.config
cd ../Z-checker/$caseName
./modifyZCConfig zc.config compressors "sz_d:../../SZ/${sz_deft_caseName} zfp:../../zfp/${zfp_caseName}"

rm $rootDir/zc.config.tmp
