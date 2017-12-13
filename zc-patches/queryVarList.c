#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

#define MAX_MSG_LENGTH 512

#define QV_FLOAT 0
#define QV_DOUBLE 1
#define QV_LITTLE_ENDIAN 0
#define QV_BIG_ENDIAN 1

#define DELIM ":"
#define DELIM2 "x"

typedef struct VarItem
{
	int varID;
	char varName[64];
	int dataType;
	int endianType;
	int dimSize;
	long dim1; //low dimension
	long dim2;
	long dim3;
	long dim4;
	long dim5; //high dimension
	char dataFilePath[256];
	
	struct VarItem* next; 
} VarItem;

void ltrim(char *s)
{
	char *p;
	p = s;
	if(p==NULL)
		return;
	while(*p == ' ' || *p == '\t')
	{
		p++;
	}
	memcpy(s, p, strlen(p)+1);
//	strcpy(s,p);
}

void rtrim(char *s)
{
	int i;
	if(s==NULL)
		return;
	i = strlen(s)-1;
	while((s[i] == ' ' || s[i] == '\t' || s[i] == '\n') && i >= 0){i--;};
	s[i+1] = '\0';
}

void trim(char *s)
{
	ltrim(s);
	rtrim(s);
}

void usage()
{
	printf("Usage: queryVarList <options>\n");
	printf("Options:\n");
	printf("* input information:\n");
	printf("	-i <original var_list file> : original file containing variables\n");
	printf("	-v <variable name> : specify variable name\n");
	printf("	-I <variable ID> : specify a variable by variable ID\n");
	printf("* control options:\n");
	printf("	-n : print number of variables\n");
	printf("	-l : list all variables (separate by space)\n");
	printf("	-d : print dimensions (e.g., 8 8 128)\n");
	printf("	-e : print endian_type (LITTLE_ENDIAN or BIG_ENDIAN)\n");
	printf("	-t : print data type (float or double)\n");
	printf("	-f : print the file path\n");
	printf("	-m : print the name of variable\n");
	printf("* Examples:\n");
	printf("	queryVarList -l -i multivars2.txt\n");
	printf("	queryVarList -v CLDLOW -d -i multivars2.txt\n");
	printf("	queryVarList -v CLDHGH -e -i multivars2.txt\n");
	printf("	queryVarList -I 2 -d -i multivars2.txt\n");
	printf("	queryVarList -I 3 -t -i multivars2.txt\n");
	printf("	queryVarList -n -i multivars2.txt\n");
	printf("	queryVarList -m -I 2 -i multivars2.txt\n");
}

VarItem* createVarItemHeader()
{
	VarItem* header = (VarItem*)malloc(sizeof(VarItem));
	memset(header, 0, sizeof(VarItem));
	return header;
}

VarItem* appendOneLine(VarItem* tail, char* str, int id)
{
	VarItem* newItem = (VarItem*)malloc(sizeof(VarItem));
	memset(newItem, 0, sizeof(VarItem));

	char* token, *token2;
	token = strtok(str, DELIM);
	newItem->varID = id;
	strcpy(newItem->varName, token);
	
	token = strtok(NULL, DELIM);
	if(strcmp(token, "LITTLE_ENDIAN")==0)
		newItem->endianType = QV_LITTLE_ENDIAN;
	else if(strcmp(token, "BIG_ENDIAN")==0)
		newItem->endianType = QV_BIG_ENDIAN;	
	
	token = strtok(NULL, DELIM);
	if(strcmp(token, "FLOAT")==0)
		newItem->dataType = QV_FLOAT;
	else if(strcmp(token, "DOUBLE")==0)
		newItem->dataType = QV_DOUBLE;	

	token = strtok(NULL, DELIM);
	char tmpStr[64], tmpStr2[256];
	strcpy(tmpStr, token);

	token = strtok(NULL, DELIM);
	strcpy(tmpStr2, token);

	int i = 0, n = 0;
	long d[5] = {0,0,0,0,0};	
	token2 = strtok(tmpStr, DELIM2);
	d[0] = atol(token2);
	n = 1;
	for(i=1;token2 = strtok(NULL, DELIM2);i++)
	{
		d[i] = atol(token2);
		n++;
	}

	switch(n)
	{
	case 1:
		newItem->dimSize = 1;
		newItem->dim1 = d[0];
		break;
	case 2:
		newItem->dimSize = 2;
		newItem->dim2 = d[0];
		newItem->dim1 = d[1];
		break; 
	case 3:
		newItem->dimSize = 3;
		newItem->dim3 = d[0];
		newItem->dim2 = d[1];
		newItem->dim1 = d[2];
		break; 
	case 4:
		newItem->dimSize = 4;
		newItem->dim4 = d[0];
		newItem->dim3 = d[1];
		newItem->dim2 = d[2];
		newItem->dim1 = d[3];
		break; 
	case 5:
		newItem->dimSize = 5;
		newItem->dim5 = d[0];
		newItem->dim4 = d[1];
		newItem->dim3 = d[2];
		newItem->dim2 = d[3];
		newItem->dim1 = d[4];
		break;
	}
	
	trim(tmpStr2);
	strcpy(newItem->dataFilePath, tmpStr2);
	
	tail->next = newItem;
	return newItem;
}

