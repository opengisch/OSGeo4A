#!/bin/bash

# OpenSSL 1.1.x has new API compared to 1.0.2
# We need to stick with the version of SSL that is
# compatible with Qt's binaries, otherwise
# you got (runtime)
# "qt.network.ssl: QSslSocket::connectToHostEncrypted: TLS initialization failed"
#
# https://blog.qt.io/blog/2019/06/17/qt-5-12-4-released-support-openssl-1-1-1/
# see https://wiki.qt.io/Qt_5.12_Tools_and_Versions
# Qt 5.12.3 OpenSSL 1.0.2b
# Qt 5.12.4 OpenSSL 1.1.1
# Qt 5.13.0 OpenSSL 1.1.1


# version of your package
VERSION_openssl=1.1.1

# dependencies of this recipe
DEPS_openssl=()

# url of the package
URL_openssl=https://www.openssl.org/source/openssl-${VERSION_openssl}.tar.gz

# default recipe path
RECIPE_openssl=$RECIPES_PATH/openssl

# default build path
BUILD_openssl=$BUILD_PATH/openssl/$(get_directory $URL_openssl)

# function called for preparing source code if needed
function prebuild_openssl() {
  # echo "patching $BUILD_PATH/openssl/openssl-${VERSION_openssl}/config"
  try ${SED} 's/android-armeabi/android-arm/g' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/config

  # ad random seed & patch of rand_unix.c: https://mta.openssl.org/pipermail/openssl-users/2018-September/008860.html
  PWD=`pwd`
  cd $BUILD_PATH/openssl/openssl-${VERSION_openssl}/crypto/rand/
  try patch -p1 rand_unix.c $RECIPE_openssl/patches/rand_unix.patch
  cd $PWD

  touch .patched
}

function shouldbuild_openssl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/openssl/build-$ARCH/libssl.so -nt $BUILD_openssl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_openssl() {
  # try mkdir -p $BUILD_PATH/openssl/build-$ARCH
  try cp -r $BUILD_openssl $BUILD_PATH/openssl/build-$ARCH
  try cd $BUILD_PATH/openssl/build-$ARCH

  push_arm

  export CROSS_COMPILE=$ANDROID_EABI-
  # tools are prefixed in config
  export CC=$NDK_TOOLCHAIN_BASENAMEgcc
  export AR=$NDK_TOOLCHAIN_BASENAMEar
  export CXX=$NDK_TOOLCHAIN_BASENAMEg++
  export LINK=${CXX}
  export LD=$NDK_TOOLCHAIN_BASENAMEld
  export RANLIB=$NDK_TOOLCHAIN_BASENAMEranlib
  export STRIP=$NDK_TOOLCHAIN_BASENAMEstrip

  # Setup compiler toolchain based on CPU architecture
  if [ "X${ARCH}" == "Xarmeabi-v7a" ]; then
      export SSL_ARCH=android-arm
  elif [ "X${ARCH}" == "Xarm64-v8a" ]; then
      export SSL_ARCH=android-arm64
  else
      echo "Error: Please report issue to enable support for arch (${ARCH})."
      exit 1
  fi

  try ./Configure ${SSL_ARCH} -D__ANDROID_API__=$ANDROIDAPI no-engine --prefix=/

  try $SED 's/SHLIB_EXT=.so.$(SHLIB_VERSION_NUMBER)/SHLIB_EXT=.so/g' Makefile
  try ${MAKESMP} CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs

  # install
  try $SED 's/DESTDIR=/DESTDIR=$STAGE_PATH/g' Makefile
  try ${MAKE} DESTDIR=$STAGE_PATH install_dev install_engines

  pop_arm
}

# function called after all the compile have been done
function postbuild_openssl() {
  true
}
