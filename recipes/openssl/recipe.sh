#!/bin/bash

# OpenSSL 1.1.x has new API, so ATM with the new API it is not possible to build QCA
# To see how to build OpenSSL 1.1.x, check  https://github.com/opengisch/OSGeo4A/pull/25

# version of your package
VERSION_openssl=1.0.2o

# dependencies of this recipe
DEPS_openssl=()

# url of the package
URL_openssl=https://www.openssl.org/source/openssl-${VERSION_openssl}.tar.gz


# default recipe path
RECIPE_openssl=$RECIPES_PATH/openssl

# default build path
BUILD_openssl=$BUILD_PATH/openssl/$(get_directory $URL_openssl)

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_openssl() {
  cd $BUILD_PATH/openssl/openssl-${VERSION_openssl}
  # check marker
  if [ -f .patched ]; then
    return
  fi

  echo "patching $BUILD_PATH/openssl/openssl-${VERSION_openssl}/config"
  try $SED 's/armv\[7-9\]\*-\*-android/armeabi-v7a\*-\*-android|armv\[7-9\]\*-\*-android/g' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/config

  echo "patching $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Configure"
  LC_ALL=C try $SED 's/SHLIB_EXT=$shared_extension/SHLIB_EXT=.so/g' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Configure

  touch .patched
}

function shouldbuild_openssl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_openssl/libssl.so -nt $BUILD_openssl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_openssl() {
  # unfortunately config and Configure uses relative paths to this
  # se we need to do in-source build
  try cd $BUILD_openssl

  push_arm

  # https://wiki.openssl.org/index.php/Android
  export _ANDROID_ARCH=arch-$SHORTARCH
  export _ANDROID_EABI=$TOOLCHAIN_PREFIX-$TOOLCHAIN_VERSION
  export _ANDROID_NDK=$ANDROIDNDK
  export _ANDROID_NDK_ROOT=$ANDROIDNDK
  export ANDROID_SDK_ROOT=$ANDROIDSDK
  export _ANDROID_API=android-$ANDROIDAPI

  export MACHINE=${ARCH}
  export RELEASE=2.6.37
  export SYSTEM=android
  # export ARCH is exported in distribute.sh

  export ANDROID_DEV=$_ANDROID_NDK/platforms/$_ANDROID_API/$_ANDROID_ARCH/usr
  export HOSTCC=gcc
  export ANDROID_TOOLCHAIN=$ANDROIDNDK/toolchains/$TOOLCHAIN_BASEDIR-$TOOLCHAIN_VERSION/prebuilt/$PYPLATFORM-x86_64/bin

  CFLAGS_WITHOUT_QUOTES=$(eval echo $CFLAGS)
  CFLAGS_WITHOUT_SYSROOT=${CFLAGS_WITHOUT_QUOTES//"--sysroot $NDKPLATFORM"/}

  ./config \
      shared no-hw \
      --openssldir=/usr/local/ssl/$ANDROIDAPI/ \
      -D__ANDROID_API__=$ANDROIDAPI \
      --prefix=/  \
      $(eval echo $CFLAGS_WITHOUT_SYSROOT)

  echo "patching $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Makefile"
  # remove docs
  try $SED '646,690d' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Makefile
  try $SED '621,643d' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Makefile
  # remove "link-shared" target, since we do not want links
  try $SED '346,352d' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Makefile
  # remove so.x.y versions
  try $SED 's/LIBVERSION=$(SHLIB_MAJOR).$(SHLIB_MINOR)//g' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Makefile
  try $SED 's/LIBCOMPATVERSIONS=";$(SHLIB_VERSION_HISTORY)"//g' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/Makefile

  ${MAKESMP} depend
  ${MAKESMP} CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs

  # install
  try ${MAKE} INSTALL_PREFIX=$STAGE_PATH install
    
  pop_arm
}

# function called after all the compile have been done
function postbuild_openssl() {
  true
}
