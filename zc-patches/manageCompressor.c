#include <stdio.h> 
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include "ZC_rw.h"
#include "ZC_util.h"
#include "iniparser.h"
#include <stdbool.h>



#define ADD_CMPR 11
#define DELETE_CMPR 10
#define MODIFY_RATE_DISTORTION_SH 1
#define PRINT_INFO 0
#define CHECK_ERRBOUNDS 2

#define MANAGE_SUC 1
#define MANAGE_FAIL 0

char* delim = " ";
char* delim2 = "\"";
char* delim3 = ":";
char* delim4 = "=";
char* delim5 = ",";

void usage()
{
	printf("Usage: manageCompressor <options>\n");
	printf("Options:\n");
	printf("* Operation:\n");
	printf("	-a <compressor>: add a compressor\n");
	printf("	-d <compressor>: delete a compressor\n");
	printf("	-z <compressor>: modify zc-ratedistortion.sh and exe_CompDecomp.sh\n");	
	printf("	-p : print the information\n");	
	printf("	-k : check validity of errBounds.cfg\n");
	printf("	-i : limits on the dimensions that the compressor supports\n");
	printf("	-r : reverse the dimensions of the input data(does not support varlist)\n");
	printf("* Mode:\n");
	printf("	-m : the execution mode of the compressor (e.g., fast or deft)\n");
	printf("* Input:\n");
	printf("	-c <configuration file>: configuration file\n");
	printf("	-w <workspace> : specify workspace\n");
	printf("* Example:\n");
	printf("	manageCompressor -c zc_manage.cfg\n");
	printf("	manageCompressor -a sz -m fast -c manageCompressor-sz-f.cfg\n");
	printf("	manageCompressor -d sz -m fast -c manageCompressor-sz-f.cfg\n");
}

int loadConfFile(char* zc_cfgFile, char** compressorName, char** compressorMode, char** compressor, char** workspaceDir, char** exeDir, char** preCommand, char** exeCommand)
{
	if (access(zc_cfgFile, F_OK) != 0)
	{
		printf("[ZC] Configuration file NOT accessible.\n");
		return 1;
	}
	dictionary *ini = iniparser_load(zc_cfgFile);
	if (ini == NULL)
	{
		printf("[ZC] Iniparser failed to parse the conf. file.\n");
		return 1;
	}

	*compressorName = (char*)malloc(100);
	*compressorMode = (char*)malloc(100);
	*compressor = (char*)malloc(100);
	*workspaceDir = (char*)malloc(1024);
	*exeDir = (char*)malloc(1024);
	*preCommand = (char*)malloc(512);
	*exeCommand = (char*)malloc(512);

	char* compressorN = iniparser_getstring(ini, "COMPRESSOR:compressor_name", NULL);
	strcpy(*compressorName, compressorN);
	char* compressorM = iniparser_getstring(ini, "COMPRESSOR:compression_mode", NULL);
	strcpy(*compressorMode, compressorM);
	
	char* workspaceDir_ = iniparser_getstring(ini, "COMPRESSOR:workspaceDir", NULL);
	strcpy(*workspaceDir, workspaceDir_);
	char* compressor_ = iniparser_getstring(ini, "COMPRESSOR:full_compressor_name", NULL);
	strcpy(*compressor, compressor_);

	char* exeDir_ = iniparser_getstring(ini, "COMPRESSOR:exeDir", NULL);
	strcpy(*exeDir, exeDir_);
	char* preCommand_ = iniparser_getstring(ini, "COMPRESSOR:preCommand", NULL);
	strcpy(*preCommand, preCommand_);
	char* exeCommand_ = iniparser_getstring(ini, "COMPRESSOR:exeCommand", NULL);
	strcpy(*exeCommand, exeCommand_);

	iniparser_freedict(ini);

	return 0;
}

