# OctotigerClangScripts
Instructions:

To build everything (including clang, jemalloc, hwloc, boost, Vc, hpx and octotiger):

(With cuda)

./build-all.sh Release cuda

(Without cuda)

./build-all.sh Release no-cuda


Known issue:

Sometimes clang has problems with the compilation of jemalloc and complains about a missing mutex header. For some reason this is fixable by either running "./build-clang-jemalloc Release cuda" again, or by switching to an older jemalloc version!
