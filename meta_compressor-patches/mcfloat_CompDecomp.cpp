#include "sz_compress_3d.hpp"
#include "sz_decompress_3d.hpp"
#include "sz_lossless.hpp"
#include <iostream>
#include <fstream>


#include "zc.h"

template<typename Type>
Type * readfile(char * file, size_t& num){
  std::ifstream fin(file, std::ios::binary);
  if(!fin){
        std::cout << " Error, Couldn't find the file" << "\n";
        return 0;
    }
    fin.seekg(0, std::ios::end);
    const size_t num_elements = fin.tellg() / sizeof(Type);
    fin.seekg(0, std::ios::beg);
    Type * data = (Type *) malloc(num_elements*sizeof(Type));
  fin.read(reinterpret_cast<char*>(&data[0]), num_elements*sizeof(Type));
  fin.close();
  num = num_elements;
  return data;
}

int main(int argc, char *argv[])
{

  size_t r3=0,r2=0,r1=0;
  size_t numElements, result_size;
  char oriFilePath[640];
  char *zcFile, *solName, *varName;
  double eb;
  if(argc != 9)
  {
        printf("incorrect number of arguments. meta_compressor only supports 3 dimensional data compression \n");
        printf("Test case: mcdouble_CompDecomp [config_file] [solName] [varName] [eb] [srcFilePath] [dimension sizes 1] [dimension sizes 2] [dimension sizes 3]\n");
        printf("Example: mcdouble_CompDecomp zc.config sol var 0.01 testdata/x86/testdouble_8_8_128.dat 8 8 128\n");
        exit(0);
  }

  zcFile=argv[1];
  solName=argv[2];
  varName=argv[3];
  eb = atof(argv[4]);
  

 
  sprintf(oriFilePath, "%s", argv[5]);
  if(argc>=7)
	 r1 = atoi(argv[6]); //8
  if(argc>=8)
	 r2 = atoi(argv[7]); //8
  if(argc>=9)
	 r3 = atoi(argv[8]); //128

  float* data = readfile<float>(oriFilePath, numElements);
  float max = data[0];
  float min = data[0];

  for(int i=1; i<numElements; i++)
  {
      if(max < data[i]) max = data[i];
      if(min > data[i]) min = data[i];
  }

  //start compress
  ZC_Init(zcFile);

  ZC_DataProperty* dataProperty = ZC_startCmpr(varName, ZC_FLOAT, data, 0, 0, r3, r2, r1);
  unsigned char * result =  sz_compress_3d(data, r1, r2, r3, eb*(max - min), result_size);
  unsigned char * result_after_lossless = NULL;
  size_t lossless_outsize = sz_lossless_compress(ZSTD_COMPRESSOR, 3, result, result_size, &result_after_lossless);
  ZC_CompareData* compareResult = ZC_endCmpr(dataProperty, solName, lossless_outsize);

  free(result);

  //decompress the data
  ZC_startDec();

  size_t lossless_output = sz_lossless_decompress(ZSTD_COMPRESSOR, result_after_lossless, lossless_outsize, &result, result_size);
  float * dec_data = sz_decompress_3d<float>(result, r1, r2, r3);
  
  free(result_after_lossless);

  ZC_endDec(compareResult, dec_data);

  //free options and the library
  free(data);
  free(dec_data);
  return 0;
}
