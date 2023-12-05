#!/bin/bash
set -e -x

# docker run --rm -v $PWD:/io:Z ghcr.io/diamondlightsource/manylinux-dls-2014_x86_64:latest /bin/bash /io/releng/build_manylinux_binding.sh
# bash build_manylinux_binding.sh

cd /io

source releng/prepare_source.sh

export JDKDIR=$(readlink -f /etc/alternatives/java_sdk_openjdk)

PLAT_OS=linux
LIBEXT=so
CBF_MAKEFILE=Makefile

source releng/build_java_bindings.sh

# set RPATH to something sensible so linker can find main library from wrapper
patchelf --set-rpath '$ORIGIN' $DEST/libcbf_wrap.so

if [ $ARCH == 'x86_64' ]; then
    DONT_TEST=y
    source releng/build_mingw64_cross_compiler.sh
fi

