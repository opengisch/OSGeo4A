#!/bin/bash

# version of your package
VERSION_proj=6.2.0

# dependencies of this recipe
DEPS_proj=(sqlite3)

# url of the package
URL_proj=https://github.com/OSGeo/proj.4/releases/download/${VERSION_proj}/proj-${VERSION_proj}.tar.gz
# https://github.com/OSGeo/proj.4/archive/a8cbe0c66974871f5a7bd7ef94001ebf461ac7ea.tar.gz

# md5 of the package
MD5_proj=5cde556545828beaffbe50b1bb038480

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
    $BUILD_proj
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_proj() {
	true
}
