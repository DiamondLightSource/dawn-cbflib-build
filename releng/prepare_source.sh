# 
git clone --depth=1 --branch=CBFlib-0.9.7-devel https://github.com/yayahjb/cbflib.git
mv releng cbflib
cd cbflib
patch -p1 < releng/make.patch
patch -p1 < releng/no-hdf5.patch
patch -p1 < releng/pointer-leak.patch

