#!/bin/bash
. ./source-me.sh
echo $BUILD_ROOT $INSTALL_ROOT $PAPI_VER
cd "$BUILD_ROOT"
wget http://icl.utk.edu/projects/papi/downloads/papi-${PAPI_VER}.tar.gz
tar -xzf papi-${PAPI_VER}.tar.gz
cd papi-${PAPI_VER}/src
./configure --prefix=$INSTALL_ROOT/papi/$PAPI_VER --enable-shared
make -j 8 install
