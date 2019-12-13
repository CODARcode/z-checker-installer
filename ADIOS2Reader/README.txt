1. Modify the ADIOS2's installation path in Makefile
2. make
3. execute 'testAdios2'

Usage: testAdios2 <options>
Options:
* input & output:
       -i <input file> : input file
       -o <output dir> : output directory
* operation type:
       -r <workspace> <error-bound type>: directly generate assessment report
           * <workspace> is the name of the test use-case.
           * <error-bound type> is the type of error bound, either ABS or REL
       -R <root-dir>: this specifies the root directory of z-checker-installer
           (it is ../ by default if you run the testAdios2 command under ADIOS2Reader/)
       -h: print the help information
* select variables:
       -n <number of variables>
       -v <variables ....>: the n variables to be extracted
       -l <L> : select the variables whose # data points is no smaller than L
       -u <U> : select the variables whose # data points is no greater than U
       -t <T> : select the variables with data type T [float/double]
       -d <D> : select the variables with the dimension D
* examples:
       testAdios2 -i myVector_cpp.bp -n 2 -v bpFloats bpInts -o .
       testAdios2 -i myVector_cpp.bp -o ./outputData -r testmyVector REL

The generated binary data files will be put with 'varInfo.txt', which contains the extracted variables' information. 
varInfo.txt and the binary files can be processed by runZCCase.sh

If you use the option -r, the Z-checker report will be generated directly after running the testAdios2 command.
