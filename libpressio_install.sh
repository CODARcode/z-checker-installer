#!/usr/bin/env bash

if ! which cmake &> /dev/null
then
  echo "cmake must be installed"
  exit 1
fi

rootDir=`pwd`

#curl -L https://github.com/CODARcode/MGARD/archive/0.0.0.2.tar.gz | tar zxf -
#mv MGARD-0.0.0.2 MGARD
git clone https://github.com/CODARcode/MGARD
cd MGARD
git checkout 8a1e16949d8ceee881d16e245ea262bd2d924609
cd -

git clone https://github.com/CODARcode/libpressio

mkdir -p MGARD/build
pushd MGARD/build
cmake .. -DCMAKE_INSTALL_PREFIX=$rootDir/MGARD/MGARD-install -DCMAKE_INSTALL_LIBDIR=lib
make -j$(nproc)
make install
popd

mkdir -p libpressio/install
pushd libpressio/install
ln -s $rootDir/SZ/sz-install sz-install
ln -s $rootDir/zfp/zfp-install zfp-install
ln -s $rootDir/MGARD/MGARD-install MGARD-install
popd

LIBPRESSIO_CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$rootDir/libpressio/install -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=lib"
mkdir -p libpressio/build
pushd libpressio/build
cmake .. $LIBPRESSIO_CMAKE_ARGS -DLIBPRESSIO_HAS_MGARD=ON -DLIBPRESSIO_HAS_HDF=OFF -DLIBPRESSIO_HAS_MAGICK=OFF
make -j$(nproc)
make install
cp liblibpressio* ../install/lib
popd
