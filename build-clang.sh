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
    git checkout release_60
    cd ..
fi
if [ ! -d clang ] ; then
    git clone https://llvm.org/git/clang.git
    cd clang
    git checkout release_60
    cd ..
fi
if [ ! -d libcxx ] ; then
    git clone https://llvm.org/git/libcxx.git
    cd libcxx
    git checkout release_60
    cd ..
fi
if [ ! -d libcxxabi ] ; then
    git clone https://llvm.org/git/libcxxabi.git
    cd libcxxabi
    git checkout release_60
    cd ..
fi

cd llvm
mkdir llvm-build && cd llvm-build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$CLANG_ROOT -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" ../llvm
make -j${PARALLEL_BUILD} install

cd $BUILD_ROOT
