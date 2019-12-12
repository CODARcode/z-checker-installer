1. Modify the ADIOS2's installation path in Makefile
2. make
3. execute 'testAdios2'

Example:
testAdios2 -i myVector_cpp.bp -n 2 -v bpFloats bpInts -o .

The generated binary data files will be put with 'varInfo.txt', which contains the extracted variables' information. 
varInfo.txt and the binary files can be processed by runZCCase.sh
