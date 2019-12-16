#!/bin/bash

rootDir=`pwd`
export PATH=$rootDir/Z-checker/zc-install/bin:$PATH

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
make
make install
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
cd zfp/src

git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd ../utils
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull


cd ../..
cp zfp-patches/zfp-zc.c zfp/utils
cp zfp-patches/zfp-zc-vis.c zfp/utils
cp zfp-patches/Makefile-zc zfp/utils/Makefile
#cp zfp-patches/*.sh zfp/utils

cd zfp
#make
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/zfp/zfp-install -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=lib
make clean
make -j$(nproc)
make install

cd ../utils

cp ../../zc-patches/zc.config .
modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR

make clean
make
cd ..

#---------- download SZ and set the configuration -----------
cd $rootDir
cd SZ
cd sz
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git pull

cd src
#patch -p1 < ../../../sz-patches/sz-src-hacc.patch

cd ../../
rm -rf $rootDir/SZ/sz-install
./configure --prefix=$rootDir/SZ/sz-install
mkdir -p build
cd build
make clean
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/SZ/sz-install -DCMAKE_INSTALL_LIBDIR=lib
make -j $(nproc)
make install
cd ../zlib
make
make install
cd ../zstd
make
make install
cd ..

cd example
cp ../../sz-patches/testfloat_CompDecomp.c .
cp ../../sz-patches/testfloat_CompDecomp_libpressio.c .
cp ../../sz-patches/testdouble_CompDecomp.c .
cp ../../sz-patches/testdouble_CompDecomp_libpressio.c .
cp ../../sz-patches/sz-zc-vis.c .
cp ../../sz-patches/Makefile.bk .
cp ../../sz-patches/testfloat_CompDecomp.sh .
cp ../../sz-patches/testdouble_CompDecomp.sh .

#----------- download MGARD and libpressio and install -------
cd $rootDir
./libpressio_install.sh

#-----Go back to SZ and compile testxxxx_CompDecopm_libpressio.c
cd SZ/example
make clean -f Makefile.bk
make -f Makefile.bk
cp ../../zc-patches/zc.config .
modifyZCConfig ./zc.config checkingStatus PROBE_COMPRESSOR


cd $rootDir
#cp zc.config.bk Z-checker/examples/zc.config
if [ ! -f zc.config ]
then
	ln -s $rootDir/zc-patches/zc.config zc.config
fi
