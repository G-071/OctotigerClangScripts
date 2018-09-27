#!/bin/bash
set -e
set -x

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
    . source-clang.sh
fi

cd "$BUILD_ROOT"
mkdir -p src
cd src
if [ ! -d octotiger ] ; then
    git clone https://github.com/STEllAR-GROUP/octotiger.git
    cd octotiger
    git checkout aa832788dd0c57eee3a750d8969a82332f1d6354
    cd ..
fi
cd octotiger
cd ../..

mkdir -p build/octotiger
echo $(pwd)
cd build/octotiger
echo $(pwd)

cmake \
-DCMAKE_PREFIX_PATH=${BUILD_ROOT}/build/hpx \
-DCMAKE_CXX_COMPILER=$CXX \
-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
-DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS $CUDAFLAGS" \
-DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS $CUDAFLAGS" \
-DBOOST_ROOT=$INSTALL_ROOT/boost/$BOOST_VER \
-DBoost_COMPILER=-clang70 \
-DOCTOTIGER_WITH_CUDA=${OCT_WITH_CUDA} \
-DCMAKE_BUILD_TYPE=${buildtype} \
-DOCTOTIGER_WITH_SILO=OFF \
 ../../src/octotiger

make -j${PARALLEL_BUILD} VERBOSE=1
