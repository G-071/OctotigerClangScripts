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
if [ ! -d Vc ] ; then
    # git clone git@github.com:VcDevel/Vc.git
    git clone https://github.com/STEllAR-GROUP/Vc.git
    cd Vc
    git checkout pfandedd_inlining_AVX512
    cd ..
fi
cd Vc
git pull
cd ..
cd ..
mkdir -p build
cd build
mkdir -p Vc
cd Vc
cmake \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT/Vc-Release \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_CXX_COMPILER=$CXX \
 -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
 -DBUILD_EXAMPLES=OFF \
 -DBUILD_TESTING=OFF \
 -DENABLE_MIC=OFF \
 $BUILD_ROOT/src/Vc

make -j${PARALLEL_BUILD}
make install
cd $basedir
