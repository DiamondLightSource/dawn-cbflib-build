# 
CBFLIB_VER=0.9.8
CBFLIB_CHK=81d8ea4b75ba2cab7f94a6b20a32b8ca099405a073201776c64064b64c7a4d30
CBFLIB_DIR=CBFlib-${CBFLIB_VER}
CBFLIB_TGZ=${CBFLIB_DIR}.tar.gz

if [ ! -f ${CBFLIB_TGZ} ]; then
  curl -fsSLO "https://github.com/dials/cbflib/archive/refs/tags/${CBFLIB_TGZ}"
  echo "${CBFLIB_CHK} ${CBFLIB_TGZ}" | sha256sum -c -
fi

if [ ! -d "${CBFLIB_DIR}" ]; then
  tar xzf "${CBFLIB_TGZ}"
  mv cbflib-${CBFLIB_DIR} ${CBFLIB_DIR}
  pushd "${CBFLIB_DIR}"

  ln -s ../releng .
  patch -p1 < releng/make.patch
  patch -p1 < releng/no-hdf5.patch
  patch -p1 < releng/pointer-leak.patch
  popd
fi

cd "${CBFLIB_DIR}"
