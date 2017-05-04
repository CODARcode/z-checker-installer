# z-checker-installer

 (C) 2017 by Mathematics and Computer Science (MCS), Argonne National Laboratory.
       See COPYRIGHT in top-level directory.

***Authors: Sheng Di, Hanqi Guo ***

one-key installation to install gnuplot, sz, zfp, and z-checker, and complete the configuration automatically for the testing.

#########3rd party libraries/tools#########

git

gnuplot

latexmk (todo, not supported yet)


#########Testing/Installation method#######

z-checker-install.sh will download gnuplot, Z-checker, ZFP, and SZ and install them one by one automatically, and then add the patches to let ZFP and SZ fit for Z-checker.

z-checker-install2.sh will download Z-checker, ZFP, and SZ and install them, without installation of gnuplot (assuming you already installed gnuplot).

After installation, please download the two testing data sets, CESM-ATM and MD-simulation (exaalt). The two data sets are available only for the purpose of research of compression. Please ask for the data by contacting sdi1@anl.gov if interested.
 
Then, you can generate compression results with SZ and ZFP using the following simple steps: 

1. Go to zfp/utils/, and then execute "zfp-zc-ratedistortion.sh [data directory] [dimension sizes....]". The compression results are stored in the compressionResults/ directory.
	For example, suppose the directory of CESM-ATM data set is here: /home/shdi/CESM-testdata/1800x3600, then the command is "zfp-zc-ratedistortion.sh /home/shdi/CESM-testdata/1800x3600 3600 1800". Note: the data files stored in the directory are also ending with .dat and the dimension sizes are the same (1800x3600) in this test-case.

2. Similarly, go to SZ/example/, and then generate compression results by SZ compressor as follows: "sz-zc-ratedistortion.sh [data directory] [dimension sizes....]". The compression results are stored in the compressionResults/ directory.
	As for the example CESM-ATM, the test command is "sz-zc-ratedistortion.sh /home/shdi/CESM-testdata/1800x3600 3600 1800".

3. Then, go to Z-checker/examples/ directory, and run the command "./analyzeDataProperty.sh [data directory] [dimension sizes....]" to generate the data properties based on the data sets. This step has nothing to do with the compressors. The data analysis results are stored in the dataProperties/ directory. 

4. Generate the figure files: run the command "./generateReport.sh" simply. The results of comparing different compressors (such as sz and zfp in this test-case) are stored in the directory called compareCompressors/.


