#!/bin/bash

# expects CBF_MAKEFILE, PLAT_OS, ARCH, LIBEXT

make Makefiles $CBF_MAKEFILE
make distclean

CBF_CTEST=bin/ctestcbf
if [ -z "$DONT_TEST" ]; then
    CBF_TESTS=javatests
else
    CBF_TESTS=ctestcbf_bin
fi

if [ -n "$CBF_CC" ]; then
    CBF_COMPILE="CC=$CBF_CC"
else
    CBF_COMPILE="DUMMY=no"
fi

make -f $CBF_MAKEFILE $CBF_TESTS javawrapper "$CBF_COMPILE" CBFLIB_DONT_BUILD_HDF5=yes CBF_NO_REGEX=yes CBFLIB_DONT_USE_LOCAL_REGEX=yes CBFLIB_DONT_USE_PYCIFRW=yes CBFLIB_DONT_USE_PY2CIFRW=yes CBFLIB_DONT_USE_PY3CIFRW=yes NOFORTRAN=yes

JARFILE="jcbf/cbflib-*.jar"
VERSION=`basename $JARFILE | sed -e 's/cbflib-\(.*\)\.jar/\1/g'`

DEST=dist/$VERSION/$PLAT_OS/$ARCH
mkdir -p $DEST
cp $JARFILE $DEST
if [ $PLAT_OS == "win32" ]; then
    cp solib/cbf*.$LIBEXT $DEST
else
    cp solib/libcbf*.$LIBEXT $DEST
fi
if [ -f $CBF_CTEST ]; then
    cp $CBF_CTEST bin/changtestcompression bin/testcbf.class $DEST
fi

