
# our build directory root for all clang compiled projects in one place
export BUILD_ROOT=$PWD
mkdir -p clang6
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
#
if [[ `echo $HOST | grep vgpu2` ]]; then
    echo "compiling for vgpu2, doing additional setup";
    module load cuda-8.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/Modules/modulefiles/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOSTNAME | grep bahram` ]]; then
    echo "compiling for rostam, doing additional setup";
    module load cuda/8.0.61
    export CUDATOOLKIT_HOME=/opt/modules/cuda/8.0.61
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOSTNAME | grep rostam` ]]; then
    echo "compiling for rostam, doing additional setup";
    module load cuda/8.0.61
    export CUDATOOLKIT_HOME=/opt/modules/cuda/8.0.61
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
else
    echo "compiling for normal desktop machine, expecting cuda in /usr/local/cuda";
    export CUDATOOLKIT_HOME=/usr/local/cuda
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
fi


# Optional shortcuts for Apex output in HPX
alias APEX_OFF='export APEX_SCREEN_OUTPUT=0;export APEX_PROFILE=0;export APEX_OTF2=0'
alias APEX_ON='export APEX_SCREEN_OUTPUT=1;export APEX_PROFILE=1;export APEX_OTF2=1'

# Versions we will install
mkdir -p build
export INSTALL_ROOT=$BUILD_ROOT/build
export HWLOC_VER=1.11.7
export JEMALLOC_VER=5.0.1
export OTF2_VER=2.0
export BOOST_VER=1.65.0
export BOOST_SUFFIX=1_65_0
export BOOST_ROOT=$INSTALL_ROOT/boost/$BOOST_VER
export PAPI_VER=5.5.1

export PARALLEL_BUILD=$((`lscpu -p=cpu | wc -l`-4))

export octotiger_source_me_sources=1
if [[ ! -z $1 ]]; then
    if [[ ! ("$1" == "Release" || "$1" == "RelWithDebInfo" || "$1" == "Debug") ]]; then
    echo "build type invalid: valid are Release, RelWithDebInfo and Debug"
    kill -INT $$
    fi
    export buildtype=$1
else
    echo "no build type specified: specify either Release, RelWithDebInfo or Debug"
    kill -INT $$
    # export buildtype=Release
fi
echo "build type: $buildtype"
