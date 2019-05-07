#!/bin/bash

if [ $# != 1 ]
then
        echo Usage: $0 [workspace name]
        echo Example: $0 CESM-ATM
        exit
fi

workspace=$1

mkdir -p ../SZ/${workspace}_deft/compressionResults
echo mv compressionResults/SZ* ../SZ/${workspace}_deft/compressionResults
mv compressionResults/SZ* ../SZ/${workspace}_deft/compressionResults

mkdir -p ../zfp/${workspace}/compressionResults
echo mv compressionResults/ZFP* ../zfp/${workspace}/compressionResults
mv compressionResults/ZFP* ../zfp/${workspace}/compressionResults

mkdir -p ../Z-checker/${workspace}/dataProperties
echo mv dataProperties/* ../Z-checker/${workspace}/dataProperties
mv dataProperties/* ../Z-checker/${workspace}/dataProperties

rm -rf compressionResults
rm -rf dataProperties

echo The dataProperties and compressionResults have been moved to the workspace $workspace
echo done
