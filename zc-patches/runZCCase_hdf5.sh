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
echo mv compressionResults/ZFP* ../ZFP/${workspace}/compressionResults
mv compressionResults/ZFP* ../ZFP/${workspace}/compressionResults

mkdir -p ../Z-checker/${workspace}/dataProperties
echo mv dataProperties/* ../Z-checker/${workspace}/dataProperties
mv dataProperties/* ../Z-checker/${workspace}/dataProperties

echo The compression results have been stored in the workspace $workspace
echo done
