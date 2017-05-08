#!/bin/bash

if [ $# != 1 ]
then
        echo Usage: please specify a unique case directory name.
        echo Example: $0 case1 
        exit
fi

caseName=$1

echo Create a new case $caseName for Z-checker
cd Z-checker
./createNewCase.sh $caseName

echo "Create a new case (fast mode) for SZ"
cd ../SZ
sz_caseName=${caseName}_fast
mkdir $sz_caseName
cp example/sz-zc-ratedistortion.sh $sz_caseName
cp example/testfloat_CompDecomp $sz_caseName
cp example/testfloat_CompDecomp.sh $sz_caseName
cp ../sz-patches/sz.config.fast_mode $sz_caseName/sz.config

echo "Create a new case (default mode) for SZ"
cd ../SZ
sz_caseName=${caseName}_deft
mkdir $sz_caseName
cp example/sz-zc-ratedistortion.sh $sz_caseName
cp example/testfloat_CompDecomp $sz_caseName
cp example/testfloat_CompDecomp.sh $sz_caseName
cp ../sz-patches/sz.config.default_mode $sz_caseName/sz.config

echo Create a new case for ZFP
cd ../zfp
zfp_caseName=${caseName}
mkdir $zfp_caseName
cp utils/*.sh $zfp_caseName

echo Modify Z-checker/$caseName/zc.config
cd Z-checker/$caseName
modifyZCConfig zc.config compressors "sz_f:../../SZ/${caseName}_fast sz_d:../../SZ/${caseName}_deft zfp:../../zfp/${zfp_caseName}"
