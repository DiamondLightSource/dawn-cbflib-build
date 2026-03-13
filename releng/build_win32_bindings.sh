#!/bin/bash
set -e -x

pacman -S --noconfirm --needed git patch

source releng/prepare_source.sh

if [ -z "$BASE_DIR" ]; then
    export BASE_DIR=$HOME
fi
if [ -z "$DEST_DIR" ]; then
    export DEST_DIR="$PWD/dist"
fi

export MSYS=winsymlinks:native # to unpack zstd tarball

CBF_MAKEFILE=Makefile_MINGW
LIBEXT=dll

export PLAT_OS=win32

if [ -n "$JAVA_HOME_21_X64" ]; then
  JDKDIR=`echo $JAVA_HOME_21_X64 | sed -e 's,C:,/c,' | tr \\\\ /` # make a Unix path
elif [ -n "$JAVA_HOME" ]; then
  JDKDIR="$JAVA_HOME"
elif [ -z "$JDKDIR" ]; then
  echo "Must define JDKDIR or override it with JAVA_HOME_21_X64 or JAVA_HOME"
  exit 1
fi
ARCH=x86_64
export JDKDIR ARCH

export MY_MINGW_ENV_DIR=/ucrt64

pacman -S --noconfirm --needed make m4 diffutils swig mingw-w64-x86_64-cmake mingw-w64-ucrt-x86_64-gcc

export PATH="${MY_MINGW_ENV_DIR}/bin":"${JDKDIR}/bin":"$PATH" # add universal C runtime compilers

case $ARCH in
  aarch64)
    export GLOBAL_CFLAGS="-fPIC -O3"
    ;;
  x86_64|*)
    export GLOBAL_CFLAGS="-fPIC -O3 -m64"
    ;;
esac

source releng/build_java_bindings.sh

