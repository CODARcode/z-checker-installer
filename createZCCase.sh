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
cd ./SZ
sz_caseName=${caseName}_fast
mkdir -p $sz_caseName
cd $sz_caseName
cp $rootDir/zc-patches/test_CompDecomp.sh .
cp $rootDir/zc-patches/zc-ratedistortion.sh .
ln -s $rootDir/errBounds.cfg errBounds.cfg
ln -s /home/sdi/Development/z-checker-installer/z-checker-installer/manageCompressor-sz-f.cfg manageCompressor.cfg
ln -s $rootDir/manageCompressor manageCompressor
./manageCompressor -z sz_f -c ./manageCompressor.cfg
cd ./SZ/$sz_caseName
ln -s ./SZ/example/./testfloat_CompDecomp ./testfloat_CompDecomp
cd -
cp $rootDir/Z-checker/examples/zc.config .
cp SZ/example/sz.config ./SZ/$sz_caseName
patch -p0 < $rootDir/zc-patches/zc-probe.config.patch
cp $rootDir/zc-patches/queryVarList .
##end: Compressor sz_f

##begin: Compressor sz_d
echo "Create a new case (default mode) for SZ"
cd SZ
sz_caseName=${caseName}_deft
if [ ! -d $sz_caseName ]; then
	mkdir $sz_caseName
fi
cp ../zc-patches/queryVarList $sz_caseName

cp ../sz-patches/sz_d-zc-ratedistortion.sh $sz_caseName
#cp example/testfloat_CompDecomp.sh $sz_caseName
#cp example/testdouble_CompDecomp.sh $sz_caseName
cp ../sz-patches/testfloat_CompDecomp.sh $sz_caseName
cp ../sz-patches/testdouble_CompDecomp.sh $sz_caseName

cp example/zc.config $sz_caseName
cp ../sz-patches/sz.config.default_mode $sz_caseName/sz.config
cd $sz_caseName
ln -s "$rootDir/SZ/example/testfloat_CompDecomp" testfloat_CompDecomp
patch -p0 < ../../sz-patches/testfloat_CompDecomp_deft.sh.patch
ln -s "$rootDir/SZ/example/testdouble_CompDecomp" testdouble_CompDecomp
patch -p0 < ../../sz-patches/testdouble_CompDecomp_deft.sh.patch
cd ../..
##end: Compressor sz_d

##begin: Compressor zfp
echo Create a new case for ZFP
cd zfp
zfp_caseName=${caseName}
if [ ! -d $zfp_caseName ]; then
	mkdir $zfp_caseName
fi
cp ../zfp-patches/*.sh $zfp_caseName
cp utils/zc.config $zfp_caseName
cp $rootDir/zc-patches/queryVarList $zfp_caseName
cd ..
##end: Compressor zfp

##New compressor to be added here

cd $rootDir/zc-patches

echo Modify Z-checker/$caseName/zc.config
cd ../Z-checker/$caseName
./modifyZCConfig zc.config compressors "sz_d:../../SZ/${caseName}_deft zfp:../../zfp/${zfp_caseName} sz_f:./SZ/${sz_caseName}"
