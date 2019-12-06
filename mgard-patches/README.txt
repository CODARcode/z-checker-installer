In order to generate compression results for MGARD, you need to do the following steps: 


cp Makefile_LIBP_MGARD ../libpressio/test/Makefile
cp mgarddouble_CompDecomp.c ../libpressio/test
cp mgardfloat_CompDecomp.c ../libpressio/test

cd ../libpressio/test
make


test:
mgardfloat_CompDecomp zc.config "mgard(1E-2)" var ABS 1E-2 ~/Development/SZ_C_Version/sz-2.1.6/example/testdata/x86/testfloat_8_8_128.dat 8 8 128
mgarddouble_CompDecomp zc.config "mgard(1E-2)" var ABS 1E-2 ~/Development/SZ_C_Version/sz-2.1.6/example/testdata/x86/testdouble_8_8_128.dat 8 8 128

