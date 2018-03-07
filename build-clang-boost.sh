#!/bin/bash
. ./source-me.sh
cd $BUILD_ROOT
if [ ! -f boost_$BOOST_SUFFIX.tar.gz ] ; then
    wget http://vorboss.dl.sourceforge.net/project/boost/boost/$BOOST_VER/boost_$BOOST_SUFFIX.tar.gz
fi
tar -xzf boost_$BOOST_SUFFIX.tar.gz
cd boost_$BOOST_SUFFIX
./bootstrap.sh toolset=clang
./b2 toolset=clang cxxflags="$CXXFLAGS -D_LIBCPP_ENABLE_CXX17_REMOVED_AUTO_PTR" linkflags="$LDCXXFLAGS" threading=multi link=shared variant=release address-model=64 --without-mpi --without-python --without-graph --without-graph_parallel --prefix=$BOOST_ROOT  -j${PARALLEL_BUILD} install
