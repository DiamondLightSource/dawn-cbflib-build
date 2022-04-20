#!/bin/bash
set -e -x

export JDKDIR=$JAVA_HOME_11_X64

ARCH=x86_64

make Makefiles
make distclean
export MACOSX_DEPLOYMENT_TARGET=10.8
make -f Makefile_OSX javawrapper javatests CBFLIB_DONT_BUILD_HDF5=yes CBF_NO_REGEX=yes CBFLIB_DONT_USE_LOCAL_REGEX=yes CBFLIB_DONT_USE_PYCIFRW=yes CBFLIB_DONT_USE_PY2CIFRW=yes CBFLIB_DONT_USE_PY3CIFRW=yes NOFORTRAN=yes CC="clang -arch $ARCH"

JARFILE="jcbf/cbflib-*.jar"
VERSION=`basename $JARFILE | sed -e 's/cbflib-\(.*\)\.jar/\1/g'`

DEST=dist/$VERSION/macos/$ARCH
mkdir -p $DEST
cp $JARFILE $DEST
cp solib/libcbf*.dylib $DEST
mv solib solib-$ARCH
X86_DEST=$DEST

# Repeat for -arch arm64 (just build wrapper)
ARCH=arm64
export MACOSX_DEPLOYMENT_TARGET=11.0
make -f Makefile_OSX javawrapper CBFLIB_DONT_BUILD_HDF5=yes CBF_NO_REGEX=yes CBFLIB_DONT_USE_LOCAL_REGEX=yes CBFLIB_DONT_USE_PYCIFRW=yes CBFLIB_DONT_USE_PY2CIFRW=yes CBFLIB_DONT_USE_PY3CIFRW=yes NOFORTRAN=yes CC="clang -arch $ARCH"

DEST=dist/$VERSION/macos/$ARCH
mkdir -p $DEST
cp $JARFILE $DEST
cp solib/libcbf*.dylib $DEST
mv solib solib-$ARCH

# Create universal2 versions
UNI_DEST=dist/$VERSION/macos/universal2
mkdir -p $UNI_DEST
for l in $DEST/*.dylib; do
    dlib=$(basename $l)
    lipo -create $l $X86_DEST/$dlib -output $UNI_DEST/$dlib
done

