#!/bin/bash

cd ../Z-checker/HDF5Reader
make -f Makefile.linux2 clean
make -f Makefile.linux2
cd -
cd testHDF5
ln ../Z-checker/HDF5Reader/test/testHDF5_CompDecomp testHDF5_CompDecomp

cp ../zc-patches/runZCCase_hdf5.sh



