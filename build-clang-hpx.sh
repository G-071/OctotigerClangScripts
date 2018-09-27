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
if [ ! -d hpx ] ; then
    git clone https://github.com/STEllAR-GROUP/hpx.git
    cd hpx
    #git checkout 1.1.0
    #git checkout cuda_clang
    git checkout master
    cd ..
fi
cd hpx
cd ../..

mkdir -p build/hpx
echo $(pwd)
cd build/hpx
echo $(pwd)

cmake \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT/hpx \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_CXX_COMPILER=$CXX \
 -DCMAKE_CXX_FLAGS="$CXXFLAGS" "$CUDAFLAGS" \
 -DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS" \
 -DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS" \
 -DHPX_WITH_CUDA=${OCT_WITH_CUDA} \
 -DHPX_WITH_CXX14=${OCT_WITH_CUDA} \
 -DHPX_WITH_CUDA_CLANG=${OCT_WITH_CUDA} \
 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
 -DHPX_WITH_THREAD_IDLE_RATES=ON \
 -DHPX_WITH_DISABLED_SIGNAL_EXCEPTION_HANDLERS=ON \
 -DHWLOC_ROOT=$INSTALL_ROOT/hwloc/$HWLOC_VER \
 -DHPX_WITH_MALLOC=JEMALLOC \
 -DJEMALLOC_ROOT=$INSTALL_ROOT/jemalloc/$JEMALLOC_VER \
 -DBOOST_ROOT=$BOOST_ROOT \
 -DHPX_WITH_CUDA_ARCH=sm_60 \
 -DHPX_WITH_DATAPAR_VC=ON \
 -DHPX_WITH_DATAPAR_VC_NO_LIBRARY=ON \
 -DVc_DIR=$INSTALL_ROOT/Vc-Release/lib/cmake/Vc \
 -DHPX_WITH_EXAMPLES:BOOL=ON \
 -DCMAKE_BUILD_TYPE=$buildtype \
 -DHPX_WITH_NETWORKING=ON \
 ../../src/hpx

make -j${PARALLEL_BUILD} core components VERBOSE=1
