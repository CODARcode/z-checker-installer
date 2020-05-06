#!/usr/bin/env bash

if ! which cmake &> /dev/null
then
  echo "cmake must be installed"
  exit 1
fi

rootDir=`pwd`

curl -L https://github.com/CODARcode/MGARD/archive/0.0.0.2.tar.gz | tar zxf -
mv MGARD-0.0.0.2 MGARD
#git clone https://github.com/CODARcode/MGARD
#cd MGARD
#git checkout 8a1e16949d8ceee881d16e245ea262bd2d924609
#cd -

git clone http://github.com/disheng222/SZ
git clone http://github.com/LLNL/zfp
git clone https://github.com/CODARcode/libpressio

mkdir -p SZ/build
pushd SZ/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/SZ/sz-install

mkdir -p zfp/build
pushd zfp/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF
make -j
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/zfp/zfp-install

mkdir -p MGARD/build
pushd MGARD/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DCMAKE_INSTALL_LIBDIR=lib
make -j
make install
popd
ln -s $rootDir/compressor-install/ $rootDir/MGARD/MGARD-install

LIBPRESSIO_CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=lib"
mkdir -p libpressio/build
pushd libpressio/build
#cmake .. $LIBPRESSIO_CMAKE_ARGS -DLIBPRESSIO_HAS_MGARD=ON -DLIBPRESSIO_HAS_SZ=ON -DLIBPRESSIO_HAS_ZFP=ON
cmake .. $LIBPRESSIO_CMAKE_ARGS -DSZ_DIR:PATH=$rootDir/compressor-install/share/SZ/cmake -DLIBPRESSIO_HAS_SZ=ON -DLIBPRESSIO_HAS_ZFP=ON
make -j
make install
popd
