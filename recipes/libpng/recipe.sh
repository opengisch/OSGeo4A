#!/bin/bash

# version of your package
VERSION_libpng=1.6.37

# dependencies of this recipe
DEPS_libpng=()

# url of the package
URL_libpng=https://sourceforge.net/projects/libpng/files/libpng16/${VERSION_libpng}/libpng-${VERSION_libpng}.tar.xz/download

# filename because sourceforge likes to be special
FILENAME_libpng=libpng-${VERSION_libpng}.tar.xz

# md5 of the package
MD5_libpng=015e8e15db1eecde5f2eb9eb5b6e59e9

# default build path
BUILD_libpng=$BUILD_PATH/libpng/$(get_directory $URL_libpng)

# default recipe path
RECIPE_libpng=$RECIPES_PATH/libpng

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libpng() {
  cd $BUILD_libpng

  # check marker
  if [ -f .patched ]; then
    return
  fi
}

function shouldbuild_libpng() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libpng/build-$ARCH/lib/libpng.so -nt $BUILD_libpng/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libpng() {
  try mkdir -p $BUILD_PATH/libpng/build-$ARCH
  try cd $BUILD_PATH/libpng/build-$ARCH
  push_arm

  # configure
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DHAVE_LD_VERSION_SCRIPT=OFF \
    $BUILD_libpng

  # try $MAKESMP
  try make genfiles
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_libpng() {
	true
}
