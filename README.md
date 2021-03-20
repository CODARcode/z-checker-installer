# Z-checker installer

 (C) 2017-2021 by Mathematics and Computer Science (MCS), Argonne National Laboratory.

See COPYRIGHT in top-level directory.


Major authors: Sheng Di, Dingwen Tao, Hanqi Guo
Other contributors: Robert Underwood, Hengzhi Chen

## 3rd party libraries/tools

- cmake (version: 3.13+)
- gcc (version: 7.3+)
- g++
- git
- texlive (e.g., execute 'sudo yum install texlive-*' on linux)
- ghostscript(gsview) (z-checker-install.sh can install it automatically if missing)
- latexmk (z-checker-install.sh will install latexmk automatically if missing)
- gnuplot (z-checker-install.sh will install gnuplot automatically if missing)
- perl (used by only web-visualization support)

The following libraries - libpng, tif22pnm and sam2p are used to convert slice image png files to eps. If plotSliceImag option is disabled (in zc.config), these three libraries are not needed. 
- libpng (z-checker-install.sh will install tif22pnm automatically if missing; in fact, libpng can be installed using system installation command such as 'yum install libpng-devel' on linux.)
- tif22pnm (z-checker-install.sh will install tif22pnm automatically if missing)
- sam2p (z-checker-install.sh will install sam2p automatically if missing)

For simplicity, 
the Fedora users need to run the following command for installation: 
```bash
sudo dnf install -y gcc gcc-c++ git cmake zlib-devel libzstd-devel gfortran which xorg-x11-server-Xorg gnuplot libpng-devel findutils unzip latexmk texlive
<!-- required texlive package: "tex(${comment.sty})" "tex(${pifont.sty})" "tex(${natbib.sty})" "tex(${amsmath.sty})" "tex(${morefloats.sty})" "tex(${geometry.sty})" "tex(${nopageno.sty})" "tex(${subfigure.sty})" "tex(${enumitem.sty})"-->
git clone http://github.com/CODARcode/z-checker-installer
cd z-checker-installer
./z-checker-install.sh
```

the Ubuntu users need to run the following command for installation: 
```bash
sudo sudo apt-get install -y gcc g++ git cmake zlib-devel gfortran gnuplot libpng-devel xorg openbox findutils unzip latexmk texlive-full texlive-fonts-recommends --no-install-recommends
git clone http://github.com/CODARcode/z-checker-installer
cd z-checker-installer
./z-checker-install.sh
```

## Testing/Installation method

z-checker-install.sh will download latexmk, gnuplot, Z-checker, ZFP, and SZ and install them one by one automatically, and then add the patches to let ZFP and SZ fit for Z-checker.

After installation, please download the two testing data sets, CESM-ATM and MD-simulation (exaalt). The two data sets are available only for the purpose of research of compression. Please ask for the data by contacting [sdi1@anl.gov]() if interested.

LibpressioOPT is a library that is able to search for the appropriate error bound setting based on user-sepcified metric values such as compression ratio and PSNR. Z-checker itself has some simple built-in algorithms to do this work, which may not be as accurate as LibpressioOPT. To this end, you also need to install spack and use spack to install some preliminary libraries. For more details, please read the z-checker-installer-instruction.pdf in the ./doc/ directory. If you don't need LibpressioOPT, you just need to run './z-checker-installer.sh' to install everything.

### Quick Start

Then, you are ready to conduct the compression checking.
You can generate compression results with SZ and ZFP using the following simple steps: 
(Note: you have to run z-checker-install.sh to install the software before doing the following tests)

1. Configure the error bound setting and comparison cases in errBounds.cfg.

2. Create a new test-case, by executing "createZCCase.sh [test-case-name]". You need to replace [test-case-name] by a meaningful name.
   For example:
   [user@localhost z-checker-installer] ./createZCCase.sh CESM-ATM-tylor-data

3. Perform the checking by running the command "runZCCase.sh": runZCCase.sh [data_type] [error-bound-mode] [test-case-name] [data dir] [extension] [dimensions....].
   Example:
   [user@localhost z-checker-installer] ./runZCCase.sh -f REL CESM-ATM-tylor-data /home/shdi/CESM-testdata/1800x3600 dat 3600 1800

Then, you can find the report generated in z-checker-installer/Z-checker/[test-case-name]/report.

### Step-by-step Checking

Unlike the above one-command checking, the following steps present the generation of compression results step by step.

1. Go to zfp/utils/, and then execute "zfp-zc-ratedistortion.sh [data directory] [dimension sizes....]". The compression results are stored in the compressionResults/ directory.
   For example, suppose the directory of CESM-ATM data set is here: /home/shdi/CESM-testdata/1800x3600, then the command is "zfp-zc-ratedistortion.sh /home/shdi/CESM-testdata/1800x3600 3600 1800". Note: the data files stored in the directory are also ending with .dat and the dimension sizes are the same (1800x3600) in this test-case.

