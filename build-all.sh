#!/bin/bash
set -e
set -x
source source-me.sh
./build-clang.sh
source source-clang.sh
./build-clang-jemalloc.sh
./build-clang-hwlock.sh
./build-clang-boost.sh
./build-clang-vc.sh
./build-clang-hpx.sh
./build-clang-octotiger.sh
