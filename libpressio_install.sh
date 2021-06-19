#!/usr/bin/env bash

if ! which cmake &> /dev/null
then
  echo "cmake must be installed"
  exit 1
fi

rootDir=`pwd`

#git clone https://github.com/CODARcode/MGARD
#cd MGARD
#git checkout b67a0ac963587f190e106cc3c0b30773a9455f7a
#cd ..

git clone http://github.com/disheng222/SZ
git clone http://github.com/LLNL/zfp
git clone https://github.com/szcompressor/SZauto.git
git clone https://github.com/facebook/zstd
git clone https://github.com/szcompressor/SZ
git clone https://github.com/LLNL/zfp
git clone https://github.com/robertu94/std_compat
git clone https://github.com/CODARcode/libpressio
git clone https://github.com/LLNL/fpzip.git
git clone https://github.com/disheng222/BitGroomingZ.git
git clone https://github.com/disheng222/digitroundingZ.git

export PKG_CONFIG_PATH=$rootDir/compressor-install/lib/pkgconfig/:$PKG_CONFIG_PATH

mkdir -p zstd/builddir
pushd zstd/builddir
cmake ../build/cmake/ -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j 4
make install
popd

mkdir -p SZ/build
pushd SZ/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j 4
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/SZ/sz-install

mkdir -p zfp/build
pushd zfp/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF
make -j 4
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/zfp/zfp-install

# mkdir -p MGARD/build
# pushd MGARD/build
# cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
# make -j 4
# make install
# popd
# ln -s $rootDir/compressor-install/ $rootDir/MGARD/MGARD-install

mkdir -p std_compat/build
pushd std_compat/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF
make -j 4
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/std_compat/

#install fpzip 
#add fpzip through manageCompressor
mkdir -p fpzip/build
pushd fpzip/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j 4
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/fpzip/fpzip-install

#install BitGrooming
mkdir -p BitGroomingZ/build
pushd BitGroomingZ/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j 4
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/BitGroomingZ/BitGroomingZ-install

#install digit rounding
mkdir -p digitroundingZ/build
pushd digitroundingZ/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j 4
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/digitroundingZ/digitroundingZ-install

#install SZauto
mkdir -p SZauto/build
pushd SZauto/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j 4
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/SZauto/SZauto-install


LIBPRESSIO_CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=lib"
mkdir -p libpressio/build
pushd libpressio/build
cmake .. $LIBPRESSIO_CMAKE_ARGS -DSZ_DIR:PATH=$rootDir/compressor-install/share/SZ/cmake -DLIBPRESSIO_HAS_SZ=ON -DLIBPRESSIO_HAS_FPZIP=ON -DLIBPRESSIO_HAS_ZFP=ON -DLIBPRESSIO_HAS_MGARD=OFF -DLIBPRESSIO_HAS_BIT_GROOMING=ON -DLIBPRESSIO_HAS_SZ_AUTO=ON -DLIBPRESSIO_HAS_DIGIT_ROUNDING=ON
make -j 4
make install
popd
