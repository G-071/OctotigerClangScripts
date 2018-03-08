#!/bin/bash
set -e
set -x
./build-clang.sh

source source-me.sh

./build-clang-jemalloc.sh
./build-clang-hwlock.sh
./build-clang-boost.sh

./build-clang-vc.sh
./build-clang-hpx.sh
./build-clang-octotiger.sh
