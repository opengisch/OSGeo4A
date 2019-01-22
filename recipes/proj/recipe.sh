#!/bin/bash

# version of your package
VERSION_proj=5.2

# dependencies of this recipe
DEPS_proj=()

# url of the package
URL_proj=http://download.osgeo.org/proj/proj-5.2.0.tar.gz

# md5 of the package
MD5_proj=ad285c7d03cbb138d9246e10e1f3191c

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

  try cp $ROOT_PATH/.packages/config.sub $BUILD_proj
  try cp $ROOT_PATH/.packages/config.guess $BUILD_proj
}

function shouldbuild_proj() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/proj/build-$ARCH/src/.libs/libproj.so -nt $BUILD_proj/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_proj() {
  try mkdir -p $BUILD_PATH/proj/build-$ARCH
  try cd $BUILD_PATH/proj/build-$ARCH

  push_arm
  try $BUILD_proj/configure \
    --prefix=$STAGE_PATH \
    --host=$TOOLCHAIN_PREFIX \
    --build=x86_64
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_proj() {
	true
}
