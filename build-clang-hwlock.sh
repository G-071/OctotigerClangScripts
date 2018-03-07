#!/bin/bash
. ./source-me.sh
cd $BUILD_ROOT
wget --no-check-certificate https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-$HWLOC_VER.tar.gz
tar -xzf hwloc-$HWLOC_VER.tar.gz
cd hwloc-$HWLOC_VER
./configure --prefix=$INSTALL_ROOT/hwloc/$HWLOC_VER
make -j8 install
