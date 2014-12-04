#!/bin/bash

# version of your package
VERSION_proj=4.9

# dependencies of this recipe
DEPS_proj=()

# url of the package
URL_proj=http://download.osgeo.org/proj/proj-4.9.0b2.tar.gz

# md5 of the package
MD5_proj=d43fd87b991831faaf7e6fb5570b86aa

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

  try cp $BUILD_PATH/tmp/config.sub $BUILD_proj
  try cp $BUILD_PATH/tmp/config.guess $BUILD_proj
  try patch -p1 < $RECIPE_proj/patches/proj4.patch

  touch .patched
}

function shouldbuild_proj() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/proj/build/src/.libs/libproj.so -nt $BUILD_proj/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_proj() {
  try mkdir -p $BUILD_PATH/proj/build
  try cd $BUILD_PATH/proj/build
	push_arm
  try $BUILD_proj/configure --prefix=$DIST_PATH --host=arm-linux-androideabi
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_proj() {
	true
}
