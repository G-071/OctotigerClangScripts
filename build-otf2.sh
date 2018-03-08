#!/bin/bash
. ./source-me.sh
. source-clang.sh
cd $BUILD_ROOT
wget http://www.vi-hps.org/upload/packages/otf2/otf2-2.0.tar.gz
tar -xzf otf2-2.0.tar.gz
cd "otf2-2.0"
./configure --prefix=$INSTALL_ROOT/otf2/$OTF2_VER CC=$CC CXX=$CXX --enable-shared
make clean
make -j8 -k install
