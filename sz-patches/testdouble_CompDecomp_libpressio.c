/**
 *  @file testdouble_CompDecomp_libpressio.c
 *  @author Sheng Di
 *  @date April, 2015
 *  @brief This is an example of using compression interface
 *  (C) 2015 by Mathematics and Computer Science (MCS), Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sz.h"
#include "rw.h"
#include "zc.h"
#include <libpressio.h>
#include <libpressio_ext/io/posix.h>

int main(int argc, char * argv[])
{
    size_t r5=0,r4=0,r3=0,r2=0,r1=0;
    char outDir[640], oriFilePath[640], outputFilePath[640];
    char *cfgFile, *zcFile, *solName, *varName, *errBoundMode;
    double absErrBound;
    int errboundmode;
    if(argc < 9)
    {
	printf("Test case: testdouble_CompDecomp_libpressio [config_file] [zc.config] [solName] [varName] [errBoundMode] [err bound] [srcFilePath] [dimension sizes...]\n");
	printf("Example: testdouble_CompDecomp_libpressio sz.config zc.config sz(1E-6) testdouble ABS 1E-6 testdata/x86/testdouble_8_8_128.dat 8 8 128\n");
	exit(0);
    }
   
    cfgFile=argv[1];
    zcFile=argv[2];
    solName=argv[3];
    varName=argv[4];
    errBoundMode=argv[5];
    if(strcmp(errBoundMode, "PW_REL")==0) 
    {
	errboundmode = PW_REL;
    }
    else if(strcmp(errBoundMode, "ABS")==0)
    {
	errboundmode = ABS;
    }
    else if(strcmp(errBoundMode, "REL")==0)
    {
	errboundmode = REL;
    }
    else
    {
	printf("Error: Z-checker checking doesn't support this error bound mode: %s, but only ABS, REL, and PW_REL.\n", errBoundMode);
	exit(0); 
    }

    int dim = 0;
    absErrBound=atof(argv[6]);
    sprintf(oriFilePath, "%s", argv[7]);
    if(argc>=9)
    {
	r1 = atoi(argv[8]); //8
	dim ++;
    }
    if(argc>=10)
    {
	r2 = atoi(argv[9]); //8
	dim ++;
    }
    if(argc>=11)
    {
	r3 = atoi(argv[10]); //128
	dim ++;
    }
    if(argc>=12)
    {
        r4 = atoi(argv[11]);
	dim ++;
    }
    if(argc>=13)
    {
        r5 = atoi(argv[12]);
	dim ++;
    }

    struct pressio* library = pressio_instance();
    struct pressio_compressor* compressor = pressio_get_compressor(library, "sz");
    struct pressio_options* sz_options = pressio_compressor_get_options(compressor);

    pressio_options_set_integer(sz_options, "sz:error_bound_mode", errboundmode);
    if(errboundmode == ABS)
	pressio_options_set_double(sz_options, "sz:abs_err_bound", absErrBound);
    else if(errboundmode == REL)
	pressio_options_set_double(sz_options, "sz:rel_err_bound", absErrBound);

    pressio_options_set_string(sz_options, "sz:config_file", cfgFile);

    if(pressio_compressor_check_options(compressor, sz_options)) {
	printf("%s\n", pressio_compressor_error_msg(compressor));
	exit(pressio_compressor_error_code(compressor));
    }
    if(pressio_compressor_set_options(compressor, sz_options)) {
	printf("%s\n", pressio_compressor_error_msg(compressor));
	exit(pressio_compressor_error_code(compressor));
    }
   
    printf("zcFile=%s\n", zcFile);
    ZC_Init(zcFile);
 
    sprintf(outputFilePath, "%s.sz", oriFilePath);
  
    size_t rdim[5] = {r1, r2, r3, r4, r5};
    struct pressio_data* dims = pressio_data_new_empty(pressio_double_dtype, dim, rdim);
    struct pressio_data* input_data = pressio_io_data_path_read(dims, oriFilePath);
    struct pressio_data* decompressed_data = pressio_data_new_clone(input_data);
    struct pressio_data* compressed_data = pressio_data_new_empty(pressio_byte_dtype, 0, NULL);
    double* data = pressio_data_ptr(input_data, NULL);
   
    ZC_DataProperty* dataProperty = ZC_startCmpr(varName, ZC_DOUBLE, data, r5, r4, r3, r2, r1);
    
    if(pressio_compressor_compress(compressor, input_data, compressed_data)) {
        printf("%s\n", pressio_compressor_error_msg(compressor));
        exit(pressio_compressor_error_code(compressor));
    }

    size_t outSize;
    unsigned char* compressed_bytes = pressio_data_ptr(compressed_data, &outSize);
    ZC_CompareData* compareResult = ZC_endCmpr(dataProperty, solName, outSize);
    //writeByteData(bytes, outSize, outputFilePath, &status);
   
    ZC_startDec();
    if(pressio_compressor_decompress(compressor, compressed_data, decompressed_data)) {
        printf("%s\n", pressio_compressor_error_msg(compressor));
        exit(pressio_compressor_error_code(compressor));
    }    
    double* decData = pressio_data_ptr(decompressed_data, NULL);
    ZC_endDec(compareResult, decData);
    //ZC_endDec(compareResult, "sz(1E-7)", decData);

    freeDataProperty(dataProperty);
    freeCompareResult(compareResult);
    pressio_data_free(input_data);
    pressio_data_free(compressed_data);
    pressio_data_free(decompressed_data);
    pressio_options_free(sz_options);
    pressio_compressor_release(compressor);
    pressio_release(library);

    printf("done\n");
    
    ZC_Finalize();
    return 0;
}
