#!/bin/bash

cp Makefile.linux2 ../Z-checker/HDF5Reader

cd ../Z-checker/HDF5Reader
make -f Makefile.linux2 clean
make -f Makefile.linux2
cd -
ln -f -s ../Z-checker/HDF5Reader/test/testHDF5_CompDecomp testHDF5_CompDecomp
ln -f -s ../removeZCCase.sh removeZCCase.sh
ln -f -s ../Z-checker Z-checker
ln -f -s ../SZ SZ
ln -f -s ../zfp zfp
