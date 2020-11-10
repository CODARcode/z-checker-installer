#!/bin/bash

mgardpath=`abspath ../compressor-install`
if [ ! -f "$mgardpath" ]; then
	cp Makefile_LIBP_MGARD ../libpressio/test/Makefile
	cp mgarddouble_CompDecomp.c ../libpressio/test
	cp mgardfloat_CompDecomp.c ../libpressio/test

	cd ../libpressio/test
	make
fi
