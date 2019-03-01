#!/bin/bash

# version of your package
VERSION_zlib=1.2.11

# dependencies of this recipe
DEPS_zlib=()

# url of the package
URL_zlib=https://www.zlib.net/zlib-${VERSION_zlib}.tar.xz

# md5 of the package
MD5_zlib=85adef240c5f370b308da8c938951a68

# default build path
BUILD_zlib=$BUILD_PATH/zlib/$(get_directory $URL_zlib)

# default recipe path
RECIPE_zlib=$RECIPES_PATH/zlib

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_zlib() {
  cd $BUILD_zlib
  try cp $ROOT_PATH/.packages/config.sub $BUILD_zlib
  try cp $ROOT_PATH/.packages/config.guess $BUILD_zlib

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_zlib() {
  # If lib is newer than the sourcecode skip build
  if [ $STAGE_PATH/lib/libz.so -nt $BUILD_zlib/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_zlib() {
  try mkdir -p $BUILD_PATH/zlib/build-$ARCH
  try cd $BUILD_PATH/zlib/build-$ARCH

  push_arm

  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    $BUILD_zlib
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_zlib() {
	true
}
