#!/bin/bash

rootDir=`pwd`

if [ $1 = "-h" ]
then
	echo "Usage: ./z-checker-installer [libpressio_opt_prefix_installation_path]"
	echo "Hint: To use libpressio_opt, you need to install it using spack first; after installation, the libpressio_opt_prefix_installation_path contains include and lib64."
	echo "Example without libpressio-opt: ./z-checker-installer"
	echo "Example with libpressio-opt: ./z-checker-installer /lcrc/project/ECP-EZ/shdi/LibpressioOpt/libpressio_opt_example/.spack-env/view"
	exit
fi

if [ $# -gt 0 ]
then
	LibpressioOptPrefixDir=$1
	#check if the libpressio_opt has been installed successfully
	if [ ! -d $LibpressioOptPrefixDir ]
	then
		echo "Error: $LibpressioOptPrefixDir does not exsit."
		exit
	elif [ ! -f $LibpressioOptPrefixDir/include/libpressio_opt/pressio_search.h ]
	then
		echo "Error: missing libpressio_opt/pressio_search.h."
		echo "Please make sure Libpressio_Opt has been installed correctly."
		exit
	fi
fi

#----------check gcc version----------------
cd zc-patches
g++ -std=c++17 foo.cc
if [[ $? == 1 ]]
then
	echo "Fatal issue: too old gcc version! "
	echo "Please update your gcc to gcc 7.3 or later version."
 	exit
fi
 
cd $rootDir


#----------check X11------------------------
X_PATH=`which X`
if [ ! -x ${X_PATH} ];then
	echo "Error: missing X11!"
	echo "Please install X11 first (requiring root previlege)."
	exit
fi

#----------check git and perl---------------
PERL_PATH=`which perl`
if [ ! -x ${PERL_PATH} ]; then
	echo "Error: missing perl command; Please install perl."
	exit
fi

#---------- download gnuplot ----------------
GNUPLOT_URL="https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.0.6/gnuplot-5.0.6.tar.gz"
GNUPLOT_SRC_DIR=$rootDir/gnuplot-5.0.6
GNUPLOT_DIR=$rootDir/gnuplot-5.0.6-install

GNUPLOT_EXE_PATH=`which gnuplot`
if [ ! -x "$GNUPLOT_EXE_PATH" ]; then
	if [ ! -d "$GNUPLOT_DIR" ]; then
		# download gnuplot source
		curl -L $GNUPLOT_URL | tar zxf -
		if [ ! -d "$GNUPLOT_SRC_DIR" ] ; then
			echo "FATAL: cannot download and extract gnuplot source."
			exit
		fi

		# compile gnuplot
		cd $GNUPLOT_SRC_DIR
		./configure --prefix=$GNUPLOT_DIR
		make && make install
		cd $rootDir
		echo "export GNUPLOT_HOME=$GNUPLOT_DIR" > $rootDir/env_config.sh
		echo "export PATH=\$PATH:\$GNUPLOT_HOME/bin" >> $rootDir/env_config.sh
	fi

fi

#---------- download libpng if missing ------
LIBPNG_URL=http://www.mcs.anl.gov/~shdi/download/libpng-1.6.37.tar.gz
LIBPNG_SRC_DIR=$rootDir/libpng
LIBPNG_EXE_PATH=`which libpng-config`

if [ ! -x "$LIBPNG_EXE_PATH" ]; then
        if [ ! -d "$LIBPNG_SRC_DIR" ]; then
                # download libpng source
		mkdir -p $LIBPNG_SRC_DIR
		cd $LIBPNG_SRC_DIR
		curl -L $LIBPNG_URL | tar zxf -
                
                if [ ! -d "$LIBPNG_SRC_DIR" ] ; then
                        echo "FATAL: cannot download and extract libpng source."
                        exit
                fi

                # compile libpng
                cd $LIBPNG_SRC_DIR/libpng-1.6.37
                ./configure --prefix=$LIBPNG_SRC_DIR/libpng-1.6.37-install
                make -j 4
		make install
        fi
fi

#---------- download tif22pnm ---------------
cd $rootDir
TIF22PNM_URL="https://github.com/pts/tif22pnm.git"
TIF22PNM_SRC_DIR=$rootDir/tif22pnm

TIF22PNM_EXE_PATH=`which png22pnm`
if [ ! -x "$TIF22PNG_EXE_PATH" ]; then
	if [ ! -d "$TIF22PNG_SRC_DIR" ]; then
		# download tif22pnm source
		git clone $TIF22PNM_URL
		if [ ! -d "$TIF22PNM_SRC_DIR" ] ; then
			echo "FATAL: cannot download and extract tif22pnm source."
			exit
		fi

		# compile tif22pnm
		cd $TIF22PNM_SRC_DIR
		./configure
		cp $rootDir/zc-patches/do.sh .
		if [ -d $LIBPNG_SRC_DIR/libpng-1.6.37-install ];then
			./do.sh fast $LIBPNG_SRC_DIR/libpng-1.6.37-install
		else
			./do.sh fast
		fi
		cd $rootDir
		echo "export PNG22PNM_HOME=$TIF22PNM_SRC_DIR" >> $rootDir/env_config.sh
		echo "export PATH=\$PATH:\$PNG22PNM_HOME" >> $rootDir/env_config.sh
	fi
fi

#---------- download sam2p --------------------
SAM2P_URL="https://github.com/pts/sam2p.git"
SAM2P_SRC_DIR=$rootDir/sam2p

SAM2P_EXE_PATH=`which sam2p`
if [ ! -x "$SAM2P_EXE_PATH" ]; then
	if [ ! -d "$SAM2P_SRC_DIR" ]; then
		# download sam2p source
		git clone $SAM2P_URL
		if [ ! -d "$SAM2P_SRC_DIR" ] ; then
			echo "FATAL: cannot download and extract sam2p source."
			exit
		fi

		# compile sam2p
		cd $SAM2P_SRC_DIR
		#fix a potential bug (line:600)
		cp $rootDir/zc-patches/gensio.cpp .
		#compilation
		./compile.sh
		cd $rootDir
		echo "export SAM2P_HOME=$SAM2P_SRC_DIR" >> $rootDir/env_config.sh
		echo "export PATH=\$PATH:\$SAM2P_HOME" >> $rootDir/env_config.sh
	fi

fi


#----------- download MGARD and libpressio and install -------
cd $rootDir
./libpressio_install.sh

#--------- compile the codes in zc-patch ------------
cd $rootDir/zc-patches
gcc -O3 -o queryVarList queryVarList.c 

#---------- download Z-checker --------------
cd $rootDir
git clone https://github.com/CODARcode/Z-checker.git
cd Z-checker
if [ -n $LibpressioOptPrefixDir ]
then
	./configure --enable-libpressioopt --with-libpressioopt-prefix=$LibpressioOptPrefixDir --prefix=$rootDir/Z-checker/zc-install
else
	./configure --prefix=$rootDir/Z-checker/zc-install
fi
make
make install
export PATH=$rootDir/Z-checker/zc-install/bin:$PATH
cp ../zc-patches/generateReport.sh ./examples/

cd $rootDir/zc-patches
gcc -g -O3 -o manageCompressor manageCompressor.c -fPIC -I../Z-checker/zc-install/include -L../Z-checker/zc-install/lib -lzc -lm -Wl,-rpath $rootDir/Z-checker/zc-install/lib -I$(LibpressioOptPrefixDir)/include/libpressio -L$(LibpressioOptPrefixDir)/lib64 -llibpressio -Wl,-rpath,"$(LibpressioOptPrefixDir)/lib64"
mv manageCompressor ..

#---------- download ZFP and set the configuration -----------
cd $rootDir

#git clone https://github.com/LLNL/zfp.git
#cd zfp
#make
#mkdir -p build
#cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/zfp/zfp-install -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=lib
#make -j$(nproc)
#make install
#cd ../..

cp zfp-patches/zfp-zc.c zfp/utils
cp zfp-patches/zfp-zc-vis.c zfp/utils
#cp zfp-patches/*.sh zfp/utils

cd zfp/utils/
#patch -p0 < ../../zfp-patches/Makefile-zc.patch
cp ../../zfp-patches/Makefile-zc ./Makefile

#cp ../../zc-patches/zc.config .
#modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR

make

#---------- download SZ and set the configuration -----------
cd $rootDir
#git clone https://github.com/disheng222/SZ

#cd SZ/sz/src
#patch -p1 < ../../../sz-patches/sz-src-hacc.patch

#cd ../..
#./configure --prefix=$rootDir/SZ/sz-install
#mkdir -p build
#cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/SZ/sz-install -DCMAKE_INSTALL_LIBDIR=lib
#make -j $(nproc)
#make install
#cd ../zlib
#make
#make install
#cd ../zstd
#make
#make install

cd SZ/example
cp ../../sz-patches/testfloat_CompDecomp.c .
cp ../../sz-patches/testfloat_CompDecomp_libpressio.c .
cp ../../sz-patches/testdouble_CompDecomp.c .
cp ../../sz-patches/testdouble_CompDecomp_libpressio.c .
cp ../../sz-patches/sz-zc-vis.c .
cp ../../sz-patches/Makefile.bk .
#cp ../../sz-patches/sz-zc-ratedistortion.sh .
cp ../../sz-patches/testfloat_CompDecomp.sh .
cp ../../sz-patches/testdouble_CompDecomp.sh .


#---go back to SZ and compile testxxxxx_CompDecopm_libpressio.c
cd $rootDir
cd SZ/example
make -f Makefile.bk
cp ../../zc-patches/zc.config .
modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR

#---------- download MGARD and set the configuration ------------
cd $rootDir/mgard-patches
./compile-mgard-zchecker.sh
if [ -f ../libpressio/test/mgardfloat_CompDecomp ]
then
	cp ../libpressio/test/mgardfloat_CompDecomp ../MGARD/build/bin
	cp ../libpressio/test/mgarddouble_CompDecomp ../MGARD/build/bin
fi
cd ..

#---------- download bit_grooming and set the configuration -----------
cd $rootDir
cd BitGroomingZ/examples
cp ../../bg-patches/Makefile-bg .
cp ../../bg-patches/bgfloat_CompDecomp.cpp .
cp ../../bg-patches/bgdouble_CompDecomp.cpp .
cp ../../bg-patches/bg_CompDecomp.sh .
make -f Makefile-bg
cp ../../zc-patches/zc.config .
modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR
cd $rootDir
./manageCompressor -a bg -c manageCompressor-bg.cfg
Z-checker/examples/modifyZCConfig errBounds.cfg bitgrooming_ERR_BOUNDS "\"1 2 3 4 5\""

#---------- download digit_rounding and set the configuration -----------
cd $rootDir
cd digitroundingZ/examples
cp ../../dr-patches/Makefile-dr .
cp ../../dr-patches/drfloat_CompDecomp.cpp .
cp ../../dr-patches/drdouble_CompDecomp.cpp .
cp ../../dr-patches/dr_CompDecomp.sh .
make -f Makefile-dr
cp ../../zc-patches/zc.config .
modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR
cd $rootDir
./manageCompressor -a digitrounding -c manageCompressor-dr.cfg
Z-checker/examples/modifyZCConfig errBounds.cfg digitrounding_ERR_BOUNDS "\"3 4 5 6 7\""

#---------- download FPZIP and set the configuration -----------
cd $rootDir
cd fpzip/tests
cp ../../fpzip-patches/Makefile-zc .
cp ../../fpzip-patches/fpzipfloat_CompDecomp.c .
cp ../../fpzip-patches/fpzipdouble_CompDecomp.c .
cp ../../fpzip-patches/fpzip_CompDecomp.sh .
make -f Makefile-zc
cp ../../zc-patches/zc.config .
modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR
cd $rootDir
./manageCompressor -a fpzip -c manageCompressor-fpzip-fd.cfg
Z-checker/examples/modifyZCConfig errBounds.cfg fpzip_ERR_BOUNDS "\"8 10 12 14 18 22\""

#----------- download latexmk --------------------------------
cd $rootDir
latexmk_url=http://ctan.math.utah.edu/ctan/tex-archive/support/latexmk.zip
latexmk_dir=latexmk
latexmk_exe_path=`which latexmk`
if [ ! -x "$latexmk_exe_path" ]; then
	if [ ! -d "$latexmk_dir" ]; then
		curl -O $latexmk_url
		unzip latexmk.zip
		cd $latexmk_dir
		ln -s "$rootDir/$latexmk_dir/latexmk.pl" latexmk
		echo "export LATEXMK_HOME=$rootDir/$latexmk_dir" >> $rootDir/env_config.sh
		echo "export PATH=\$PATH:\$LATEXMK_HOME" >> $rootDir/env_config.sh
		cd $rootDir
		rm -rf latexmk.zip
	fi
fi

#----------- download ghost view (gsview) if necessary-----------
cd $rootDir
ghost_url="https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs921/ghostpdl-9.21.tar.gz"
ghost_src_dir=$rootDir/ghostpdl-9.21
ghost_dir=$rootDir/ghostpdl-9.21-install
PS2PDF_EXE_PATH=`which ps2pdf`
if [ ! -x "$PS2PDF_EXE_PATH" ]; then
        if [ ! -d "$ghost_dir" ]; then
                # download ghost source
                curl -L $ghost_url | tar zxf -
                if [ ! -d "$ghost_src_dir" ] ; then
                        echo "FATAL: cannot download and extract ghost source."
                        exit
                fi

                # compile ghost
                cd $ghost_src_dir
                ./configure --prefix=$ghost_dir
                make && make install
                cd $rootDir
		echo "export GHOST_HOME=$ghost_dir" >> $rootDir/env_config.sh
		echo "export PATH=\$PATH:\$GHOST_HOME/bin" >> $rootDir/env_config.sh
        fi

fi

cd $rootDir
ln -s $rootDir/zc-patches/zc.config zc.config 
