# 
if [ ! -d cbflib ]; then
  git clone --depth=1 --branch=CBFlib-0.9.7-devel https://github.com/yayahjb/cbflib.git
fi
cd cbflib
if [ ! -L releng ]; then
  ln -s ../releng .
  patch -p1 < releng/make.patch
  patch -p1 < releng/no-hdf5.patch
  patch -p1 < releng/pointer-leak.patch
fi

