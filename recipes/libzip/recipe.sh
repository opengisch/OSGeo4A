#!/bin/bash

# version of your package
VERSION_libzip=1.2.0

# dependencies of this recipe
DEPS_libzip=()

# url of the package
URL_libzip=https://github.com/dec1/libzip-android/archive/master.zip

# md5 of the package
MD5_libzip=63e1de205a48c6b11034f95457e6aaeb

# default build path
BUILD_libzip=$BUILD_PATH/libzip/$(get_directory $URL_libzip)

# default recipe path
RECIPE_libzip=$RECIPES_PATH/libzip

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libzip() {
  cd $BUILD_libzip

  # check marker
  if [ -f .patched ]; then
    return
  fi
}

function shouldbuild_libzip() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libzip/build-$ARCH/src/.libs/liblibzip.so -nt $BUILD_libzip/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libzip() {
  try mkdir -p $BUILD_PATH/libzip/build-$ARCH
  try cd $BUILD_PATH/libzip/build-$ARCH
  push_arm
  ndk-build APP_STL=gnustl_shared \
    APP_PLATFORM=android-9 \
    APP_ABI="${ARCH}" \
    NDK_TOOLCHAIN_VERSION=5 \
    NDK_PROJECT_PATH=$BUILD_libzip \
    $@
  pop_arm
  cp $BUILD_PATH/libzip/master/libs/${ARCH}/*.so ${STAGE_PATH}/lib
  cp $BUILD_PATH/libzip/master/jni/*.h ${STAGE_PATH}/include
  rm -f ${STAGE_PATH}/include/config.h
}

# function called after all the compile have been done
function postbuild_libzip() {
	true
}
