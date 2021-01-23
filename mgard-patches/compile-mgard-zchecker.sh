#!/bin/bash

mgardpath=$(readlink -f ../compressor-install/lib/libmgard.so)
if [ -f "$mgardpath" ]; then
	cp Makefile_LIBP_MGARD ../libpressio/test/Makefile
	cp mgarddouble_CompDecomp.c ../libpressio/test
	cp mgardfloat_CompDecomp.c ../libpressio/test

	cd ../libpressio/test
	make
fi
