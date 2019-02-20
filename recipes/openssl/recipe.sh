#!/bin/bash

# OpenSSL 1.1.x has new API, so ATM with the new API it is not possible to build QCA
# To see how to build OpenSSL 1.1.x, check  https://github.com/opengisch/OSGeo4A/pull/25

# version of your package
VERSION_openssl=1.1.1a

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
  try patch -p1 < $RECIPE_openssl/patches/armeabi.patch

  touch .patched
}

function shouldbuild_openssl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_openssl/libssl.so -nt $BUILD_PATH/openssl/openssl-${VERSION_openssl}/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_openssl() {
  try mkdir -p $BUILD_PATH/openssl/build-$ARCH
  try cd $BUILD_PATH/openssl/build-$ARCH

  push_arm

  MACHINE=$QT_ARCH_PREFIX \
  SYSTEM=android \
  ARCH=$SHORTARCH \
  try $BUILD_openssl/config \
    shared \
    no-asm \
    --prefix=$STAGE_PATH \
    -D__ANDROID_API__=$ANDROIDAPI
  try make SHLIB_EXT=".so" CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" MAKE="make -e" all
  mkdir -p $STAGE_PATH/lib
  echo "place-holder make target for avoiding symlinks" >> $STAGE_PATH/lib/link-shared
  try make SHLIB_EXT=.so install_sw &> install.log
  rm $STAGE_PATH/lib/link-shared

  pop_arm
}

# function called after all the compile have been done
function postbuild_openssl() {
  true
}
