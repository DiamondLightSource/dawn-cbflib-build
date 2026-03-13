#!/bin/bash
set -e -x

# docker run --rm -v $PWD:/io:Z quay.io/pypa/manylinux_2_28_x86_64:latest /bin/bash /io/releng/build_manylinux_binding.sh
# bash build_manylinux_binding.sh

# install jdk
dnf install -y java-11-openjdk-devel

cd /io

source releng/prepare_source.sh

export JDKDIR=$(readlink -f /etc/alternatives/java_sdk_openjdk)

PLAT_OS=linux
LIBEXT=so
CBF_MAKEFILE=Makefile

source releng/build_java_bindings.sh

# set RPATH to something sensible so linker can find main library from wrapper
patchelf --set-rpath '$ORIGIN' $DEST/libcbf_wrap.so

