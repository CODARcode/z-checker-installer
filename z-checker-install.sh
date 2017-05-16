#!/bin/bash

rootDir=`pwd`

#---------- download gnuplot ----------------
GNUPLOT_URL="https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.0.6/gnuplot-5.0.6.tar.gz"
#GNUPLOT_SRC_DIR=$rootDir/gnuplot-5.0.6
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

		echo "export PATH=$GNUPLOT_DIR/bin:\$PATH" > env_config.sh
	fi

fi

#---------- download Z-checker --------------
cd $rootDir
git clone https://github.com/CODARcode/Z-checker.git
cd Z-checker
./configure --prefix=$rootDir/Z-checker/zc-install
make
make install
cp ../zc-patches/generateReport.sh ./examples/

#---------- download ZFP and set the configuration -----------
cd $rootDir

git clone https://github.com/LLNL/zfp.git
cd zfp
make

cd -
cp zfp-patches/zfp-zc.c zfp/utils
cp zfp-patches/*.sh zfp/utils

cd zfp/utils/
patch -p0 < ../../zfp-patches/Makefile-zc.patch
make

#---------- download SZ and set the configuration -----------
cd $rootDir
git clone https://github.com/disheng222/SZ

cd SZ/sz/src
patch -p1 < ../../../sz-patches/sz-src-hacc.patch

cd ../..
./configure --prefix=$rootDir/SZ/sz-install
make
make install

cd example
patch -p0 < ../../sz-patches/Makefile-zc.bk.patch
make -f Makefile.bk
cp ../../Z-checker/examples/zc.config .
patch -p0 < ../../zc-patches/zc-probe.config.patch

cp ../../sz-patches/sz-zc-ratedistortion.sh .
cp ../../sz-patches/testfloat_CompDecomp.sh .

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
		echo "export PATH=\$PATH:$rootDir/$latexmk_dir" >> env_config.sh
	fi
fi

if [ -f env_config.sh ]; then
	echo "export PATH=\$PATH:\$GNUPLOT_HOME/bin:\$LATEXMK_HOME/bin" >> env_config.sh
	mv env_config.sh Z-checker/examples/env_config.sh
fi