int processCreateZCCase(int operation, char* compressorName, char* mode, char* compressor, char* workspaceDir, char* exeDir, char* preCommand, char* exeCommand, char* confFilePath)
{
	int i = 0, lineCount = 0, tag = 0;
	StringLine* header = NULL, *preLine = NULL;
	char* p = NULL;
	char buf[4096];
	memset(buf, 0, 4096);

	if(operation == PRINT_INFO)
	{
		return MANAGE_SUC;
	}
	else if(operation == ADD_CMPR)
	{
		header = ZC_readLines("createZCCase.sh", &lineCount);
		preLine = header;
		StringLine* curLine = NULL;
		StringLine* newHeader = NULL, *newTailer = NULL;
		for(i=0;preLine->next!=NULL;i++)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##New compressor");
			if(tag)
			{
				newHeader = preLine;
				newTailer = curLine;
				break;
			}
			preLine = preLine->next;
		}
		
		if(tag==0)
		{
			ZC_freeLines(header);
			printf("Error: The line '##New compressor' is missing in createZCCase.sh\n");
			printf("Reason: You probably removed that line manually in createZCCase.sh\n");
			printf("Solution: add this line '##New compressor to be added here' before 'cd $rootDir/zc-patches'\n");
			return MANAGE_FAIL;
		}		
		
		//add lines
		StringLine* insertLines = createStringLineHeader();
		StringLine* insertLinesTail = insertLines;

		char caseName[1024];
		sprintf(caseName, "%s_%s_caseName", compressorName, mode);
		char* buf2 = (char*)malloc(1024);
		sprintf(buf2, "##begin: Compressor %s\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "echo Create a new case for %s\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);
		
		buf2 = (char*)malloc(1024);
		char  workspaceDir_fullPath[PATH_MAX+1];
 		char* res = realpath(workspaceDir,workspaceDir_fullPath);
 		if(!res)
		{
			printf("cannot find the path of the file \n");
			return 1;
		}
		sprintf(buf2, "cd $rootDir\nmkdir -p %s\ncd %s\n", workspaceDir, workspaceDir);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "%s=${caseName}_%s\n", caseName, mode);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "mkdir -p $%s\n", caseName);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "cd $%s\n", caseName);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "cp $rootDir/zc-patches/exe_CompDecomp.sh .\ncp $rootDir/zc-patches/zc-ratedistortion.sh .\n");
		insertLinesTail = appendOneLine(insertLinesTail, buf2);
		
		buf2 = (char*)malloc(1024);
		sprintf(buf2, "ln -s $rootDir/errBounds.cfg errBounds.cfg\n");
		insertLinesTail = appendOneLine(insertLinesTail, buf2);		

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "ln -s %s manageCompressor.cfg\n", confFilePath);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);	
		
		buf2 = (char*)malloc(1024);
		sprintf(buf2, "ln -s $rootDir/manageCompressor manageCompressor\n");
		insertLinesTail = appendOneLine(insertLinesTail, buf2);			
		
		buf2 = (char*)malloc(1024);
		sprintf(buf2, "cp $rootDir/zc.config.tmp ./zc.config\n");
		insertLinesTail = appendOneLine(insertLinesTail, buf2);
		
		buf2 = (char*)malloc(1024);
		sprintf(buf2, "./manageCompressor -z %s -c manageCompressor.cfg\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "cd $rootDir\n");
		insertLinesTail = appendOneLine(insertLinesTail, buf2);
		
		strtok(exeCommand, delim);
		buf2 = (char*)malloc(1024);
		sprintf(buf2, "cp %s/%s %s/$%s/%s\n", exeDir, exeCommand, workspaceDir, caseName, exeCommand); 
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "%s\n", preCommand);
		ZC_ReplaceStr2(buf2, "$workspaceDir", workspaceDir);
		ZC_ReplaceStr2(buf2, "testcase", caseName); 
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "cd %s/$%s\n", workspaceDir, caseName);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);		
		sprintf(buf2, "cp $rootDir/zc-patches/queryVarList .\n", compressorName);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "##end: Compressor %s\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		newHeader->next = insertLines->next;
		insertLinesTail->next = newTailer;

		free(insertLines); //actually only free the header of insertlines

		preLine = header;
		while(preLine->next!=NULL) //go to the modifyZCConfig line
		{
			curLine = preLine->next;
			if(ZC_startsWithLines(curLine, "./modifyZCConfig")==1)
				break;
			preLine = preLine->next;
		}
		StringLine* modifyLine = curLine;
		trim(modifyLine->str);
		int len = strlen(modifyLine->str);
		modifyLine->str[len-1] = '\0';
		memset(buf, 0, 4096);
		sprintf(buf, "%s %s:%s/${%s}\"\n", modifyLine->str, compressor, workspaceDir_fullPath, caseName); 
		strcpy(modifyLine->str, buf);
	}
	else //operation == DELETE_CMPR
	{
		char buf2[1024];
		header = ZC_readLines("createZCCase.sh", &lineCount);
		preLine = header;
		StringLine* curLine;
		StringLine* rmHeader = NULL, *rmTailer = NULL;
		while(preLine->next!=NULL)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##begin: Compressor");
			if(tag)
			{
				strcpy(buf2, curLine->str);
				strtok(buf2, delim);
				strtok(NULL, delim);
				p = strtok(NULL, delim);
				trim(p);
				if(strcmp(p, compressor)==0)
					rmHeader = preLine;
				preLine = preLine->next;
				continue;
			}
			tag = ZC_startsWithLines(curLine, "##end: Compressor");
			if(tag)
			{
				strcpy(buf2, curLine->str);
				strtok(buf2, delim);
				strtok(NULL, delim);
				p = strtok(NULL, delim);
				trim(p);
				if(strcmp(p, compressor)==0)
				{
					rmTailer = curLine;
					break;
				}
			}
			preLine = preLine->next;
		}

		//delete compressor
		if(rmHeader==NULL||rmTailer==NULL)
		{
			printf("No such a compressor in createZCCase.sh: %s\n", compressor);
			return MANAGE_FAIL;
		}
		else
			ZC_removeLines(rmHeader, rmTailer);

		preLine = header;
		while(preLine->next!=NULL) //go to the modifyZCConfig line
		{
			curLine = preLine->next;
			if(ZC_startsWithLines(curLine, "./modifyZCConfig")==1)
			{
				break;
			}			
			preLine = preLine->next;
		}
		StringLine* modifyLine = curLine;
		
		strtok(modifyLine->str, delim2);
		p = strtok(NULL, delim2); 
		char p2[1024], p3[1024]; 
		char* zname;
		strcpy(p2, p); //p2==sz_f:../../SZ/${caseName}_fast sz_d:../../SZ/${caseName}_deft zfp:../../zfp/${zfp_caseName}

		int counter =  0;
		i = 0;
		char cmprs[20][100]; //at most 20 compressors
		p = strtok(p2, delim);
		for(counter = 0;p!=NULL;counter++)
		{
			strcpy(cmprs[counter],p);
			p = strtok(NULL, delim);
		}

		char tmp[1024], p2_[1024];
		memset(p2_, 0, 1024);
		for(i=0;i<counter;i++)
		{
			p = cmprs[i];
			strcpy(p3, p);
			zname = strtok(p3, delim3); //sz_f : ../../SZ...
			if(strcmp(zname, compressor)!=0)
			{
				sprintf(tmp, "%s %s", p2_, p);
				strcpy(p2_, tmp);
			}
		}
		trim(p2_);
		sprintf(buf, "./modifyZCConfig zc.config compressors \"%s\"\n", p2_);
	
		strcpy(modifyLine->str, buf);
			
	}
	ZC_writeLines(header, "createZCCase.sh");
	
	if(header!=NULL)
		ZC_freeLines(header);
		
	return MANAGE_SUC;			
}

