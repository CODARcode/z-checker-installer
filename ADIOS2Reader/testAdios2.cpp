/*
 * 
 * Author: Sheng Di, Robert Underwood
 * 
 * testAdios2.cpp: 
 * 
 */

#include <fstream>
#include <ios>       //std::ios_base::failure
#include <iostream>  //std::cout
#include <stdexcept> //std::invalid_argument std::exception
#include <vector>
#include <string>
#include <adios2.h>
#include <zc.h>

#define ZCBP_FLOAT 0
#define ZCBP_DOUBLE 1
#define ZCBP_INT16 2
#define ZCBP_INT32 3
#define ZCBP_INT64 4
#define ZCBP_UINT16 5
#define ZCBP_UINT32 6
#define ZCBP_UINT64 7
#define ZCBP_INVALID -1


using namespace std;

template <class T>
class Zcbp_variable_impl;

 
static	int dtype_from_str(string const& dataType_s) noexcept{
		if(dataType_s=="float")
			return ZCBP_FLOAT;
		else if(dataType_s=="double")
			return ZCBP_DOUBLE;
		else if(dataType_s=="int16_t")
			return ZCBP_INT16;
		else if(dataType_s=="int32_t")
			return ZCBP_INT32;
		else if(dataType_s=="int64_t")
			return ZCBP_INT64;
		else
			return ZCBP_INVALID;
	}


class Zcbp_variable {
	public:
	virtual ~Zcbp_variable()=default;
	
	Zcbp_variable(string const& name, string dataType_s, adios2::Dims const& dims): 
		name(name), 
		dimension(dims.size()), 
		dataType(dtype_from_str(dataType_s))
	{
		switch(dimension)
			{
			case 1:
				this->r1 = dims[0];
				break;
			case 2:
				this->r2 = dims[0];
				this->r1 = dims[1];
				break;
			case 3:
				this->r3 = dims[0];
				this->r2 = dims[1];
				this->r1 = dims[2];
				break;
			case 4:
				this->r4 = dims[0];
				this->r3 = dims[1];
				this->r2 = dims[2];
				this->r1 = dims[3];
				break;
			case 5:
				this->r5 = dims[0];
				this->r4 = dims[1];
				this->r3 = dims[2];
				this->r2 = dims[3];	
				this->r1 = dims[4];
				break;
			}
	}
	
	template<class T>
	static Zcbp_variable* create(string varName, string dataType_s , adios2::Variable<T> bpData) {
		return new Zcbp_variable_impl<T>(varName, dataType_s, bpData);
	}
	
	int getDataType() const noexcept {
		return dataType;
	}
	string const& getName() const noexcept {
			return name;
	}
	
	int getDimension() const noexcept {
		return dimension;
	}
	void setR5(size_t r5) noexcept {
		this->r5 = r5;
	}
	size_t getR5() const noexcept {
		return r5;
	}
	void setR4(size_t r4) noexcept {
		this->r4 = r4;
	}		
	size_t getR4() const noexcept  {
		return r4;
	}
	void setR3(size_t r3) noexcept {
		this->r3 = r3;
	}		
	size_t getR3() const noexcept {
		return r3;
	}
	void setR2(size_t r2)  noexcept {
		this->r2 = r2;
	}		
	size_t getR2() const noexcept {
		return r2;
	}			
	void setR1(size_t r1) noexcept {
		this->r1 = r1;
	}			
	size_t getR1() const noexcept {
		return r1;
	}
	
	size_t getTotalSize()
	{
		size_t totalSize = 0;
		switch(dimension)
		{
		case 1:
			totalSize = r1;
			break;
		case 2:
			totalSize = r1*r2;
			break;
		case 3:
			totalSize = r1*r2*r3;
			break;
		case 4:
			totalSize = r1*r2*r3*r4;
			break;
		case 5:
			totalSize = r1*r2*r3*r4*r5;
			break;
		}
		return totalSize;
	}
	
