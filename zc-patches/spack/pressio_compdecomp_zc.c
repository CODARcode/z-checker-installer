#include <fcntl.h>
#include <string.h>
#include <libpressio.h>
#include <libpressio_ext/json/pressio_options_json.h>
#include <libpressio_ext/io/posix.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>
#include <zc.h>


#define SZ 1
#define ZFP 2
#define FPZIP 3
#define BITGROOMING 4
#define DIGITROUNDING 5
#define SZAUTO 6
#define MGARD 7

#define ABS 0
#define REL 1
#define PW_REL 2
#define PREC 3

#define PRESSIO_FLOAT 0
#define PRESSIO_DOUBLE 1

#define PRESSIO_JSON_SZ_FILE "sz.json"
#define PRESSIO_JSON_ZFP_FILE "zfp.json"
#define PRESSIO_JSON_FPZIP_FILE "fpzip.json"
#define PRESSIO_JSON_BITGROOMING_FILE "bitgrooming.json"
#define PRESSIO_JSON_DIGITROUNDING_FILE "digitrounding.json"
#define PRESSIO_JSON_SZAUTO_FILE "SZauto.json"
#define PRESSIO_JSON_MGARD_FILE "mgard.json"


char* read_json_from_file(const char* path);
void usage();
int computeDim(size_t* dims);

