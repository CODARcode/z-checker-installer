#!/bin/bash

if [ $# != 1 ]
then
        echo Usage: $0 [workspace name]
        echo Example: $0 CESM-ATM
        exit
fi

workspace=$1

rootDir=`pwd`

#copy results to sz_workspace
sz_workspace=SZ/${workspace}_deft
mkdir -p $sz_workspace/compressionResults
echo mv compressionResults/SZ* $sz_workspace/compressionResults
mv compressionResults/SZ* $sz_workspace/compressionResults

#copy results to zfp_workspace
zfp_workspace=zfp/${workspace}
mkdir -p $zfp_workspace/compressionResults
echo mv compressionResults/ZFP* $zfp_workspace/compressionResults
mv compressionResults/ZFP* $zfp_workspace/compressionResults

#create scripts for Z-checker workspace
cd Z-checker
if [ ! -d $workspace ];then
	./createNewCase.sh $workspace
	mkdir -p $workspace/dataProperties
	echo mv dataProperties* $workspace/dataProperties
	mv $rootDir/dataProperties/* $workspace/dataProperties
else
	echo Error: $workspace already exits!
	echo Please remove it using removeZCCase.sh.

	rm -rf $rootDir/compressionResults
	rm -rf $rootDir/dataProperties
	exit
fi

#modify zc.config based on compression cases
cd $workspace
./modifyZCConfig zc.config compressors "sz_d:../../SZ/${workspace}_deft zfp:../../zfp/${workspace}"

#remove useless files
cd $rootDir
rm -rf compressionResults
rm -rf dataProperties

echo The dataProperties and compressionResults have been moved to the workspace $workspace
echo done