	void getDimensionString(string& dimString)
	{
		switch(dimension)
		{
		case 1:
			dimString = to_string(r1);
			break;
		case 2:
			dimString = to_string(r2) + "X" + to_string(r1);
			break;
		case 3:
			dimString = to_string(r3) + "X" + to_string(r2) + "X" + to_string(r1);
			break;
		case 4:
			dimString = to_string(r4) + "X" + to_string(r3) + "X" + to_string(r2) + "X" + to_string(r1);
			break;
		case 5:
			dimString = to_string(r5) + "X" + to_string(r4) + "X" + to_string(r3) + "X" + to_string(r2) + "X" + to_string(r1);
			break;
		}		
	}
	
	void getOutFileName(string& outFileName)
	{
		outFileName += name;
		outFileName += "_";
		string dimString;
		getDimensionString(dimString);
		
		outFileName += dimString;
		outFileName += ".";
		
		string dataTypeString;
		switch(dataType)
		{
		case ZCBP_FLOAT:
			dataTypeString = "f32";
			break;
		case ZCBP_DOUBLE:
			dataTypeString = "f64";
			break;
		case ZCBP_INT16:
			dataTypeString = "i16";
			break;						
		case ZCBP_INT32:
			dataTypeString = "i32";
			break;		
		case ZCBP_INT64:
			dataTypeString = "i64";
			break;												
		}
		
		outFileName += dataTypeString;
	}
	
	private:
	string name;
	int dimension;
	size_t r5;
	size_t r4;
	size_t r3;
	size_t r2;
	size_t r1;
	int dataType;
};

template <typename T>
class Zcbp_variable_impl : public Zcbp_variable
{
	public:
	
		Zcbp_variable_impl(string varName, string dataType_s, adios2::Variable<T> bpData): Zcbp_variable(varName, dataType_s, bpData.Shape()), bpData(bpData) {}
		
		adios2::Variable<T> const& getBPData() const {
			return bpData;
		}
	private:
	
		adios2::Variable<T> bpData;
};

void usage()
{
	std::cout << "Usage: testAdios2 <options>\n";
	std::cout << "Options:\n";
	std::cout << "* input & output:\n";
	std::cout << "       -i: input file\n";
	std::cout << "       -o: output directory\n";
	std::cout << "* operation type:\n";
	std::cout << "       -b: extract data and store into binary files\n";
	std::cout << "       -r: directly generate assessment report (to do: comming soon)\n";
	std::cout << "       -h: print the help information\n";
	std::cout << "* select variables:\n";
	std::cout << "       -n <number of variables>\n";
	std::cout << "       -v <variables ....>: the n variables to be extracted\n";
	std::cout << "       -l <L> : select the variables whose # data points is no smaller than L\n";
	std::cout << "       -u <U> : select the variables whose # data points is no greater than U\n";
	std::cout << "       -t <T> : select the variables with data type T [float/double]\n";
	std::cout << "       -d <D> : select the variables with the dimension D\n";
	std::cout << "* examples:\n";

}

adios2::Params queryVarParameter(string varName, std::map<std::string, adios2::Params> varMap)
{
	adios2::Params params;
	for (const auto variablePair : varMap)
	{
		string vName = variablePair.first;
		if(varName==vName)
		{
			params = variablePair.second;
		}
	}
	return params;
} 

void freeZCVarVector(vector<Zcbp_variable*> v)
{
	for (vector<Zcbp_variable*>::iterator it = v.begin(); it != v.end(); it ++) 
    if (NULL != *it) 
    {
        delete *it; 
        *it = NULL;
    }
    v.clear();
}

