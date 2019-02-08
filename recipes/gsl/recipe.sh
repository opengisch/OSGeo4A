#!/bin/bash

# version of your package
VERSION_gsl=1.16

# dependencies of this recipe
DEPS_gsl=()

# url of the package
URL_gsl=http://ftpmirror.gnu.org/gnu/gsl/gsl-${VERSION_gsl}.tar.gz

# md5 of the package
MD5_gsl=e49a664db13d81c968415cd53f62bc8b

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

  try cp $ROOT_PATH/.packages/config.sub $BUILD_gsl
  try cp $ROOT_PATH/.packages/config.guess $BUILD_gsl
  try patch -p1 < $RECIPE_gsl/patches/gsl.patch

  touch .patched
}

function shouldbuild_gsl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/gsl/build-$ARCH/.libs/libgsl.so -nt $BUILD_gsl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_gsl() {
  mkdir $BUILD_PATH/gsl/build-$ARCH
  cd $BUILD_PATH/gsl/build-$ARCH
	push_arm
  try $BUILD_gsl/configure \
    --prefix=$STAGE_PATH \
    --host=$TOOLCHAIN_PREFIX \
    --build=x86_64
  try $MAKESMP
  try make install
	pop_arm
}

# function called after all the compile have been done
function postbuild_gsl() {
	true
}
