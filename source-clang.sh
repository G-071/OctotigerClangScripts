export CLANG_ROOT=$BUILD_ROOT/clang6
export CC=$CLANG_ROOT/bin/clang
export CXX=$CLANG_ROOT/bin/clang++
export CPP=$CLANG_ROOT/bin/clang-cpp
#
export PATH=$CLANG_ROOT/bin:$PATH
export LD_LIBRARY_PATH=$CLANG_ROOT/lib:$LD_LIBRARY_PATH
#
export CFLAGS=-fPIC
export CXXFLAGS="-fPIC -march=native -mtune=native -ffast-math -std=c++14 -stdlib=libc++ -I$CLANG_ROOT/include/c++/v1"
export LDFLAGS="-L$CLANG_ROOT/lib -rpath $CLANG_ROOT/lib"
export LDCXXFLAGS="$LDFLAGS -std=c++14 -stdlib=libc++"