2. Similarly, go to SZ/example/, and then generate compression results by SZ compressor as follows: "sz-zc-ratedistortion.sh [data directory] [dimension sizes....]". The compression results are stored in the compressionResults/ directory.
   As for the example CESM-ATM, the test command is "sz-zc-ratedistortion.sh /home/shdi/CESM-testdata/1800x3600 3600 1800".

3. Then, go to Z-checker/examples/ directory, and run the command "./analyzeDataProperty.sh [data directory] [dimension sizes....]" to generate the data properties based on the data sets. This step has nothing to do with the compressors. The data analysis results are stored in the dataProperties/ directory. 

4. Generate the figure files: run the command "./generateReport.sh" simply. The results of comparing different compressors (such as sz and zfp in this test-case) are stored in the directory called compareCompressors/.

### Create a new case

"createZCCase.sh [test-case-name]" allows you to create a new test-case.  This command will create a new workspace directory in Z-checker, SZ, and zfp respectively. The compression results will be put in those workspace directories to avoid bing messed with other test-cases.

For example, if you run the generateReport.sh in the directory ./Z-checker/examples, it is actually one test case, where the compression results and data analysis results will be put in the dataProperty/ and compressionResults/ under it.
For another test case with another set of data or application, you can create a new workspace directory by the script createZCCase.sh (which calls ./Z-checker/createNewCase.sh).

### z-checker-update.sh

z-checker-update.sh can be used to update the repository (pull the new update from the server), so that you don't have to perform the update manually.

### web installation

Web installation allows to install a web server on the local machine, such that you can visualize the data through a local webpage and other people can view the data/results via that page if public ip is provided. 
z-checker-web-install.sh


### Add a new compressor
1. Make a monitoring program (e.g., called testfloat_CompDecomp.c) for your compressor. An example can be found in SZ/example/testfloat_CompDecomp.c, which is used for SZ compressor.)
2. Modify the manageCompressor.cfg based on the workspaceDir on your computer and directory containing the compiled executable monitoring program. 
3. Suppose the new compressor's name is zz and the compression mode is called 'best'; then, run the following command to add the new compressor: 
	./manageCompressor -a zz -m best -c manageCompressor.cfg
4. Then, open errBounds.cfg to modify the error bounds for the new compressor; and also modify the comparison cases as follows (the compressor name 'zz_b' was set in manageCompressor.cfg):
	comparisonCases="sz_f(1E-1),sz_d(1E-1),zfp(1E-1) sz_f(1E-2),sz_d(1E-2),zfp(1E-2)" --> comparisonCases="sz_f(1E-1),sz_d(1E-1),zfp(1E-1),zz_b(1E-2) sz_f(1E-2),sz_d(1E-2),zfp(1E-2),zz_b(1E-2)"
5. Finally, create a test case like this: ./createZCCase.sh case_name
6. Perform the assessment by runZCCase.sh.

### Remove a compressor
Remove sz_f (sz fast mode):
$ manageCompressor -d sz -m fast -c manageCompressor-sz-f.cfg
Remove sz_d (sz fast mode):
$ manageCompressor -d sz -m deft -c manageCompressor-sz-d.cfg
Remove zfp: 
$ manageCompressor -d zfp -c manageCompressor-zfp.cfg

### Generate Z-checker report based on HDF5 files

You can generate Z-checker report directly based on an HDF5 file. 
To this end, you need to install HDF5 library before hand, and then compile the Z-checker/HDF5Reader as follows: 

You need to modify Makefile.linux2 by replacing "HDF5PATH = /home/sdi/Install/hdf5-1.10.1-install" by your HDF5 installation path.
Then:
make -f Makefile.linux2

You will find the executable 'testHDF5_CompDecomp' generated on Z-checker/HDF5Reader/test/ directory.
You can use this command to read HDF5 file and generate analysis results.

After that, you can use 'installHDF5Reader.sh' and 'runZCCase_hdf5.sh' to generate the .pdf report. 
More details can be found in testHDF5/README.txt

### Generate Z-checker report based on ADIOS2 files

Go to the directory ADIOS2Header, and then do the following steps:
1. Modify the ADIOS2's installation path in Makefile
2. make
3. execute 'testAdios2'

Example:
testAdios2 -i myVector_cpp.bp -n 2 -v bpFloats bpInts -o [target output directory]

The generated binary data files will be put in the target output directory. A meta file called 'varInfo.txt' contains the extracted variables' information and it will be put in the target output directory as well.
varInfo.txt and the binary files can be processed by runZCCase.sh
