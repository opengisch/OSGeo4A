#!/bin/bash

# version of your package
VERSION_gsl=1.14

# dependencies of this recipe
DEPS_gsl=()

# url of the package
URL_gsl=http://ftp.gnu.org/gnu/gsl/gsl-${VERSION_gsl}.tar.gz

# md5 of the package
MD5_gsl=d55e7b141815412a072a3f0e12442042

# default build path
BUILD_gsl=$BUILD_PATH/gsl/$(get_directory $URL_gsl)

# default recipe path
RECIPE_gsl=$RECIPES_PATH/gsl

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_gsl() {
  cd $BUILD_gsl

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_gsl
  try cp $BUILD_PATH/tmp/config.guess $BUILD_gsl
  try patch -p1 < $RECIPE_gsl/patches/gsl.patch

  touch .patched
}

# function called to build the source code
function build_gsl() {
  try mkdir -p $BUILD_PATH/gsl/build
  try cd $BUILD_PATH/gsl/build
	push_arm
  printenv
  try $BUILD_gsl/configure --prefix=$DIST_PATH --host=arm-linux-androideabi
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_gsl() {
	true
}
