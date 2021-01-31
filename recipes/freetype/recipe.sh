#!/bin/bash

# version of your package
VERSION_freetype=2-10-4

# dependencies of this recipe
DEPS_freetype=()

# url of the package
URL_freetype=https://gitlab.freedesktop.org/freetype/freetype/-/archive/VER-${VERSION_freetype}/freetype-VER-${VERSION_freetype}.tar.gz

# md5 of the package
MD5_freetype=00496c4147705ec55c9cac47ba53049b

# default build path
BUILD_freetype=$BUILD_PATH/freetype/$(get_directory $URL_freetype)

# default recipe path
RECIPE_freetype=$RECIPES_PATH/freetype

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_freetype() {
  cd $BUILD_freetype

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_freetype() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/freetype/build-$ARCH/lib/libfreetype.so -nt $BUILD_freetype/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_freetype() {
  try mkdir -p $BUILD_PATH/freetype/build-$ARCH
  try cd $BUILD_PATH/freetype/build-$ARCH
  push_arm
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    $BUILD_freetype
  try $MAKESMP
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_freetype() {
	true
}
