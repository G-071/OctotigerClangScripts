
# our build directory root for all clang compiled projects in one place
export BUILD_ROOT=$PWD
mkdir -p clang6
#
if [[ `echo $HOST | grep vgpu2` ]]; then
    echo "compiling for vgpu2, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-8.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/Modules/modulefiles/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOST | grep vgpu1` ]]; then
    echo "compiling for vgpu1, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-8.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/Modules/modulefiles/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOST | grep argon-tesla1` ]]; then
    echo "compiling for argon-tesla1, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-8.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "

    export CUDA_VISIBLE_DEVICES=0
elif [[ `echo $HOST | grep argon-tesla2` ]]; then
    echo "compiling for argon-tesla2, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-8.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
    export CUDA_VISIBLE_DEVICES=0
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOST | grep argon-gtx` ]]; then
    echo "compiling for argon-tesla2, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-8.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
    export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOST | grep ipvs8gtx` ]]; then
    echo "compiling for ipvs8gtx, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-8.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/Modules/modulefiles/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOSTNAME | grep bahram` ]]; then
    echo "compiling for rostam, doing additional setup";
    module load gcc/5.4.0
    module load cmake/3.7.2
    module load cuda/8.0.61
    export CUDATOOLKIT_HOME=/opt/modules/cuda/8.0.61
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
elif [[ `echo $HOSTNAME | grep rostam` ]]; then
    echo "compiling for rostam, doing additional setup";
    module load gcc/5.4.0
    module load cmake/3.7.2
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
 -lcudart_static -pthread \
 -lcuda -lcublas"
fi
# -lcudart -ldl -lrt -pthread \

if [[ -z $2 ]]; then
    export CUDATOOLKIT_HOME=""
    export CUDAFLAGS=""
    export OCT_WITH_CUDA=OFF
else
    export OCT_WITH_CUDA=ON
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
if [[ ! -z $2 ]]; then
    if [[ ! ("$2" == "cuda" || "$2" == "no-cuda") ]]; then
    echo "no build cuda type specified: Use either cuda or no-cuda as second argument!"
    kill -INT $$
    fi
if [[ "$2" == "no-cuda" ]]; then
    export CUDATOOLKIT_HOME=""
    export CUDAFLAGS=""
    export OCT_WITH_CUDA=OFF
elif [[ "$2" == "cuda" ]]; then
    export OCT_WITH_CUDA=ON
fi
else
    echo "no build cuda type specified: Use either cuda or no-cuda as second argument!"
    kill -INT $$
    # export buildtype=Release
fi
