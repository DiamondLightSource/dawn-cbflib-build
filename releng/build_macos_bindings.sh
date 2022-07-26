#!/bin/bash
set -e -x

export JDKDIR=$JAVA_HOME_11_X64

PLAT_OS=macos
LIBEXT=dylib
CBF_MAKEFILE=Makefile_OSX
export MACOSX_DEPLOYMENT_TARGET=10.9 # minimum macOS version Mavericks for XCode 12.1+

CBF_DYLIB=libcbf.$LIBEXT
CBF_DYLIB_WRAP=solib/libcbf_wrap.$LIBEXT

B_ARCH=$(uname -m) # build architecture
if [ $B_ARCH == "x86_64" ]; then
    X_ARCH=arm64 # cross architecture
else
    X_ARCH=x86_64
fi

ARCH=$B_ARCH
export CBF_CC="clang -arch $ARCH"

source releng/build_java_bindings.sh
install_name_tool -change solib/$CBF_DYLIB "@loader_path/$CBF_DYLIB" $CBF_DYLIB_WRAP
mv solib solib-$ARCH
B_DEST=$DEST

# Repeat for other arch (just build wrapper)
ARCH=$X_ARCH
export CBF_CC="clang -arch $ARCH"

DONT_TEST=y
source releng/build_java_bindings.sh
install_name_tool -change solib/$CBF_DYLIB "@loader_path/$CBF_DYLIB" $CBF_DYLIB_WRAP
mv solib solib-$ARCH

# Create universal2 versions
UNI_DEST=dist/$VERSION/$PLAT_OS/universal2
mkdir -p $UNI_DEST
for l in $DEST/*.$LIBEXT; do
    dlib=$(basename $l)
    lipo -create $l $B_DEST/$dlib -output $UNI_DEST/$dlib
done

