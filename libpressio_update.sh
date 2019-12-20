#!/usr/bin/env bash

if ! which cmake &> /dev/null
then
  echo "cmake must be installed"
  exit 1
fi

rootDir=`pwd`

#curl -L https://github.com/CODARcode/MGARD/archive/0.0.0.2.tar.gz | tar zxf -
#mv MGARD-0.0.0.2 MGARD
cd MGARD
git checkout 8a1e16949d8ceee881d16e245ea262bd2d924609
cd -

mkdir -p SZ/build
pushd SZ/build
git pull
make -j
make install
popd

mkdir -p zfp/build
pushd zfp/build
git pull
make -j
make install
popd

mkdir -p MGARD/build
pushd MGARD/build
git pull
make -j
make install
popd

LIBPRESSIO_CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$rootDir/compressor-install -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=lib"
mkdir -p libpressio/build
pushd libpressio/build
git pull
make -j
make install
popd
