#!/bin/bash

# version of your package
VERSION_libtiff=4.0.6

# dependencies of this recipe
DEPS_libtiff=()

# url of the package
URL_libtiff=http://download.osgeo.org/libtiff/tiff-${VERSION_libtiff}.tar.gz

# md5 of the package
MD5_libtiff=d1d2e940dea0b5ad435f21f03d96dd72

# default build path
BUILD_libtiff=$BUILD_PATH/libtiff/$(get_directory $URL_libtiff)

# default recipe path
RECIPE_libtiff=$RECIPES_PATH/libtiff

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libtiff() {
  cd $BUILD_libtiff

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_PATH/.packages/config.sub $BUILD_libtiff/config
  try cp $ROOT_PATH/.packages/config.guess $BUILD_libtiff/config
  # try patch -p1 < $RECIPE_libtiff/patches/libtiff.patch

  touch .patched
}

# function called before build_libtiff
# set DO_BUILD=0 if you know that it does not require a rebuild
function shouldbuild_libtiff() {
# If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libtiff/build-$ARCH/libtiff/libtiff.so -nt $BUILD_libtiff/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libtiff() {
  try mkdir -p $BUILD_PATH/libtiff/build-$ARCH
  try cd $BUILD_PATH/libtiff/build-$ARCH
  push_arm
  try cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
    -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI \
    -DANDROID_TOOLCHAIN_VERSION=gcc-4.9 \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DANDROID_ABI=$ARCH \
    -DANDROID_NDK=$ANDROID_NDK \
    $BUILD_libtiff
  try make install
  pop_arm
}

# function called after all the compile have been done
function postbuild_libtiff() {
  true
}