VarItem* ZC_readVarItems(char* filePath, int *varCount)
{
	char* buf;
	//char buf[500] = {0};
	int len = 0, i = 0;

	FILE *fp = fopen(filePath, "r");
	if(fp == NULL)
	{
		printf("failed to open the file %s\n", filePath);
		exit(0);
	}

	VarItem *header = createVarItemHeader();
	VarItem *tail = header; //the last element
	
	while(!feof(fp))
	{
		buf = (char*)malloc(MAX_MSG_LENGTH);
		memset(buf, 0, MAX_MSG_LENGTH);
		fgets(buf, MAX_MSG_LENGTH, fp); // already including \n
		if(buf[0]=='#' || strcmp(buf, "")==0 || strcmp(buf, "\n")==0)
			continue;
		tail = appendOneLine(tail, buf, i);
		i++;
	}
	*varCount = i;

	fclose(fp);	
	return header;
}

int main(int argc, char* argv[])
{
	int printNbVars = 0;
	int listAllVars = 0;
	int printDims = 0;
	int printEndianType = 0;
	int printDataType = 0;
	int printFilePath = 0;
	int printVarName = 0;

	char* inPath = NULL;
	char* varName = NULL;
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
		case 'n': 
			printNbVars = 1;
			break;
		case 'l': 
			listAllVars = 1;
			break;
		case 'd':
			printDims = 1;
			break;
		case 'e':
			printEndianType = 1;
			break;
		case 't': 
			printDataType = 1;
			break;
		case 'f':
			printFilePath = 1;
			break;
		case 'm':
			printVarName = 1;
			break;
		case 'i':
			if (++i == argc)
				usage();
			inPath = argv[i];		
			break;
		case 'v':
			if (++i == argc)
				usage();
			varName = argv[i];
			break;
		case 'I':
			if (++i == argc)
				usage();
			varID = atoi(argv[i]);
			break;
		default: 
			usage();
			break;
		}
	}

	if(inPath == NULL)
	{
		printf("Error: you need to specify either a raw binary data file or a compressed data file as input\n");
		usage();
		exit(0);
	}
	
	int varCount = 0;
	VarItem* varItemHeader = ZC_readVarItems(inPath, &varCount);
	VarItem* p = varItemHeader->next;
	
	if(listAllVars)
	{
		p = varItemHeader->next;
		printf("%s", p->varName);
		p = p->next;
		while(p!=NULL)
		{
			printf(" ");
			printf("%s", p->varName);
			p = p->next;
		}
		return 0;
	}
	
	if(printNbVars)
	{
		printf("%d", varCount);
		return 0;
	}
		
	//the following functions require targetItem to be non NULL	
	
	p = varItemHeader->next;
	if(varName!=NULL)
	{
		for(i=0;i<varCount && p!=NULL;i++,p=p->next)
		{
			if(strcmp(varName, p->varName))
				break;
		}
	}
	else if(varID!=-1)
	{
		for(i=0;i<varCount && p!=NULL;i++,p=p->next)
		{
			if(p->varID == varID)
				break;
		}		
	}	
	
	VarItem* targetItem = p;
	
	if(targetItem == NULL)
	{
		printf("NULL");
		return 0;
	}
	
	if(printDims)
	{
		switch(targetItem->dimSize)
		{
		case 1:
			printf("%ld", targetItem->dim1);
			break;
		case 2:
			printf("%ld %ld", targetItem->dim1, targetItem->dim2);
			break;
		case 3: 
			printf("%ld %ld %id", targetItem->dim1, targetItem->dim2, targetItem->dim3);
			break;
		case 4:
			printf("%ld %ld %ld %ld", targetItem->dim1, targetItem->dim2, targetItem->dim3, targetItem->dim4);
			break;
		case 5:
			printf("%ld %ld %ld %ld %ld", targetItem->dim1, targetItem->dim2, targetItem->dim3, targetItem->dim4, targetItem->dim5);
			break;
		}
		return 0;
	}
	
	if(printEndianType)
	{
		printf("%d", targetItem->endianType);
		return 0;
	}
	
	if(printDataType)
	{
		printf("%d", targetItem->dataType);
		return 0;
	}

	if(printFilePath)
	{
		printf("%s", targetItem->dataFilePath);
		return 0;
	}

	if(printVarName)
	{
		printf("%s", targetItem->varName);
		return 0;
	}
	
}