int main(int argc, char *argv[])
{
    string filename = "";
    string outputDir = "";

	int convert = 0;
	int report = 0;
	int nbVars = 0;
	size_t l_nbPoints = 0;
	size_t u_nbPoints = 0;
	int dataType = ZCBP_FLOAT; //0: float, 1: double
	int dimension = 0; //1,2, or 3
	
	vector<string> varVector; //set by users
	vector<Zcbp_variable*> zc_var_vector; //zc_var_vector
	
	if(argc==1)
		usage();
		
	int  i = 0, j = 0;
	for(i=1;i<argc;i++)
	{
		if (argv[i][0] != '-' || argv[i][2])
			usage();
		
		switch (argv[i][1])
		{
		case 'h':
			usage();
			exit(0);
		case 'b':
			convert = 1;
			break;
		case 'r': 
			report = 1;
			break;
		case 'n': 
			if (++i == argc)
				usage();
			nbVars = atoi(argv[i]);
			break;
		case 'v':
			for (j = 0; j < nbVars && ++i < argc;j++)
			{
				varVector.push_back(argv[i]);
			}
			if(nbVars!=j)
			{
				cout << "Wrong setting: the real # variables (specified by -v> is not equal to expected # variables <specified by -n>\n"; 
				exit(0);
			}
			break;
		case 'l':
			if (++i == argc)
				usage();
			sscanf(argv[i], "%zu", &l_nbPoints); 
			break;
		case 'u': 
			if (++i == argc)
				usage();
			sscanf(argv[i], "%zu", &u_nbPoints); 
			break;
		case 't':
			if (++i == argc)
				usage();
			if(argv[i]=="float")
				dataType = ZCBP_FLOAT;
			else if(argv[i]=="double")
				dataType = ZCBP_DOUBLE;
			else if(argv[i]=="int16")
				dataType = ZCBP_INT16;
			else if(argv[i]=="int32")
				dataType = ZCBP_INT32;
			else if(argv[i]=="int64")
				dataType = ZCBP_INT64;
			else 
			{
				std::cout << "Wrong setting: unrecognized data type\n";
				exit(0);
			}	
			break;	
		case 'd':
			sscanf(argv[i], "%d", &dimension);
			break;
		case 'i':
			if (++i == argc)
				usage();
			filename = argv[i];
			break;
		case 'o':
			if (++i == argc)
				usage();
			outputDir = argv[i];
			break;
		default: 
			usage();
			break;
		}
	}

	if (filename.empty())
	{
		cout << "Error: input file is null\n";
		exit(0);
	}

	//open bp file	
	adios2::ADIOS adios(adios2::DebugON);
	adios2::IO bpIO = adios.DeclareIO("ReadBP");
	adios2::Engine bpReader = bpIO.Open(filename, adios2::Mode::Read);
	std::map<std::string, adios2::Params> varMap = bpIO.AvailableVariables();

	if(nbVars!=0)
	{
		for (vector<string>::iterator iter = varVector.begin(); iter != varVector.end(); iter++)
		{
			string varName = *iter;
			adios2::Params params = queryVarParameter(varName, varMap);
						
			auto it = params.find("Type");
			const std::string &type = it->second;
			adios2::Dims dims;
			if(type=="float")
			{
				adios2::Variable<float> bpData = bpIO.InquireVariable<float>(varName); 
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData); //bpData can be kept normally?
				zc_var_vector.push_back(zcbpv);				
			}
			else if(type=="double")
			{
				adios2::Variable<double> bpData = bpIO.InquireVariable<double>(varName);
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData);
				zc_var_vector.push_back(zcbpv);
			}
			else if(type=="int16_t")
			{
				adios2::Variable<short> bpData = bpIO.InquireVariable<short>(varName);
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData);
				zc_var_vector.push_back(zcbpv);
			}			
			else if(type=="int32_t")
			{
				adios2::Variable<int> bpData = bpIO.InquireVariable<int>(varName);
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData);
				zc_var_vector.push_back(zcbpv);
			}
			else if(type=="int64_t")
			{
				adios2::Variable<long> bpData = bpIO.InquireVariable<long>(varName);
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData);
				zc_var_vector.push_back(zcbpv);
			}			
			else
			{
				cout << "Error: the types other than short, int, long, float and double are not supported yet.\n";
				exit(0);
			}
			
		}
	}
	else //get variables based on the input bp file
	{
		for (const auto variablePair : varMap)
		{
			string varName = variablePair.first;
			adios2::Params params = variablePair.second;
			auto it = params.find("Type");
			const std::string &type = it->second;

			adios2::Dims dims;
			if(type=="float")
			{
				adios2::Variable<float> bpData = bpIO.InquireVariable<float>(varName); 
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData); //bpData can be kept normally?
				zc_var_vector.push_back(zcbpv);				
			}
			else if(type=="double")
			{
				adios2::Variable<double> bpData = bpIO.InquireVariable<double>(varName);
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData);
				zc_var_vector.push_back(zcbpv);
			}
			else if(type=="int32_t")
			{
				adios2::Variable<int> bpData = bpIO.InquireVariable<int>(varName);
				dims = bpData.Shape();
				Zcbp_variable* zcbpv = Zcbp_variable::create(varName, type, bpData);
				zc_var_vector.push_back(zcbpv);
			}	
			else
			{
				cout << "Error: the types other than int, float and double are not supported yet.\n";
				exit(0);
			}
		}
	}
	
	//from zc_var_vector, select the variables customized by users
	
	
	
	ofstream outf; 
	string varInfoTxtFile = outputDir + "/varInfo.txt";
	outf.open(varInfoTxtFile);
	
	string ENDIAN_TYPE = sysEndianType==LITTLE_ENDIAN_SYSTEM ? "LITTLE_ENDIAN" : "BIG_ENDIAN";
	
	//process the variables
	for (vector<Zcbp_variable*>::iterator iter = zc_var_vector.begin(); iter != zc_var_vector.end(); iter++)
	{
		Zcbp_variable* var = *iter;
		
		int type = var->getDataType();
		string name = var->getName();
		
		outf << name << ":";
		
		cout << "type: " << type << " name: " << name << "\n";
		if(type==ZCBP_FLOAT)
		{
			auto* p = dynamic_cast<Zcbp_variable_impl<float>*>(var); //p == nullptr if not matched
			auto bpData = p->getBPData();
			std::vector<float> data;
			bpReader.Get<float>(bpData, data, adios2::Mode::Sync);
			float* c_data = &data[0];
			
			string dimensionString;
			p->getDimensionString(dimensionString);			
			
			string outFilePath = outputDir+"/";
			p->getOutFileName(outFilePath);
			cout << "outFilePath: " << outFilePath << "\n";
			
			char * writable_str = new char[outFilePath.size() + 1];
			memset(writable_str, 0, outFilePath.size() + 1);
			std::copy(outFilePath.begin(), outFilePath.end(), writable_str);
			writable_str[outFilePath.size()] = '\0'; 	
			
			ZC_writeFloatData_inBytes(c_data, p->getTotalSize(), writable_str);

			string DATA_TYPE = "FLOAT";
			outf << DATA_TYPE << ":" << dimensionString << ":" << outFilePath << endl;
			
			delete[] writable_str;
	
		}
		else if(type==ZCBP_DOUBLE)
		{
			auto* p = dynamic_cast<Zcbp_variable_impl<double>*>(var);			
			auto bpData = p->getBPData();
			std::vector<double> data;
			bpReader.Get<double>(bpData, data, adios2::Mode::Sync);
			double* c_data = &data[0];
			
			string dimensionString;
			p->getDimensionString(dimensionString);			
			
			string outFilePath = outputDir+"/";
			p->getOutFileName(outFilePath);
			cout << "outFilePath: " << outFilePath << "\n";		
			char * writable_str = new char[outFilePath.size() + 1];
			memset(writable_str, 0, outFilePath.size() + 1);
			std::copy(outFilePath.begin(), outFilePath.end(), writable_str);
			writable_str[outFilePath.size()] = '\0'; 	

			ZC_writeDoubleData_inBytes(c_data, p->getTotalSize(), writable_str);	
			
			string DATA_TYPE = "DOUBLE";	
			outf << DATA_TYPE << ":" << dimensionString << ":" << outFilePath << endl;
			
			delete[] writable_str;
		}
		else if(type==ZCBP_INT32)
		{
			auto* p = dynamic_cast<Zcbp_variable_impl<int>*>(var);
			auto bpData = p->getBPData();
			std::vector<int> data;
			bpReader.Get<int>(bpData, data, adios2::Mode::Sync);
			int* c_data = &data[0];
			
			string dimensionString;
			p->getDimensionString(dimensionString);
			
			string outFilePath = outputDir+"/";
			p->getOutFileName(outFilePath);
			cout << "outFilePath: " << outFilePath << "\n";			
			char * writable_str = new char[outFilePath.size() + 1];
			memset(writable_str, 0, outFilePath.size() + 1);
			std::copy(outFilePath.begin(), outFilePath.end(), writable_str);			
			ZC_writeIntData_inBytes(c_data, p->getTotalSize(), writable_str);		
			
			string DATA_TYPE = "INT";
			outf << DATA_TYPE << ":" << dimensionString << ":" << outFilePath << endl;
			
			delete[] writable_str;
		}
	}
	
	freeZCVarVector(zc_var_vector);
	outf.close();

    return 0;
}