int main(int argc, char *argv[])
{
	char solName[100];
	char varName[100];
	char zcConFile[100];
	
	int dataType = 0; //0: single precision ; 1: double precision
	char* inPath = NULL;
	
	char* compressorStr = NULL;
	int compressorID = 0;
	
	char* errBoundModeStr = NULL;
	char* absErrorBoundStr = NULL;
	char* relErrorBoundStr = NULL;
	char* pwrErrorBoundStr = NULL;
	
	int errorBoundMode;
	float absErrorBound = 0;
	float relErrorBound = 0;
	float pwrErrorBound = 0;
	int precision = 0;
	
	size_t r5 = 0;
	size_t r4 = 0;
	size_t r3 = 0;
	size_t r2 = 0; 
	size_t r1 = 0;
	
	size_t dims[5] = {0,0,0,0};
	
	size_t i = 0;
	int status;
	size_t nbEle;
	if(argc==1)
		usage();
	
	for(i=1;i<argc;i++)
	{
		if (argv[i][0] != '-' || argv[i][2])
			usage();
		switch (argv[i][1])
		{
		case 'h':
			usage();
			exit(0);			
		case 'f': 
			dataType = PRESSIO_FLOAT;
			break;
		case 'd':
			dataType = PRESSIO_DOUBLE;
			break;
		case 'i':
			if (++i == argc)
				usage();
			inPath = argv[i];		
			break;
		case 'z':
			if (++i == argc)
				usage();
			compressorStr = argv[i];
			break;
		case '1': 
			if (++i == argc || sscanf(argv[i], "%zu", &r1) != 1)
				usage();
			break;
		case '2':
			if (++i == argc || sscanf(argv[i], "%zu", &r1) != 1 ||
				++i == argc || sscanf(argv[i], "%zu", &r2) != 1)
				usage();
			break;
		case '3':
			if (++i == argc || sscanf(argv[i], "%zu", &r1) != 1 ||
				++i == argc || sscanf(argv[i], "%zu", &r2) != 1 ||
				++i == argc || sscanf(argv[i], "%zu", &r3) != 1)
				usage();		
			break;
		case '4':
			if (++i == argc || sscanf(argv[i], "%zu", &r1) != 1 ||
				++i == argc || sscanf(argv[i], "%zu", &r2) != 1 ||
				++i == argc || sscanf(argv[i], "%zu", &r3) != 1 ||
				++i == argc || sscanf(argv[i], "%zu", &r4) != 1)
				usage();		
			break;
		case 'A':
			if (++i == argc)
				usage();
			absErrorBoundStr = argv[i];
			break;
		case 'R':
			if (++i == argc)
				usage();
			relErrorBoundStr = argv[i];
			break;
		case 'P':
			if (++i == argc)
				usage();
			pwrErrorBoundStr = argv[i];
			break;
		case 'p':
			if (++i == argc)
				usage();
			absErrorBoundStr = argv[i];
			break;
		case 'S':
			if (++i == argc)
				usage();
			sprintf(solName, "%s", argv[i]);
			break;
		case 'V':
			if (++i == argc)
				usage();
			sprintf(varName, "%s", argv[i]);
			break;
		case 'c':
			if (++i == argc)
				usage();
			sprintf(zcConFile, "%s", argv[i]);
			break;
		default: 
			usage();
			break;
		}
	}

	ZC_Init(zcConFile);

	dims[0] = r1;
	dims[1] = r2;
	dims[2] = r3;
	dims[3] = r4;
	dims[4] = r5;

	if(inPath==NULL)
	{
		printf("Error: you need to specify a raw binary data file\n");
		usage();
		exit(0);
	}	

	if(compressorStr==NULL)
	{
		printf("Error: compressor cannot be NULL\n");
		exit(0);
	}
	else
	{
		if(strcmp(compressorStr, "sz")==0 || strcmp(compressorStr, "SZ")==0)
			compressorID = SZ;
		else if(strcmp(compressorStr, "zfp")==0 || strcmp(compressorStr, "ZFP")==0)
			compressorID = ZFP;
		else if(strcmp(compressorStr, "fpzip")==0 || strcmp(compressorStr, "FPZIP")==0)
			compressorID = FPZIP;
		else if(strcmp(compressorStr, "bitgrooming")==0 || strcmp(compressorStr, "BITGROOMING")==0)
			compressorID = BITGROOMING;
		else if(strcmp(compressorStr, "digitrounding")==0 || strcmp(compressorStr, "DIGITROUNDING")==0)
			compressorID = DIGITROUNDING;
		else if(strcmp(compressorStr, "SZauto")==0 || strcmp(compressorStr, "szauto")==0 || strcmp(compressorStr, "SZAUTO")==0)
			compressorID = SZAUTO;	
		else if(strcmp(compressorStr, "mgard")==0 || strcmp(compressorStr, "MGARD")==0)
			compressorID = MGARD;					
		else
		{
			printf("Error: wrong compressor name\n");
			exit(0);
		}
	}

	if(absErrorBoundStr != NULL)
	{	
		absErrorBound = atof(absErrorBoundStr);
		errorBoundMode = ABS;
	}

	if(relErrorBoundStr != NULL)
	{
		relErrorBound = atof(relErrorBoundStr);
		errorBoundMode = REL;
	}

	if(pwrErrorBoundStr != NULL)
	{	
		pwrErrorBound = atof(pwrErrorBoundStr);
		errorBoundMode = PW_REL;
	}

	char* json_str = NULL;

	if(compressorID == SZ)
		json_str = read_json_from_file(PRESSIO_JSON_SZ_FILE);
	else if(compressorID == ZFP)
		json_str = read_json_from_file(PRESSIO_JSON_ZFP_FILE);
	else if(compressorID == FPZIP)
		json_str = read_json_from_file(PRESSIO_JSON_FPZIP_FILE);
	else if(compressorID == BITGROOMING)
		json_str = read_json_from_file(PRESSIO_JSON_BITGROOMING_FILE);
	else if(compressorID == DIGITROUNDING)
		json_str = read_json_from_file(PRESSIO_JSON_DIGITROUNDING_FILE);
	else if(compressorID == MGARD)
		json_str = read_json_from_file(PRESSIO_JSON_MGARD_FILE);
	else if(compressorID == SZAUTO)
		json_str = read_json_from_file(PRESSIO_JSON_SZAUTO_FILE);

	printf("compressor json file: %s\n", json_str);

    //configure base settings
    assert(json_str != NULL);
    struct pressio* instance = pressio_instance();
    assert(instance != NULL);
    struct pressio_compressor* compressor = pressio_get_compressor(instance, "zcheckerapi");
    assert(compressor != NULL);
    struct pressio_options* json_options = pressio_options_new_json(instance, json_str);
     if(json_options == NULL) {
        fprintf(stderr, "%s\n", pressio_error_msg(instance));
        exit(pressio_error_code(instance));
    }
    if(pressio_compressor_check_options(compressor, json_options)) {
        fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
        exit(pressio_compressor_error_code(compressor));
    }
    if(pressio_compressor_set_options(compressor, json_options)) {
        fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
        exit(pressio_compressor_error_code(compressor));
    }
    free(json_str);
    pressio_options_free(json_options);

    //configure override settings
    struct pressio_options* override_options = pressio_options_new();
    //pressio_options_set_string(override_options, "zcheckerapi:metric", "error_stat");
    pressio_options_set_string(override_options, "zcheckerapi:metric", "composite");
    const char* metrics_ids[] = {"error_stat", "size", "time"};
    pressio_options_set_strings(override_options, "composite:plugins", sizeof(metrics_ids)/sizeof(metrics_ids[0]), metrics_ids);     

	switch(errorBoundMode)
	{
	case ABS:
		pressio_options_set_string(override_options, "zcheckerapi:error_bound", "abs");
		pressio_options_set_double(override_options, "zcheckerapi:abs_error_bound", absErrorBound);	
		printf("absErrorBound=%f\n", absErrorBound);
		break;
	case REL:
		pressio_options_set_string(override_options, "zcheckerapi:error_bound", "rel");
		pressio_options_set_double(override_options, "zcheckerapi:rel_error_bound", relErrorBound);		
		printf("relErrorBound=%f\n", relErrorBound);	
		break;
	case PW_REL:
		
		break;
		
	}

    if(pressio_compressor_check_options(compressor, override_options)) {
        fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
        exit(pressio_compressor_error_code(compressor));
    }
    if(pressio_compressor_set_options(compressor, override_options)) {
        fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
        exit(pressio_compressor_error_code(compressor));
    }
    pressio_options_free(override_options);
	size_t outSize = 0;

	if(dataType == PRESSIO_FLOAT) //float
	{
		//read in input file
		int dimSize = computeDim(dims);
		struct pressio_data* input_metadata = pressio_data_new_owning(pressio_float_dtype, dimSize, dims);
		//printf("inFile=%s\n", inPath);
		printf("sizeof(dims)=%zu, sizeof(dims[0])=%zu, dims[0]=%zu, dims[1]=%zu, dims[2]=%zu, dims[3]=%zu\n", sizeof(dims), sizeof(dims[0]), dims[0], dims[1], dims[2], dims[3]);
		struct pressio_data* input = pressio_io_data_path_read(input_metadata, inPath);		
		assert(input != NULL);
		struct pressio_data* compressed = pressio_data_new_empty(pressio_byte_dtype, 0, NULL);
		assert(compressed != NULL);
		struct pressio_data* output = pressio_data_new_clone(input);
		assert(output != NULL);
		float* oriData = pressio_data_ptr(input, NULL);
		//printf("%f %f %f\n", oriData[0], oriData[1], oriData[2]);
		//run the compressor
		
		ZC_DataProperty* dataProperty = ZC_startCmpr(varName, ZC_FLOAT, oriData, r5, r4, r3, r2, r1);
		if(pressio_compressor_compress(compressor, input, compressed)) {
			fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
			exit(pressio_compressor_error_code(compressor));
		}
		pressio_data_ptr(compressed, &outSize);
		ZC_CompareData* compareResult = ZC_endCmpr(dataProperty, solName, outSize);	
		printf("compressed data size = %zu\n", outSize);
		
		ZC_startDec();
		if(pressio_compressor_decompress(compressor, compressed, output)) {
			fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
			exit(pressio_compressor_error_code(compressor));
		}
		float* decData = pressio_data_ptr(output, NULL);
		ZC_endDec(compareResult, decData);
		//printf("%f %f %f\n", decData[0], decData[1], decData[2]);		 

		freeDataProperty(dataProperty);
		freeCompareResult(compareResult);
	}
	else if(dataType == PRESSIO_DOUBLE)
	{
		int dimSize = computeDim(dims);
		struct pressio_data* input_metadata = pressio_data_new_owning(pressio_double_dtype, dimSize, dims);
		struct pressio_data* input = pressio_io_data_path_read(input_metadata, inPath);		
		assert(input != NULL);
		struct pressio_data* compressed = pressio_data_new_empty(pressio_byte_dtype, 0, NULL);
		assert(compressed != NULL);
		struct pressio_data* output = pressio_data_new_clone(input);
		assert(output != NULL);
		double* oriData = pressio_data_ptr(input, NULL);
		
		//run the compressor
		ZC_DataProperty* dataProperty = ZC_startCmpr(varName, ZC_FLOAT, oriData, r5, r4, r3, r2, r1);
		if(pressio_compressor_compress(compressor, input, compressed)) {
			fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
			exit(pressio_compressor_error_code(compressor));
		}
		ZC_CompareData* compareResult = ZC_endCmpr(dataProperty, solName, outSize);	
		printf("compressed data size = %zu\n", outSize);

		ZC_startDec();		
		if(pressio_compressor_decompress(compressor, compressed, output)) {
			fprintf(stderr, "%s\n", pressio_compressor_error_msg(compressor));
			exit(pressio_compressor_error_code(compressor));
		}
		double* decData = pressio_data_ptr(output, NULL); 
		ZC_endDec(compareResult, decData);		
		
		freeDataProperty(dataProperty);
		freeCompareResult(compareResult);				
	}

	ZC_Finalize();
    struct pressio_options* metrics_results = pressio_compressor_get_metrics_results(compressor);

    //we can output in JSON or human readable format
    bool output_json = false;
    char* metrics_str = NULL;
    if(output_json) {
        metrics_str = pressio_options_to_json(instance, metrics_results);
    } else {
        metrics_str = pressio_options_to_string(metrics_results);
    }
    //printf("metrics_str: %s\n", metrics_str);
    free(metrics_str);

    //it is also possible to get values specifically
    //double value_range = 0;
    //pressio_options_get_double(metrics_results, "error_stat:value_range", &value_range);
    //printf("value_range=%.1lf\n", value_range);

    pressio_options_free(metrics_results);

    return 0;
}

