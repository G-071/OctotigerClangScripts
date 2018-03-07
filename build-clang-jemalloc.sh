#!/bin/bash
set -e
set -x
if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
fi
cd $BUILD_ROOT
wget https://github.com/jemalloc/jemalloc/releases/download/$JEMALLOC_VER/jemalloc-$JEMALLOC_VER.tar.bz2
tar -xjf jemalloc-$JEMALLOC_VER.tar.bz2
cd jemalloc-$JEMALLOC_VER
./autogen.sh
./configure --prefix=$INSTALL_ROOT/jemalloc/$JEMALLOC_VER
make -j8 -k install
