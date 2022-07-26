#!/bin/bash
set -e -x

rm -rf solib-native
mv solib solib-native

# Set up cross-compiler environment
eval `rpm --eval %{mingw64_env}`

export JDKDIR=/opt/jdk-11-win32

CBF_MAKEFILE=Makefile_MINGW_CROSS
PLAT_OS=win32
LIBEXT=dll

source releng/build_java_bindings.sh

