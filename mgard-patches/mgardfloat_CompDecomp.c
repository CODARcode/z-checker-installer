#include <libpressio.h>
#include <libpressio_ext/io/posix.h>
#include <mgard.h>

#include "make_input_data.h"
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
  struct pressio_compressor* compressor = pressio_get_compressor(library, "mgard");
  struct pressio_options* mgard_options = pressio_compressor_get_options(compressor);

  size_t r5=0,r4=0,r3=0,r2=0,r1=0, i = 0;
  char outDir[640], oriFilePath[640], outputFilePath[640];
  char *zcFile, *solName, *varName, *errBoundMode;
  double errBound;
  int errboundmode;
  if(argc < 9)
  {
        printf("Test case: mgardfloat_CompDecomp [config_file] [zc.config] [solName] [varName] [errBoundMode] [ErrBound] [srcFilePath] [dimension sizes...]\n");
        printf("Example: mgardfloat_CompDecomp zc.config mgard(1E-2) var ABS 1E-2 testdata/x86/testfloat_8_8_128.dat 8 8 128\n");
        exit(0);
  }

  zcFile=argv[1];
  solName=argv[2];
  varName=argv[3];
  errBoundMode=argv[4];
  if(strcmp(errBoundMode, "ABS")==0)
  {
        errboundmode = 0;
  }
  else if(strcmp(errBoundMode, "REL")==0)
  {
        errboundmode = 1;
  }
  else
  {
        printf("Error: Z-checker checking doesn't support this error bound mode: %s, but only ABS, REL for MGARD.\n", errBoundMode);
        exit(0);
  }

  errBound=atof(argv[5]);
  sprintf(oriFilePath, "%s", argv[6]);
  if(argc>=8)
	r1 = atoi(argv[7]); //8
  if(argc>=9)
	r2 = atoi(argv[8]); //8
  if(argc>=10)
	r3 = atoi(argv[9]); //128
  if(argc>=11)
        r4 = atoi(argv[10]);
  if(argc>=12)
        r5 = atoi(argv[11]);

  size_t dims[5];
  dims[0] = r1;
  dims[1] = r2;
  dims[2] = r3;
  dims[3] = r4;
  dims[4] = r5;
  int dim = (dims[0] != 0) +(dims[1] != 0)+(dims[2] != 0)+(dims[3] != 0)+(dims[4] != 0);
  
  struct pressio_data* input_buffer = pressio_data_new_owning(pressio_float_dtype, dim, dims);
  struct pressio_data* input_data = pressio_io_data_path_read(input_buffer, oriFilePath);
  float* data = (float*)pressio_data_ptr(input_data, NULL);

  //compute the L-inf value of data
  float L_inf_value = 0, value, max, min;
  min = data[0];
  max = min;
  for(i=0;i<pressio_data_num_elements(input_data);i++)
  {
	value = data[i];
	if(min > value) min = value;
	if(max < value) max = value;
  }
  L_inf_value = fabs(min) > fabs(max)? fabs(min) : fabs(max);
  float valueRange = max - min;  

  //compute the error bound that can be recognized by mgard
  float linfErrBound = 0, absErrBound = 0;
  if(errboundmode==0)
	absErrBound = errBound;
  else if(errboundmode==1)
	absErrBound = errBound*valueRange;
  linfErrBound = absErrBound/L_inf_value;

  if(errboundmode==0)
	printf("mode=ABS, error bound setting=%f, actual absErrBound=%f, linfErrBound=%f\n", errBound, absErrBound, linfErrBound);
  else 
	printf("mode=REL, error bound setting=%f, actual absErrBound=%f, linfErrBound=%f\n", errBound, absErrBound, linfErrBound);
  pressio_options_set_float(mgard_options, "mgard:tolerance", linfErrBound);

  if(pressio_compressor_check_options(compressor, mgard_options)) {
    printf("%s\n", pressio_compressor_error_msg(compressor));
    exit(pressio_compressor_error_code(compressor));
  }
  if(pressio_compressor_set_options(compressor, mgard_options)) {
    printf("%s\n", pressio_compressor_error_msg(compressor));
    exit(pressio_compressor_error_code(compressor));
  }
   

  //creates an output dataset pointer
  struct pressio_data* compressed_data = pressio_data_new_empty(pressio_byte_dtype, 0, NULL);

  //configure the decompressed output area
  struct pressio_data* decompressed_data = pressio_data_new_clone(input_data);

  ZC_Init(zcFile);

  //compress the data
  data = (float*)pressio_data_ptr(input_data,NULL);
  ZC_DataProperty* dataProperty = ZC_startCmpr(varName, ZC_FLOAT, data, r5, r4, r3, r2, r1);
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

  //free the input, decompressed, and compressed data
  pressio_data_free(decompressed_data);
  pressio_data_free(compressed_data);
  pressio_data_free(input_data);

  //free options and the library
  pressio_options_free(mgard_options);
  pressio_compressor_release(compressor);
  pressio_release(library);
  return 0;
}
