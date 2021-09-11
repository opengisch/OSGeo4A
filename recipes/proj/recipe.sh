#!/bin/bash

# version of your package
VERSION_proj=8.1.1

# dependencies of this recipe
DEPS_proj=(sqlite3 libtiff)

# url of the package
URL_proj=https://download.osgeo.org/proj/proj-${VERSION_proj}.tar.gz

# md5 of the package
MD5_proj=f017fd7d35311b0d65b2cf0503844690

# default build path
BUILD_proj=$BUILD_PATH/proj/$(get_directory $URL_proj)

# default recipe path
RECIPE_proj=$RECIPES_PATH/proj

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_proj() {
  cd $BUILD_proj

  # check marker
  if [ -f .patched ]; then
    return
  fi

  patch -p1 < $RECIPE_proj/patches/notest.patch
  touch .patched
}

function shouldbuild_proj() {
  # If lib is newer than the sourcecode skip build
  if [ $STAGE_PATH/lib/libproj.so -nt $BUILD_proj/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_proj() {
  try mkdir -p $BUILD_PATH/proj/build-$ARCH
  try cd $BUILD_PATH/proj/build-$ARCH

  push_arm

  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DPROJ_TESTS=OFF \
    -DEXE_SQLITE3=$(which sqlite3) \
    -DENABLE_CURL=OFF \
    -DBUILD_PROJSYNC=OFF \
    $BUILD_proj
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_proj() {
	true
}
