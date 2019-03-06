#!/bin/bash

# OpenSSL 1.1.x has new API, so ATM with the new API it is not possible to build QCA
# To see how to build OpenSSL 1.1.x, check  https://github.com/opengisch/OSGeo4A/pull/25

# version of your package
# Best to stick with 1.0.x until QT's binaries are compiled against 1.1.x
# https://github.com/opengisch/OSGeo4A/issues/44
VERSION_openssl=1.0.2p

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
  if [ $STAGE_PATH/lib/libopenssl.so -nt $BUILD_openssl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_openssl() {
  # unfortunately config and Configure uses relative paths to this
  # se we need to do in-source build
  try cp -r $BUILD_openssl $BUILD_PATH/openssl/build-$ARCH
  try cd $BUILD_PATH/openssl/build-$ARCH

  push_arm

  export SYSTEM=android
  ./config shared no-hw --openssldir=/usr/local/ssl/$ANDROIDAPI/ --prefix=/

  # remove install apps
  try $SED '104,121d' apps/Makefile

  # remove docs
  try $SED '646,690d' Makefile
  try $SED '621,643d' Makefile
  # remove "link-shared" target, since we do not want links
  try $SED '346,352d' Makefile
  # remove so.x.y versions
  try $SED 's/LIBVERSION=$(SHLIB_MAJOR).$(SHLIB_MINOR)//g' Makefile
  try $SED 's/LIBCOMPATVERSIONS=";$(SHLIB_VERSION_HISTORY)"//g' Makefile

  # remove -mandroid not recognized by clang
  try $SED 's/-mandroid//g' Makefile

  # ${MAKESMP} depend
  ${MAKESMP} CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs

  # install
  try ${MAKE} INSTALL_PREFIX=$STAGE_PATH install_sw

  pop_arm
}

# function called after all the compile have been done
function postbuild_openssl() {
  true
}
