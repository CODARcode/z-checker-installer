#!/bin/bash

rootDir=`pwd`

NODE_URL=https://nodejs.org/dist/v6.10.2/node-v6.10.2.tar.gz
NODE_SRC_DIR=$rootDir/node-v6.10.2
NODE_DIR=$rootDir/node-v6.10.2-install

# download and install node.js
cd $rootDir
if [ ! -d "$NODE_DIR" ] ; then
  curl -O $NODE_URL
  tar zxf node-v6.10.2.tar.gz
  cd $NODE_SRC_DIR
  ./configure --prefix=$NODE_DIR
  make
  make install
fi


# download z-checker-web
cd $rootDir
if [ ! -d "$NODE_DIR" ] ; then
  git clone https://github.com/CODARcode/z-checker-web
fi

export PATH=$NODE_DIR/bin:$PATH
cd z-checker-web
npm install

cd $rootDir
