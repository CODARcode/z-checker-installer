[INSTALL HDF5Reader package in Z-checker]

Step 1. Install HDF5 package such as hdf5-1.10.1-install. 

Step 2. Modify HDF5PATH in Z-checker/HDF5Reader/Makefile.linux2 as follows:

HDF5PATH        = [Your installation path that contains include and lib]

Suppose that the installation path as '/home/sdi/Install/hdf5-1.10.1-install', then HDF5PATH        = /home/sdi/Install/hdf5-1.10.1-install

Step 3. Execute 'installHDF5Reader.sh'

[Read HDF5 and generate Z-checker report]

Step 1. Execute 'testHDF5_CompDecomp' in the local directory. (Note: testHDF5_CompDecomp is generated after performing Step 3 in the above installation procedure.)
After executing testHDF5_CompDecomp, two directories - dataProperties and compressionResults - will be generated in the local directory.

Step 2. Execute 'runZCCase.sh [workspace_name]'
Example: runZCCase.sh CESM-ATM