char* read_json_from_file(const char* path) {
    int json_fd = open(path, O_RDONLY);
    if(json_fd == -1) {
        perror("failed to open json file");
        exit(1);
    }

    struct stat json_stat = {};
    if(fstat(json_fd, &json_stat) == -1) {
        perror("failed to stat file");
        exit(1);
    }
    size_t bytes_read = 0;
    size_t total_read = 0;
    char* json_str = calloc(json_stat.st_size + 1, sizeof(char));
    while((bytes_read = read(json_fd, json_str + total_read, json_stat.st_size)) > 0) {
        total_read += bytes_read;
    }
    json_str[total_read] = '\0';
    close(json_fd);
    return json_str;
}

void usage()
{
	printf("Usage: pressio_compdecop <options>\n");
	printf("Options:\n");
	printf("* operation type:\n");
	printf("	-h: print the help information\n");
	printf("	-z: compressor's json file (such as sz.json)\n");
	printf("* naming: \n");
	printf("	-S: solution name: e.g., sz(1E-1)\n");
	printf("	-V: variable name: e.g., CLDHGH\n");
	printf("* data type:\n");
	printf("	-f: single precision (float type)\n");
	printf("	-d: double precision (double type)\n");
	printf("* error control:\n");
	printf("	-A <absolute error bound>: specifying absolute error bound\n");
	printf("	-R <value_range based relative error bound>: specifying relative error bound\n");
	printf("	-P <point-wise relative error bound>: specifying point-wise relative error bound\n");
	printf("	-p <precision>: specifying precision value (for fpzip, digit rounding, bitgrooming, zfp, etc.)\n");
	printf("* input data file:\n");
	printf("	-i <original data file> : original data file\n");
	printf("	-s <compressed data file> : compressed data file in decompression\n");
	printf("	-c <zc config file>: zchecker's configuration file\n");
	printf("* dimensions: \n");
	printf("	-1 <nx> : dimension for 1D data such as data[nx]\n");
	printf("	-2 <nx> <ny> : dimensions for 2D data such as data[ny][nx]\n");
	printf("	-3 <nx> <ny> <nz> : dimensions for 3D data such as data[nz][ny][nx] \n");
	printf("	-4 <nx> <ny> <nz> <np>: dimensions for 4D data such as data[np][nz][ny][nx] \n");
	printf("* examples: \n");
	printf("	pressio_compdecomp -z sz -c zc.config -V test -S \"sz(1E-2)\" -f -i testfloat_8_8_128.dat -3 8 8 128 -A 1E-2\n");
	printf("	pressio_compdecomp -z zfp -c zc.config -V test -S \"zfp(1E-2)\" -f -i testfloat_8_8_128.dat -3 8 8 128 -R 1E-2\n");
	printf("	pressio_copmdecopm -z fpzip -c zc.config -V test -S \"fpzip(10)\" -f -i testfloat_8_8_128.dat -3 8 8 128 -p 10\n"); 
	exit(0);
}

int computeDim(size_t* dims)
{
	int i = 0;
	int dimSize = 0;
	for(i=0;i<5;i++)
	{
		if(dims[i]!=0)
			dimSize++;
		else
			break;
	}	
	return dimSize;
}
