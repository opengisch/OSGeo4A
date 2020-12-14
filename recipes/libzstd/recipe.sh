#!/bin/bash

# version of your package
VERSION_libzstd=v1.4.5

# dependencies of this recipe
DEPS_libzstd=()

# url of the package
URL_libzstd=https://github.com/facebook/zstd/archive/${VERSION_libzstd}.zip

# md5 of the package
MD5_libzstd=beb47f4f92ef69d28400be661cf95c20

# default build path
BUILD_libzstd=$BUILD_PATH/libzstd/$(get_directory $URL_libzstd)

# default recipe path
RECIPE_libzstd=$RECIPES_PATH/libzstd

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libzstd() {
  cd $BUILD_libzstd

  # check marker
  if [ -f .patched ]; then
    return
  fi
}

function shouldbuild_libzstd() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libzstd/build-$ARCH/lib/libzstd.so -nt $BUILD_libzstd/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libzstd() {
  try mkdir -p $BUILD_PATH/libzstd/build-$ARCH
  try cd $BUILD_PATH/libzstd/build-$ARCH
  push_arm

  # configure
  try $CMAKECMD \
  -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
  $BUILD_libzstd/build/cmake/

  # try $MAKESMP
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_libzstd() {
	true
}
