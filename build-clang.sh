#!/bin/bash
set -e
set -x

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
fi

cd "$BUILD_ROOT"
mkdir -p src/llvm-project
cd src/llvm-project
if [ ! -d llvm ] ; then
    git clone https://llvm.org/git/llvm.git
    cd llvm
#    git checkout release_60
    git checkout d42d9e83aeb0e752cec99b1a1f2b17a9246bff27
    cd ..
fi
if [ ! -d clang ] ; then
    git clone https://llvm.org/git/clang.git
    cd clang
#    git checkout release_60
    git checkout 23b713ddc4e7f70cd6e96ea93eab3f06ca3a72d7
    cd ..
fi
if [ ! -d libcxx ] ; then
    git clone https://llvm.org/git/libcxx.git
    cd libcxx
#    git checkout release_60
    git checkout 0b261846c90cdcfa6e584a5048665a999900618f
    cd ..
fi
if [ ! -d libcxxabi ] ; then
    git clone https://llvm.org/git/libcxxabi.git
    cd libcxxabi
#    git checkout release_60
    git checkout 565ba0415b6b17bbca46820a0fcfe4b6ab5abce2
    cd ..
fi

cd llvm
mkdir -p llvm-build && cd llvm-build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$BUILD_ROOT/clang6 -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" ..
make -j${PARALLEL_BUILD} install

cd $BUILD_ROOT
