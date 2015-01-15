#!/bin/bash

# version of your package
VERSION_freexl=1.0.0e

# dependencies of this recipe
DEPS_freexl=(iconv)

# url of the package
URL_freexl=http://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${VERSION_freexl}.tar.gz

# md5 of the package
MD5_freexl=9b494d42a079e63afbb9dc0915e8fb56

# default build path
BUILD_freexl=$BUILD_PATH/freexl/$(get_directory $URL_freexl)

# default recipe path
RECIPE_freexl=$RECIPES_PATH/freexl

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_freexl() {
  cd $BUILD_freexl

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_freexl
  try cp $BUILD_PATH/tmp/config.guess $BUILD_freexl
  try patch -p1 < $RECIPE_freexl/patches/freexl.patch

  touch .patched
}

function shouldbuild_freexl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/freexl/build/src/.libs/libfreexl.so -nt $BUILD_freexl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_freexl() {
  try mkdir -p $BUILD_PATH/freexl/build
  try cd $BUILD_PATH/freexl/build
	push_arm
  try $BUILD_freexl/configure --prefix=$STAGE_PATH --host=arm-linux-androideabi
  try make install
	pop_arm
}

# function called after all the compile have been done
function postbuild_freexl() {
	true
}