int processRunZCCase(int operation, char* mode, char* compressor, char* workspaceDir, int dimLimit, bool dimReverse)
{
	int i = 0, lineCount = 0, tag = 0;
	StringLine* header = NULL, *preLine = NULL;
	char* p = NULL;
	char buf[4096];
	memset(buf, 0, 4096);

	if(operation == PRINT_INFO)
	{
		return MANAGE_SUC;
	}
	else if(operation == ADD_CMPR)
	{
		header = ZC_readLines("runZCCase.sh", &lineCount);
		preLine = header;
		StringLine* curLine = NULL;
		StringLine* newHeader = NULL, *newTailer = NULL;
		for(i=0;preLine->next!=NULL;i++)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##New compressor");
			if(tag)
			{
				newHeader = preLine;
				newTailer = curLine;
				break;
			}
			preLine = preLine->next;
		}
		
		if(tag==0)
		{
			ZC_freeLines(header);
			printf("Error: The line '##New compressor' is missing in runZCCase.sh\n");
			printf("Reason: You probably removed that line manually in runZCCase.sh\n");
			printf("Solution: add this line '##New compressor to be added here' before \ncd $rootDir\nif [[ $errBoundMode == \"PW_REL\" ]]; then\n....\n");
			return MANAGE_FAIL; 
		}		
		
		//add lines
		StringLine* insertLines = createStringLineHeader();
		StringLine* insertLinesTail = insertLines;

		if(dimLimit == -1)
		{
			char* buf2 = (char*)malloc(1024);
			sprintf(buf2, "##begin: Compressor %s\n", compressor);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "cd $rootDir\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
			
			buf2 = (char*)malloc(1024);
			sprintf(buf2, "cd %s/${testcase}_%s\n", workspaceDir, mode);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "if [[ $option == 1 ]]; then\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
			if(!dimReverse)
			{
				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\techo ./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);

				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\t./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}
			else
			{
				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\techo ./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim4 $dim3 $dim2 $dim1\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);

				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\t./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim4 $dim3 $dim2 $dim1\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}
			buf2 = (char*)malloc(1024);
			sprintf(buf2, "else\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
			
			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\techo ./zc-ratedistortion.sh $datatype $errBoundMode $varListFile\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\t./zc-ratedistortion.sh $datatype $errBoundMode $varListFile\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);		
			sprintf(buf2, "fi\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "##end: Compressor %s\n", compressor);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
		}
		else
		{
			char* buf2 = (char*)malloc(1024);
			sprintf(buf2, "##begin: Compressor %s\n", compressor);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "cd $rootDir\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
			
			buf2 = (char*)malloc(1024);
			sprintf(buf2, "cd %s/${testcase}_%s\n", workspaceDir, mode);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			if(dimLimit == 1)
			{
				sprintf(buf2, "if [ ! -z $dim1 ] && [ -z $dim2 ] && [ -z $dim3 ] && [ -z $dim4 ]; then\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}
			if(dimLimit == 2)
			{
				sprintf(buf2, "if [ ! -z $dim1 ] && [ ! -z $dim2 ] && [ -z $dim3 ] && [ -z $dim4 ]; then\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}
			if(dimLimit == 3)
			{
				sprintf(buf2, "if [ ! -z $dim1 ] && [ ! -z $dim2 ] && [ ! -z $dim3 ] && [ -z $dim4 ]; then\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}
			if(dimLimit == 4)
			{
				sprintf(buf2, "if [ ! -z $dim1 ] && [ ! -z $dim2 ] && [ ! -z $dim3 ] && [ ! -z $dim4 ]; then\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\tif [[ $option == 1 ]]; then\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			if(!dimReverse)
			{
				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\techo ./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);

				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\t./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim1 $dim2 $dim3 $dim4\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}
			else
			{
				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\techo ./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim4 $dim3 $dim2 $dim1\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);

				buf2 = (char*)malloc(1024);
				sprintf(buf2, "\t./zc-ratedistortion.sh $datatype $errBoundMode $dataDir $extension $dim4 $dim3 $dim2 $dim1\n");
				insertLinesTail = appendOneLine(insertLinesTail, buf2);
			}

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\telse\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
			
			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\t\techo ./zc-ratedistortion.sh $datatype $errBoundMode $varListFile\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\t\t./zc-ratedistortion.sh $datatype $errBoundMode $varListFile\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);		
			sprintf(buf2, "\tfi\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "else\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
			
			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\techo The compressor %s does not support the dimensions size \n", compressor);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
			
			buf2 = (char*)malloc(1024);
			sprintf(buf2, "\tcd $rootDir/Z-checker/${testcase};./delCompressorZCConfig zc.config %s;cd -\n", compressor);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);		
			sprintf(buf2, "fi\n");
			insertLinesTail = appendOneLine(insertLinesTail, buf2);

			buf2 = (char*)malloc(1024);
			sprintf(buf2, "##end: Compressor %s\n", compressor);
			insertLinesTail = appendOneLine(insertLinesTail, buf2);
		}


		newHeader->next = insertLines->next;
		insertLinesTail->next = newTailer;

		free(insertLines); //actually only free the header of insertlines
	}
	else //operation == DELETE_CMPR
	{
		char buf2[1024];
		header = ZC_readLines("runZCCase.sh", &lineCount);
		preLine = header;
		StringLine* curLine;
		StringLine* rmHeader = NULL, *rmTailer = NULL;
		while(preLine->next!=NULL)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##begin: Compressor");
			if(tag)
			{
				strcpy(buf2, curLine->str);
				strtok(buf2, delim);
				strtok(NULL, delim);
				p = strtok(NULL, delim);
				trim(p);
				if(strcmp(p, compressor)==0)
					rmHeader = preLine;
				preLine = preLine->next;
				continue;
			}
			tag = ZC_startsWithLines(curLine, "##end: Compressor");
			if(tag)
			{
				strcpy(buf2, curLine->str);
				strtok(buf2, delim);
				strtok(NULL, delim);
				p = strtok(NULL, delim);
				trim(p);
				if(strcmp(p, compressor)==0)
				{
					rmTailer = curLine;
					break;
				}
			}
			preLine = preLine->next;
		}

		//delete compressor
		if(rmHeader==NULL||rmTailer==NULL)
		{
			printf("No such a compressor in runZCCase.sh: %s\n", compressor);
			return MANAGE_FAIL;
		}
		else
			ZC_removeLines(rmHeader, rmTailer);	
	}
	ZC_writeLines(header, "runZCCase.sh");
	
	if(header!=NULL)
		ZC_freeLines(header);	
	
	return MANAGE_SUC;
}

int processRemoveZCCase(int operation, char* mode, char* compressor, char* workspaceDir)
{
	int i = 0, lineCount = 0, tag = 0;
	StringLine* header = NULL, *preLine = NULL;
	char* p = NULL;
	char buf[4096];
	memset(buf, 0, 4096);

	if(operation == PRINT_INFO)
	{
		return MANAGE_SUC;
	}
	else if(operation == ADD_CMPR)
	{
		header = ZC_readLines("removeZCCase.sh", &lineCount);
		preLine = header;
		StringLine* curLine = NULL;
		StringLine* newHeader = NULL, *newTailer = NULL;
		for(i=0;preLine->next!=NULL;i++)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##New compressor");
			if(tag)
			{
				newHeader = preLine;
				newTailer = curLine;
				break;
			}
			preLine = preLine->next;
		}
		
		if(tag==0)
		{
			ZC_freeLines(header);
			printf("Error: The line '##New compressor' is missing in removeZCCase.sh\n");
			printf("Reason: You probably removed that line manually in removeZCCase.sh\n");
			printf("Solution: add this line '##New compressor to be added here' before \n\telse\n\t\techo No such testcase: $testcase\n\t\texit\n\tfi\n");
			return MANAGE_FAIL;
		}
		
		//add lines
		StringLine* insertLines = createStringLineHeader();
		StringLine* insertLinesTail = insertLines;

		char* buf2 = (char*)malloc(1024);
		sprintf(buf2, "##begin: Compressor %s\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "\trm -rf %s/${testcase}_%s\n", workspaceDir, mode);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "##end: Compressor %s\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		newHeader->next = insertLines->next;
		insertLinesTail->next = newTailer;

		free(insertLines); //actually only free the header of insertlines

	}
	else //operation == DELETE_CMPR
	{
		char buf2[1024];
		header = ZC_readLines("removeZCCase.sh", &lineCount);
		preLine = header;
		StringLine* curLine;
		StringLine* rmHeader = NULL, *rmTailer = NULL;
		while(preLine->next!=NULL)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##begin: Compressor");
			if(tag)
			{
				strcpy(buf2, curLine->str);
				strtok(buf2, delim);
				strtok(NULL, delim);
				p = strtok(NULL, delim);
				trim(p);
				if(strcmp(p, compressor)==0)
					rmHeader = preLine;
				preLine = preLine->next;
				continue;
			}
			tag = ZC_startsWithLines(curLine, "##end: Compressor");
			if(tag)
			{
				strcpy(buf2, curLine->str);
				strtok(buf2, delim);
				strtok(NULL, delim);
				p = strtok(NULL, delim);
				trim(p);
				if(strcmp(p, compressor)==0)
				{
					rmTailer = curLine;
					break;
				}
			}
			preLine = preLine->next;
		}

		//delete compressor
		if(rmHeader==NULL||rmTailer==NULL)
		{
			printf("No such a compressor in removeZCCase.sh: %s\n", compressor);
			return MANAGE_FAIL;
		}
		else
			ZC_removeLines(rmHeader, rmTailer);	
	}
	ZC_writeLines(header, "removeZCCase.sh");
	
	if(header!=NULL)
		ZC_freeLines(header);	
	return MANAGE_SUC;
}

int removeComparisonCases(StringLine* line, char* compressor)
{
	int len = 0;
	char value[512], buf[512], buf2[1024];
	char* newStr = (char*)malloc(512);
	memset(newStr, 0, 512);
	strcpy(newStr, "comparisonCases=\"");
	memset(buf2, 0, 512);
	char* p = strtok(line->str, delim4); //split by "="
	
	if(strcmp(p, "comparisonCases")!=0)
		return 0;
	else
	{
		p = strtok(NULL, delim4);
		strcpy(value, p); //value
		trim(value);
		ZC_ReplaceStr2(value, "\"", ""); //remove '"'
		char* q = strtok(value, delim), *r = NULL; //q is one item like sz_f(1E-1),sz_d(1E-1),zfp(1E-1)
		int i = 0;
		char buff[10][1024];
		for(i=0;q!=NULL;i++)
		{
			memset(buff[i], 0, 1024);
			strcpy(buff[i], q);
			q = strtok(NULL, delim);
		}
		int count = i;
		
		for(i=0;i<count;i++)
		{
			strcpy(buf, buff[i]); //buf
			r = strtok(buf, delim5); //split by ","
			while(r!=NULL)
			{
				if(!ZC_startsWith(r, compressor))
				{
					sprintf(buf2, "%s%s,", newStr, r);
					strcpy(newStr, buf2);
				}
				r = strtok(NULL, delim5);
			}
			//rmove the last ','
			len = strlen(newStr);
			newStr[len-1] = ' ';
		}
		trim(newStr);
		len = strlen(newStr);
		newStr[len]='\"';
		newStr[len+1] = '\n';
		newStr[len+2] = '\0';
		free(line->str);
		line->str = newStr;
		return 1;
	}
}

int processErrBounds(int operation, char* compressor)
{
	int i = 0, lineCount = 0, tag = 0;
	StringLine* header = NULL, *preLine = NULL;
	char* p = NULL;
	char buf[1024];
	memset(buf, 0, 1024);

	if(operation == PRINT_INFO)
	{
		return MANAGE_SUC;
	}
	else if(operation == ADD_CMPR)
	{
		header = ZC_readLines("errBounds.cfg", &lineCount);
		preLine = header;
		StringLine* curLine = NULL;
		StringLine* newHeader = NULL, *newTailer = NULL;
		for(i=0;preLine->next!=NULL;i++)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##New compressor");
			if(tag)
			{
				newHeader = preLine;
				newTailer = curLine;
				break;
			}
			preLine = preLine->next;
		}
		
		if(tag==0)
		{
			ZC_freeLines(header);
			printf("Error: The line '##New compressor' is missing in errBounds.cfg\n");
			printf("Reason: You probably removed that line manually in errBounds.cfg\n");
			printf("Solution: add this line '##New compressor to be added here' before '#Compression cases used for comparison between compressors'\n");
			return MANAGE_SUC;
		}
		//add lines
		StringLine* insertLines = createStringLineHeader();
		StringLine* insertLinesTail = insertLines;

		char* buf2 = (char*)malloc(1024);
		sprintf(buf2, "##begin: Compression_error_bounds for %s\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "%s_ERR_BOUNDS=\"5E-1 1E-1 1E-2 1E-3\"\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		buf2 = (char*)malloc(1024);
		sprintf(buf2, "##end: Compression_error_bounds for %s\n", compressor);
		insertLinesTail = appendOneLine(insertLinesTail, buf2);

		newHeader->next = insertLines->next;
		insertLinesTail->next = newTailer;

		free(insertLines); //actually only free the header of insertlines
		ZC_writeLines(header, "errBounds.cfg");
	}
	else //operation == DELETE_CMPR
	{
		char buf2[1024];
		header = ZC_readLines("errBounds.cfg", &lineCount);
		preLine = header;
		StringLine* curLine;
		StringLine* rmHeader = NULL, *rmTailer = NULL;
		while(preLine->next!=NULL)
		{
			curLine = preLine->next;
			tag = ZC_startsWithLines(curLine, "##begin: Compression_error_bounds");
			if(tag)
			{
				strcpy(buf2, curLine->str);
				strtok(buf2, delim); //##begin:
				strtok(NULL, delim); //Compression_error_bounds
				strtok(NULL, delim); //for
				p = strtok(NULL, delim);
				trim(p);
				if(strcmp(p, compressor)==0)
					rmHeader = preLine;
				preLine = preLine->next;
				continue;
			}
			tag = ZC_startsWithLines(curLine, "##end: Compression_error_bounds");
			if(tag)
			{
				strcpy(buf2, curLine->str); 
				strtok(buf2, delim); //##end:
				strtok(NULL, delim); //Compression_error_bounds
				strtok(NULL, delim); //for
				p = strtok(NULL, delim); 
				trim(p);
				if(strcmp(p, compressor)==0)
				{
					rmTailer = curLine;
					break;
				}
			}
			
			preLine = preLine->next;
		}

		//delete the error bound information for the compressor
		if(rmHeader!=NULL||rmTailer!=NULL)
			ZC_removeLines(rmHeader, rmTailer);	
			
		//check comparisonCases setting and delete the compressor
		preLine = header;
		while(preLine->next!=NULL)
		{
			curLine = preLine->next;
			
			tag = ZC_startsWithLines(curLine, "comparisonCases");
			if(tag)
			{
				int status = removeComparisonCases(curLine, compressor);
				if(status==0) //failed
				{
					printf("Error: cannot fild ccomparisonCases setting in errBounds.cfg\n");
					return MANAGE_FAIL;
				}
				break;
			}			
			preLine = preLine->next;
		}	
			
		ZC_writeLines(header, "errBounds.cfg");
	}
	
	if(header!=NULL)
		ZC_freeLines(header);	
		
	return MANAGE_SUC;	
}

int modify_data_distortion_sh(char* compressor)
{
	int i = 0, lineCount = 0, tag = 0;
	StringLine* header = NULL, *preLine = NULL;
	
	char errBoundKey[1024];
	sprintf(errBoundKey, "%s_ERR_BOUNDS", compressor);
	
	header = ZC_readLines("zc-ratedistortion.sh", &lineCount);
	ZC_replaceLines(header, "ZZ_ERR_BOUNDS", errBoundKey);
	ZC_writeLines(header, "zc-ratedistortion.sh");
	if(header!=NULL)
		ZC_freeLines(header);		
		
	return MANAGE_SUC;
}

int modify_exe_CompDecomp_sh(char* compressor, char* exeCommand)
{
	int i = 0, lineCount = 0, tag = 0;
	StringLine* header = NULL, *preLine = NULL;
	
	header = ZC_readLines("exe_CompDecomp.sh", &lineCount);
	
	ZC_replaceLines(header, "COMPRESSOR", compressor);
	
	preLine = header;
	StringLine* curLine;
	while(preLine->next!=NULL)
	{
		curLine = preLine->next;
		if(ZC_startsWithLines(curLine, "##EXECOMMAND_FILE"))
		{
			char buf[1024]; 
			char *buf2 = (char*)malloc(1024);
			strcpy(buf, exeCommand);
			ZC_ReplaceStr2(buf, "COMPRESSION_CASE", "\"${compressor}($absErrBound)\""); 
			ZC_ReplaceStr2(buf, "DATA_TYPE", "\"$datatype\"");
			ZC_ReplaceStr2(buf, "VAR_NAME", "\"$file\"");
			ZC_ReplaceStr2(buf, "ERROR_MODE", "$errBoundMode");
			ZC_ReplaceStr2(buf, "ERROR_BOUND", "$absErrBound");
			ZC_ReplaceStr2(buf, "DATA_FILE", "\"$dataDir/$file\"");
			ZC_ReplaceStr2(buf, "DIM1", "$dim1");
			ZC_ReplaceStr2(buf, "DIM2", "$dim2");
			ZC_ReplaceStr2(buf, "DIM3", "$dim3");
			ZC_ReplaceStr2(buf, "DIM4", "$dim4");
			sprintf(buf2, "\t\t%s\n", buf);
			StringLine* newCommand = generateOneStringLine(buf2);
			preLine->next = newCommand;
			newCommand->next = curLine->next;
			curLine->next = NULL;
			ZC_freeLines(curLine);
		}
		else if(ZC_startsWithLines(curLine, "##EXECOMMAND_VAR"))
		{
			char buf[1024];
			char *buf2 = (char*)malloc(1024);
			strcpy(buf, exeCommand);
			ZC_ReplaceStr2(buf, "COMPRESSION_CASE", "\"${compressor}($absErrBound)\""); 
			ZC_ReplaceStr2(buf, "DATA_TYPE", "\"$datatype\"");
			ZC_ReplaceStr2(buf, "VAR_NAME", "\"$varName\"");
			ZC_ReplaceStr2(buf, "ERROR_MODE", "$errBoundMode");
			ZC_ReplaceStr2(buf, "ERROR_BOUND", "$absErrBound");
			ZC_ReplaceStr2(buf, "DATA_FILE", "\"$file\"");
			ZC_ReplaceStr2(buf, "DIM1 DIM2 DIM3 DIM4", "$dims");
			sprintf(buf2, "\t\t%s\n", buf);
			StringLine* newCommand = generateOneStringLine(buf2);
			preLine->next = newCommand;
			newCommand->next = curLine->next;
			curLine->next = NULL;
			ZC_freeLines(curLine);			
		}
		
		preLine = preLine->next;
	}
	
	ZC_writeLines(header, "exe_CompDecomp.sh");
	if(header!=NULL)
		ZC_freeLines(header);	
		
	return MANAGE_SUC;
}

int check_errBounds_cfg(char* errBoundsFile)
{
	if (access(zc_cfgFile, F_OK) != 0)
	{
		printf("[ZC] Configuration file NOT accessible.\n");
		return 1;
	}
	int lineCount = 0;
	StringLine* lines = ZC_readLines(errBoundsFile, &lineCount);
	
	
}

int main(int argc, char* argv[])
{
	int operation = -1;

	char* compressorName = NULL;
	char* mode = NULL;
	char* compressor = NULL;
	char* workspaceDir = NULL;
	int dimLimit = -1; //-1 means no dims limit
	bool dimReverse = false;

	char* conFile = NULL;
	int varID = -1;
	if(argc==1)
	{
		usage();
		return 0;
	}

	int i = 0;
	for(i=1;i<argc;i++)
	{
		if (argv[i][0] != '-' || argv[i][2])
			usage();
		switch (argv[i][1])
		{
		case 'c':
			if (++i == argc)
				usage();
			conFile = argv[i];
			break;
		case 'a':
			if (++i == argc)
				usage();
			operation = ADD_CMPR;
			compressorName = argv[i];
			break;
		case 'd':
			if (++i == argc)
				usage();
			operation = DELETE_CMPR;
			compressorName = argv[i];
			break;
		case 'z':
			if (++i == argc)
				usage();
			operation = MODIFY_RATE_DISTORTION_SH;
			compressor = argv[i];
			break;
		case 'm':
			if (++i == argc)
				usage();
			mode = argv[i];
			break;
		case 'w':
			if (++i == argc)
				usage();
			workspaceDir = argv[i];
			break;			
		case 'p':
			operation = PRINT_INFO;
			break;
		case 'k':
			operation = CHECK_ERRBOUNDS;
			break;
		case 'i':
			if (++i == argc)
				usage();
			dimLimit = atoi(argv[i]);
			break;
		case 'r':
			dimReverse = true;
			break;
		default: 
			usage();
			break;
		}
	}

	char* compressorName_ = NULL, *mode_ = NULL, *compressor_ = NULL, *workspaceDir_ = NULL, *exeDir = NULL, *preCommand = NULL, *exeCommand = NULL;
	
	if(conFile!=NULL)
	{
		int loadStatus = loadConfFile(conFile, &compressorName_, &mode_, &compressor_, &workspaceDir_, &exeDir, &preCommand, &exeCommand);
		if(loadStatus==1)
		{
			printf("Error: wrong configuration file\n");
			exit(0);
		}
	}
	
	if(operation>=10 && (compressorName == NULL || exeCommand == NULL || exeDir == NULL))
	{
		printf("Error: you need to specify compressor and exeDir and exeCommand.\n");
		usage();
		exit(0);
	}

	if(dimLimit > 4 || dimLimit < -1)
	{
		printf("Error: The dimension limit ranges from 1 to 4.\n");
		usage();
		exit(0);
	}
	
	if(workspaceDir==NULL)
		workspaceDir = workspaceDir_;
	if(compressorName==NULL)
		compressorName = compressorName_;
	if(mode==NULL)
		mode = mode_;
	if(mode==NULL)
		mode = "";
	
	if(compressor == NULL)
		compressor = compressor_;
	
	if(operation == CHECK_ERRBOUNDS)
	{
		
	}
	else if(operation==MODIFY_RATE_DISTORTION_SH)
	{
		modify_data_distortion_sh(compressor);
		
		//modify exe_CompDecomp.sh
		modify_exe_CompDecomp_sh(compressor, exeCommand);
	}
	else
	{
		//modify createZCCase.sh
		char confFilePath[PATH_MAX+1];
		char* res = realpath(conFile, confFilePath);
		if(!res)
		{
			printf("cannot find the path of the file \n");
			return 1;
		}
		int a = processCreateZCCase(operation,compressorName, mode, compressor, workspaceDir, exeDir, preCommand, exeCommand, confFilePath);

		//modify runZCCase.sh
		int b = processRunZCCase(operation, mode, compressor, workspaceDir, dimLimit, dimReverse);

		//modify removeZCCase.sh
		int c = processRemoveZCCase(operation, mode, compressor, workspaceDir);

		//modify errBounds.cfg
		int d = 0;
		if(a*b*c!=0)
			d = processErrBounds(operation, compressor);
		
		if(a*b*c*d == 1)
		{
			if(operation==ADD_CMPR)
				printf("The compressor %s has been added successfully.\n", compressor);
			else if(operation==DELETE_CMPR)
				printf("The compressor %s has been deleted successfully.\n", compressor);
		}
		else
		{
			printf("Failed when ");
			if(a==0)
				printf("processing CreateZCCase\n");
			else if(b==0)
				printf("processing RunZCCase\n");
			else if(c==0)
				printf("processing RemoveZCCase\n");
			else
				printf("processing ErrBounds\n");
		}
	}
	if(compressorName_!=NULL)
		free(compressorName_);
	if(mode_!=NULL)
		free(mode_);
	if(compressor_!=NULL)
		free(compressor_);
	if(workspaceDir_!=NULL)
		free(workspaceDir_);
	if(exeDir!=NULL)
		free(exeDir);
	if(preCommand!=NULL)
		free(preCommand);
	if(exeCommand!=NULL)
		free(exeCommand);
}
