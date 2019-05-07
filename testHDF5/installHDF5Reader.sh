#!/bin/bash

cp Makefile.linux2 ../Z-checker/HDF5Reader

cd ../Z-checker/HDF5Reader
make -f Makefile.linux2 clean
make -f Makefile.linux2
cd -
ln -s ../Z-checker/HDF5Reader/test/testHDF5_CompDecomp testHDF5_CompDecomp
