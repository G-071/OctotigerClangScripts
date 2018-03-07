#!/bin/bash
set -e

source source-me.sh

./build-clang-jemalloc.sh
./build-clang-hwloc.sh
./build-clang-boost.sh

./build-clang-vc.sh
./build-clang-hpx.sh
./build-clang-octotiger.sh
