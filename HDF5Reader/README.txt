[INSTALL HDF5Reader package in Z-checker]

Step 1. Install HDF5 package such as hdf5-1.10.1-install. 

Step 2. Modify HDF5PATH in ./Makefile.linux2 as follows:

HDF5PATH        = [Your installation path that contains include and lib]

Suppose that the installation path as '/home/sdi/Install/hdf5-1.10.1-install', then HDF5PATH        = /home/sdi/Install/hdf5-1.10.1-install

Step 3. Execute 'installHDF5Reader.sh'

[Read HDF5 and generate Z-checker report]

Step 1. Execute 'testHDF5_CompDecomp' in the local directory. (Note: testHDF5_CompDecomp is generated after performing Step 3 in the above installation procedure.)

Usage: testHDF5_CompDecomp <options>
Options:
* input HDF5 file:
	-i <hdf5 file>: specify the input hdf5 file
* configuration files:
	-e <err config file>: specify the error bound configuration
	-c <zc config file>: specify the ZC configuration file
* field filter: selecting the fields in terms of specific info.
	-d <dimsensions> : 1(1D), 2(2D), 3(3D), 12(1D+2D), 13(1D+3D), 23(2D+3D), ...
	-f <fields> : field1,field2,.... (separated by comma)
	-1 <nx> : only 1D fields with <nx> dimension will be selected
	-2 <nx> <ny> : only 2D fields with <nx> <ny> will be selected
	-3 <nx> <ny> <nz> : dimensions for 3D data such as data[nz][ny][nx] 
	-4 <nx> <ny> <nz> <np>: dimensions for 4D data such as data[np][nz][ny][nx] 
 	-n <number of elements> : only the fields with >= <number of elements>
	-t <data type> : only the field with the specific data type. 0:float; 1:double
* error bounds: specifying the error bounds
	-R <value range based error bound>
	-A <absolute error bound
	-P <point-wise relative error bound
* output Workspace
	-o <workspace dir>
* examples:
	testHDF5_CompDecomp -i SZ/example/testdata/x86/testfloat_8_8_128.h5 -d 3 -c Z-checker/examples/zc.config -e ../errBounds.cfg

The 'field filter' in testHDF5_CompDecomp can help select the fields based on specified requirement, such as only selecting 2D fields, some specific data type (float or double). 
If there are multiple customzed requirements, such as -t 0 -n 1000 -d 2D, they will be combined together (i.e., AND operation).

Note: After executing testHDF5_CompDecomp, two directories - dataProperties and compressionResults - will be generated in the local directory. These two directories contain the data anaysis results and compression results, respectively.

Step 2. Execute 'runZCCase.sh [workspace_name]' to move the results to the workspace and generate Z-checker report.
Example: runZCCase.sh CESM-ATM

Note: If you already executed runZCCase_hdf5.sh, remember to use removeZCCase.sh to remove the old workspace case before running runZCCase_hdf5.sh again.
