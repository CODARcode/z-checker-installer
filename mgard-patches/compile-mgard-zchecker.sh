#!/bin/bash
cp Makefile_LIBP_MGARD ../libpressio/test/Makefile
cp mgarddouble_CompDecomp.c ../libpressio/test
cp mgardfloat_CompDecomp.c ../libpressio/test

cd ../libpressio/test
make

