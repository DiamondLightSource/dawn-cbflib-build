#!/bin/bash
set -e -x

source releng/prepare_source.sh

MTIME_M4=$(stat -f %m m4/Makefile.m4)
MTIME_MF=$(stat -f %m Makefile_OSX)
while [ $MTIME_M4 -le $MTIME_MF ]; do
  sleep 1
  touch m4/Makefile.m4 # seems that macOS's timestamping is too coarse
  MTIME_M4=$(stat -f %m m4/Makefile.m4)
done

brew install coreutils # for readlink and realpath
brew install openjdk@11

if [ -z "$HOMEBREW_PREFIX" ]; then
    HOMEBREW_PREFIX=$(realpath $(dirname $(which brew))/..)
fi
export JDKDIR=$HOMEBREW_PREFIX/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home

PLAT_OS=macos
LIBEXT=dylib
CBF_MAKEFILE=Makefile_OSX
export MACOSX_DEPLOYMENT_TARGET=10.9 # minimum macOS version Mavericks for XCode 12.1+

CBF_DYLIB=libcbf.$LIBEXT
CBF_DYLIB_WRAP=libcbf_wrap.$LIBEXT

B_ARCH=$(uname -m) # build architecture
if [ $B_ARCH == "x86_64" ]; then
    X_ARCH=arm64 # cross architecture
else
    X_ARCH=x86_64
fi

ARCH=$B_ARCH
export CBF_CC="clang -arch $ARCH"
export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"


source releng/build_java_bindings.sh
RPATH_OLD=$(realpath -L solib/$CBF_DYLIB)
RPATH_NEW="@loader_path/$CBF_DYLIB"
install_name_tool -id $CBF_DYLIB $DEST/$CBF_DYLIB
install_name_tool -id $CBF_DYLIB_WRAP $DEST/$CBF_DYLIB_WRAP
install_name_tool -change "$RPATH_OLD" "$RPATH_NEW" $DEST/$CBF_DYLIB_WRAP
otool -L $DEST/$CBF_DYLIB $DEST/$CBF_DYLIB_WRAP
B_DEST=$DEST

# Repeat for other arch (just build wrapper)
ARCH=$X_ARCH
export CBF_CC="clang -arch $ARCH"

DONT_TEST=y
source releng/build_java_bindings.sh
install_name_tool -id $CBF_DYLIB $DEST/$CBF_DYLIB
install_name_tool -id $CBF_DYLIB_WRAP $DEST/$CBF_DYLIB_WRAP
install_name_tool -change "$RPATH_OLD" "$RPATH_NEW" $DEST/$CBF_DYLIB_WRAP
otool -L $DEST/$CBF_DYLIB $DEST/$CBF_DYLIB_WRAP

# Create universal2 versions
UNI_DEST=dist/$VERSION/$PLAT_OS/universal2
mkdir -p $UNI_DEST
for l in $DEST/*.$LIBEXT; do
    dlib=$(basename $l)
    lipo -create $l $B_DEST/$dlib -output $UNI_DEST/$dlib
done
otool -L $UNI_DEST/$CBF_DYLIB $UNI_DEST/$CBF_DYLIB_WRAP

