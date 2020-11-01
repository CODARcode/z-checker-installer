#include <libpressio.h>
#include <libpressio_ext/io/posix.h>
#include <bg.h>
#include <iostream>

#include "zc.h"

size_t computeDataLength(size_t r5, size_t r4, size_t r3, size_t r2, size_t r1, int* dim)
{
	size_t dataLength;
	if(r1==0) 
	{
		dataLength = 0;
	}
	else if(r2==0) 
	{
		dataLength = r1;
		*dim = 1;
	}
	else if(r3==0) 
	{
		dataLength = r1*r2;
		*dim = 2;
	}
	else if(r4==0) 
	{
		dataLength = r1*r2*r3;
		*dim = 3;
	}
	else if(r5==0) 
	{
		dataLength = r1*r2*r3*r4;
		*dim = 4;
	}
	else 
	{
		dataLength = r1*r2*r3*r4*r5;
		*dim = 5;
	}
	return dataLength;
}

int main(int argc, char *argv[])
{
  struct pressio* library = pressio_instance();
  struct pressio_compressor* compressor = pressio_get_compressor(library, "bit_grooming");
  struct pressio_options* bit_grooming_options = pressio_compressor_get_options(compressor);

  size_t r5=0,r4=0,r3=0,r2=0,r1=0, i = 0;
  char outDir[640], oriFilePath[640], outputFilePath[640];
  char *zcFile, *solName, *varName;
  int nsd;
  if(argc < 7)
  {
        printf("Test case: bgdouble_CompDecomp [config_file] [solName] [varName] [nsd] [srcFilePath] [dimension sizes...]\n");
        printf("Example: bgdouble_CompDecomp zc.config sol var 5 testdata/x86/testdouble_8_8_128.dat 8 8 128\n");
        exit(0);
  }

  zcFile=argv[1];
  solName=argv[2];
  varName=argv[3];
  nsd = atoi(argv[4]);
  

 
  sprintf(oriFilePath, "%s", argv[5]);
  if(argc>=7)
	r1 = atoi(argv[6]); //8
  if(argc>=8)
	r2 = atoi(argv[7]); //8
  if(argc>=9)
	r3 = atoi(argv[8]); //128
  if(argc>=10)
  	r4 = atoi(argv[9]);
  if(argc>=11)
  	r5 = atoi(argv[10]);

  size_t dims[5];
  dims[0] = r1;
  dims[1] = r2;
  dims[2] = r3;
  dims[3] = r4;
  dims[4] = r5;
  int dim = (dims[0] != 0) +(dims[1] != 0)+(dims[2] != 0)+(dims[3] != 0)+(dims[4] != 0);
  
  struct pressio_data* input_buffer = pressio_data_new_owning(pressio_double_dtype, dim, dims);
  struct pressio_data* input_data = pressio_io_data_path_read(input_buffer, oriFilePath);
  double* data = (double*)pressio_data_ptr(input_data, NULL);


  
  // configure the compressor
    
   pressio_options_set_integer(bit_grooming_options, "bit_grooming:n_sig_digits", nsd);
   
   if(pressio_compressor_check_options(compressor, bit_grooming_options)) {
    printf("%s\n", pressio_compressor_error_msg(compressor));
    exit(pressio_compressor_error_code(compressor));
  }
  if(pressio_compressor_set_options(compressor, bit_grooming_options)) {
    printf("%s\n", pressio_compressor_error_msg(compressor));
    exit(pressio_compressor_error_code(compressor));
  }

   

  //creates an output dataset pointer
  struct pressio_data* compressed_data = pressio_data_new_empty(pressio_byte_dtype, 0, NULL);

  //configure the decompressed output area
  struct pressio_data* decompressed_data = pressio_data_new_clone(input_data);

  ZC_Init(zcFile);

  //compress the data
  data = (double*)pressio_data_ptr(input_data,NULL);
  ZC_DataProperty* dataProperty = ZC_startCmpr(varName, ZC_DOUBLE, data, r5, r4, r3, r2, r1);
  if(pressio_compressor_compress(compressor, input_data, compressed_data)) {
    printf("%s\n", pressio_compressor_error_msg(compressor));
    exit(pressio_compressor_error_code(compressor));
  }
  size_t outSize = pressio_data_get_bytes(compressed_data);
  ZC_CompareData* compareResult = ZC_endCmpr(dataProperty, solName, outSize);


  //decompress the data
  ZC_startDec();
  if(pressio_compressor_decompress(compressor, compressed_data, decompressed_data)) {
    printf("%s\n", pressio_compressor_error_msg(compressor));
    exit(pressio_compressor_error_code(compressor));
  }
  void* dec_data= pressio_data_ptr(decompressed_data, NULL);
  ZC_endDec(compareResult, dec_data);

  // //free the input, decompressed, and compressed data
  pressio_data_free(decompressed_data);
  pressio_data_free(compressed_data);
  pressio_data_free(input_data);

  //free options and the library
  pressio_compressor_release(compressor);
  pressio_release(library);
  return 0;
}
