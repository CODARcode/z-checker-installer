#!/bin/bash

rootDir=`pwd`
export PATH=$rootDir/Z-checker/zc-install/bin:$PATH

#---------- download libpng if missing ------
LIBPNG_URL=http://www.mcs.anl.gov/~shdi/download/libpng-1.6.37.tar.gz
LIBPNG_SRC_DIR=$rootDir/libpng
LIBPNG_EXE_PATH=$(command -v libpng-config)

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
TIF22PNM_URL="https://github.com/pts/tif22pnm.git"
TIF22PNM_SRC_DIR=$rootDir/tif22pnm

TIF22PNM_EXE_PATH=$(command -v png22pnm)
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

		png22pnm_var=`cat $rootDir/env_config.sh | grep PNG22PNM_HOME`
		if [[ $png22pnm_var == "" ]]; then
			echo "export PNG22PNM_HOME=$TIF22PNM_SRC_DIR" >> $rootDir/env_config.sh
                	echo "export PATH=\$PATH:\$PNG22PNM_HOME" >> $rootDir/env_config.sh
		fi
	fi
fi

#---------- download sam2p --------------------
SAM2P_URL="https://github.com/pts/sam2p.git"
SAM2P_SRC_DIR=$rootDir/sam2p

SAM2P_EXE_PATH=$(command -v sam2p)
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
		# fix a potential bug in sam2p
		cp $rootDir/zc-patches/gensio.cpp .
		# compilation
                ./compile.sh
                cd $rootDir
                echo "export SAM2P_HOME=$SAM2P_SRC_DIR" >> $rootDir/env_config.sh
                echo "export PATH=\$PATH:\$SAM2P_HOME" >> $rootDir/env_config.sh
        fi

fi

if [ ! -d Z-checker ]; then
	echo "Error: no Z-checker directory."
	echo "Please use z-checker-installer.sh to perform the installation first."
	exit
fi

#----------- download MGARD and libpressio and install -------
cd $rootDir
./libpressio_update.sh

#---------- download Z-checker --------------
cd $rootDir

#backup zc.config
cp Z-checker/examples/zc.config ./zc.config.bk

#pull Z-checker
cd Z-checker
cd examples
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ../zc

git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ../template

git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ..

./configure --prefix=$rootDir/Z-checker/zc-install
make clean
make -j 4
make install
export PATH=$rootDir/Z-checker/zc-install/bin:$PATH
cp ../zc-patches/generateReport.sh ./examples/

cd examples
make clean
make

#--------- compile codes in zc-patches-------
cd $rootDir/zc-patches
gcc -O3 -o queryVarList queryVarList.c
gcc -g -O3 -o manageCompressor manageCompressor.c -I../Z-checker/zc-install/include -L../Z-checker/zc-install/lib -lzc -lm -Wl,-rpath $rootDir/Z-checker/zc-install/lib
mv manageCompressor ..

#---------- download ZFP and set the configuration -----------
cd $rootDir

cp zfp-patches/zfp-zc.c zfp/utils
cp zfp-patches/zfp-zc-vis.c zfp/utils
cp zfp-patches/Makefile-zc zfp/utils/Makefile
#cp zfp-patches/*.sh zfp/utils

cd zfp/utils

#cp ../../zc-patches/zc.config .
#modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR

make clean
make
cd ..

#---------- download SZ and set the configuration -----------
cd $rootDir/SZ/example
cp ../../sz-patches/testfloat_CompDecomp.c .
cp ../../sz-patches/testfloat_CompDecomp_libpressio.c .
cp ../../sz-patches/testdouble_CompDecomp.c .
cp ../../sz-patches/testdouble_CompDecomp_libpressio.c .
cp ../../sz-patches/sz-zc-vis.c .
cp ../../sz-patches/Makefile.bk .
cp ../../sz-patches/testfloat_CompDecomp.sh .
cp ../../sz-patches/testdouble_CompDecomp.sh .

#-----Go back to SZ and compile testxxxx_CompDecopm_libpressio.c
make clean -f Makefile.bk
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

#---------- download SZauto and set the configuration -----------
cd $rootDir
cd SZauto/test
cp ../../SZauto-patches/Makefile-SZauto .
cp ../../SZauto-patches/SZautofloat_CompDecomp.cpp .
cp ../../SZauto-patches/SZautodouble_CompDecomp.cpp .
cp ../../SZauto-patches/SZauto_CompDecomp.sh .
chmod +x SZauto_CompDecomp.sh
make -f Makefile-SZauto
cp ../../zc-patches/zc.config .
modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR
cd $rootDir
./manageCompressor -a SZauto -i 3 -c manageCompressor-SZauto.cfg
Z-checker/examples/modifyZCConfig errBounds.cfg sz_auto_ERR_BOUNDS "\"0.5 0.1 0.01 0.001\""

cd $rootDir
#cp zc.config.bk Z-checker/examples/zc.config
if [ ! -f zc.config ]
then
	ln -s $rootDir/zc-patches/zc.config zc.config
fi
